import 'package:equatable/equatable.dart';
import 'prayer_time_model.dart';

/// نتيجة تحويل استجابة Aladhan API إلى بيانات جاهزة للاستخدام في التطبيق
class DailyTimingsModel extends Equatable {
  final String hijriText;
  final String gregorianText;
  final List<PrayerTimeModel> prayers; // خمس صلوات اليوم بالترتيب
  final PrayerTimeModel tomorrowFajr; // مرجع لحساب العد التنازلي بعد العشاء

  const DailyTimingsModel({
    required this.hijriText,
    required this.gregorianText,
    required this.prayers,
    required this.tomorrowFajr,
  });

  @override
  List<Object?> get props => [hijriText, gregorianText, prayers, tomorrowFajr];
}
