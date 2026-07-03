import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/prayer_time_model.dart';

const Map<String, IconData> _kPrayerIcons = {
  'sunrise': Icons.wb_twilight,
  'sun': Icons.wb_sunny_rounded,
  'sun_low': Icons.brightness_6_rounded,
  'sunset': Icons.wb_twilight,
  'moon': Icons.nightlight_round,
};

class PrayerCardWidget extends StatelessWidget {
  final PrayerTimeModel prayer;
  final bool isActive;
  final bool isPassed;

  const PrayerCardWidget({
    super.key,
    required this.prayer,
    required this.isActive,
    required this.isPassed,
  });

  String _fmtHM(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final pad = (int n) => n.toString().padLeft(2, '0');
    final mer = d.hour >= 12 ? 'م' : 'ص';
    return '${pad(h12)}:${pad(d.minute)} $mer';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      transform: isActive ? (Matrix4.identity()..translate(0.0, -6.0)) : Matrix4.identity(),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        gradient: isActive ? AppColors.activeCardGradient : AppColors.panelGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isActive ? AppColors.gold : AppColors.line, width: 1),
        boxShadow: isActive
            ? [
                BoxShadow(color: AppColors.gold.withOpacity(.35), blurRadius: 24, spreadRadius: 1),
                const BoxShadow(color: Colors.black45, blurRadius: 30, offset: Offset(0, 18)),
              ]
            : null,
      ),
      child: Opacity(
        opacity: (isPassed && !isActive) ? 0.5 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 3,
                width: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(colors: [AppColors.ember, AppColors.gold]),
                ),
              ),
            Icon(_kPrayerIcons[prayer.iconName] ?? Icons.circle, color: AppColors.gold, size: 24),
            const SizedBox(height: 6),
            Text(prayer.arabicName, style: AppTextStyles.cardPrayerName),
            const SizedBox(height: 4),
            Text(_fmtHM(prayer.time), style: AppTextStyles.cardPrayerTime),
            const SizedBox(height: 4),
            Text('الإقامة ${_fmtHM(prayer.iqamaTime)}', style: AppTextStyles.cardIqama),
          ],
        ),
      ),
    );
  }
}

/// صف الصلوات الخمس — Wrap يتكيّف تلقائيًا مع عرض الشاشة (تابلت/تلفزيون/موبايل)
class PrayerRowWidget extends StatelessWidget {
  final List<PrayerTimeModel> prayers;
  final PrayerTimeModel? nextPrayer;
  final DateTime now;

  const PrayerRowWidget({
    super.key,
    required this.prayers,
    required this.nextPrayer,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760
            ? 5
            : constraints.maxWidth > 480
                ? 3
                : 2;
        final cardWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: prayers.map((p) {
            final isActive = nextPrayer != null &&
                nextPrayer!.key == p.key &&
                nextPrayer!.time.isAtSameMomentAs(p.time);
            final isPassed = p.time.isBefore(now);
            return SizedBox(
              width: cardWidth,
              child: PrayerCardWidget(prayer: p, isActive: isActive, isPassed: isPassed),
            );
          }).toList(),
        );
      },
    );
  }
}
