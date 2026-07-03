import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/daily_timings_model.dart';
import '../../data/models/prayer_time_model.dart';
import '../../data/repositories/prayer_repository.dart';
import '../../data/services/athan_announcer_service.dart';
import 'prayer_state.dart';

/// الـ ViewModel الوحيد في التطبيق. مسؤولياته فقط:
/// 1) جلب المواقيت من الـ Repository
/// 2) عدّ الوقت كل ثانية وحساب الصلاة القادمة
/// 3) استدعاء خدمة الصوت عند دخول وقت الصلاة بالضبط
/// الواجهة (View) لا تعرف شيئًا عن أي من هذا، فقط تستمع لـ state.
class PrayerCubit extends Cubit<PrayerState> {
  final PrayerRepository _repository;
  final AthanAnnouncerService _announcer;

  Timer? _secondTimer;
  Timer? _refreshTimer;

  List<PrayerTimeModel> _todayPrayers = [];
  PrayerTimeModel? _tomorrowFajr;

  PrayerCubit({
    required PrayerRepository repository,
    required AthanAnnouncerService announcer,
  })  : _repository = repository,
        _announcer = announcer,
        super(PrayerState.initial());

  Future<void> init() async {
    await _loadTimings();
    _tick(); // رسم فوري بدون انتظار أول ثانية
    _secondTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    // إعادة الجلب كل ساعة تلتقط تلقائيًا تغيّر اليوم بعد منتصف الليل
    _refreshTimer = Timer.periodic(const Duration(hours: 1), (_) => _loadTimings());
  }

  Future<void> _loadTimings() async {
    final DailyTimingsModel daily = await _repository.getTodayTimings();
    _todayPrayers = daily.prayers;
    _tomorrowFajr = daily.tomorrowFajr;

    emit(state.copyWith(
      status: PrayerStatus.ready,
      hijriText: daily.hijriText,
      gregorianText: daily.gregorianText,
      prayers: daily.prayers,
    ));
  }

  void _tick() {
    if (_todayPrayers.isEmpty || _tomorrowFajr == null) return;

    final now = DateTime.now();
    final all = [..._todayPrayers, _tomorrowFajr!];

    PrayerTimeModel next = all.firstWhere(
      (p) => p.time.isAfter(now),
      orElse: () => _tomorrowFajr!,
    );

    final idx = all.indexOf(next);
    final windowStart = idx > 0 ? all[idx - 1].time : next.time.subtract(const Duration(hours: 6));
    final secondsToNext = next.time.difference(now).inSeconds.clamp(0, 1 << 30);

    // اكتشاف لحظة دخول الوقت بدقّة (نافذة ثانية واحدة) لتفادي تكرار التنبيه
    final fireKey = '${now.year}-${now.month}-${now.day}-${next.key}-${next.time.hour}:${next.time.minute}';
    if (secondsToNext == 0 && state.firedKey != fireKey) {
      _announcer.announce(next.arabicName);
      emit(state.copyWith(firedKey: fireKey));
    }

    emit(state.copyWith(
      now: now,
      nextPrayer: next,
      windowStart: windowStart,
      windowEnd: next.time,
      secondsToNext: secondsToNext,
    ));
  }

  /// يُستخدم من زر "تجربة الأذان" في الواجهة فقط — لا علاقة له بمنطق التوقيت الحقيقي
  void testAnnounceNext() {
    final name = state.nextPrayer?.arabicName ?? 'الظهر';
    _announcer.announce(name);
  }

  @override
  Future<void> close() {
    _secondTimer?.cancel();
    _refreshTimer?.cancel();
    _announcer.dispose();
    return super.close();
  }
}
