import 'package:equatable/equatable.dart';
import '../../data/models/prayer_time_model.dart';

enum PrayerStatus { loading, ready, error }

/// الحالة الكاملة التي تحتاجها الواجهة لرسم نفسها بالكامل — لا شيء أكثر ولا أقل.
class PrayerState extends Equatable {
  final PrayerStatus status;
  final DateTime now;
  final String hijriText;
  final String gregorianText;
  final List<PrayerTimeModel> prayers; // صلوات اليوم الخمس
  final PrayerTimeModel? nextPrayer;
  final DateTime? windowStart; // بداية الفترة (الصلاة السابقة)
  final DateTime? windowEnd; // نهاية الفترة (الصلاة القادمة) = وقت التنبيه
  final int secondsToNext;
  final String? firedKey; // مفتاح آخر تنبيه تم تشغيله (لمنع التكرار)

  const PrayerState({
    this.status = PrayerStatus.loading,
    required this.now,
    this.hijriText = '—',
    this.gregorianText = '—',
    this.prayers = const [],
    this.nextPrayer,
    this.windowStart,
    this.windowEnd,
    this.secondsToNext = 0,
    this.firedKey,
  });

  factory PrayerState.initial() => PrayerState(now: DateTime.now());

  PrayerState copyWith({
    PrayerStatus? status,
    DateTime? now,
    String? hijriText,
    String? gregorianText,
    List<PrayerTimeModel>? prayers,
    PrayerTimeModel? nextPrayer,
    DateTime? windowStart,
    DateTime? windowEnd,
    int? secondsToNext,
    String? firedKey,
  }) {
    return PrayerState(
      status: status ?? this.status,
      now: now ?? this.now,
      hijriText: hijriText ?? this.hijriText,
      gregorianText: gregorianText ?? this.gregorianText,
      prayers: prayers ?? this.prayers,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      windowStart: windowStart ?? this.windowStart,
      windowEnd: windowEnd ?? this.windowEnd,
      secondsToNext: secondsToNext ?? this.secondsToNext,
      firedKey: firedKey ?? this.firedKey,
    );
  }

  /// النسبة المئوية لامتلاء القبة (0.0 → 1.0) — تُستخدم في الرسم فقط
  double get windowProgress {
    if (windowStart == null || windowEnd == null) return 0;
    final total = windowEnd!.difference(windowStart!).inSeconds;
    if (total <= 0) return 0;
    final elapsed = total - secondsToNext;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        status,
        now,
        hijriText,
        gregorianText,
        prayers,
        nextPrayer,
        windowStart,
        windowEnd,
        secondsToNext,
        firedKey,
      ];
}
