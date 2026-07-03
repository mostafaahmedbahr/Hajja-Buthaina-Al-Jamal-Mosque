import 'package:equatable/equatable.dart';

/// نموذج بيانات لصلاة واحدة (وقت الأذان + وقت الإقامة المحسوب)
class PrayerTimeModel extends Equatable {
  final String key; // Fajr / Dhuhr / Asr / Maghrib / Isha
  final String arabicName;
  final String iconName;
  final DateTime time;
  final DateTime iqamaTime;

  const PrayerTimeModel({
    required this.key,
    required this.arabicName,
    required this.iconName,
    required this.time,
    required this.iqamaTime,
  });

  PrayerTimeModel copyWith({DateTime? time, DateTime? iqamaTime}) {
    return PrayerTimeModel(
      key: key,
      arabicName: arabicName,
      iconName: iconName,
      time: time ?? this.time,
      iqamaTime: iqamaTime ?? this.iqamaTime,
    );
  }

  @override
  List<Object?> get props => [key, time, iqamaTime];
}
