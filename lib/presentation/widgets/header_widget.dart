import 'package:flutter/material.dart';
import '../../core/constants/mosque_config.dart';
import '../../core/theme/app_text_styles.dart';
import '../cubit/prayer_state.dart';

class HeaderWidget extends StatelessWidget {
  final PrayerState state;
  const HeaderWidget({super.key, required this.state});

  String _clockTime(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(h12)}:${pad(d.minute)}:${pad(d.second)}';
  }

  String _meridiem(DateTime d) => d.hour >= 12 ? 'مساءً' : 'صباحًا';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 12,
        children: [
          // التاريخ الميلادي + الهجري
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.gregorianText, style: AppTextStyles.dateGregorian),
              const SizedBox(height: 3),
              Text(state.hijriText, style: AppTextStyles.dateHijri),
            ],
          ),

          // اسم المسجد
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(MosqueConfig.name, style: AppTextStyles.mosqueTitle, textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Text(MosqueConfig.city, style: AppTextStyles.mosqueSubtitle),
            ],
          ),

          // الساعة الحية
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_clockTime(state.now), style: AppTextStyles.clockTime),
              const SizedBox(height: 3),
              Text(_meridiem(state.now), style: AppTextStyles.clockMeridiem),
            ],
          ),
        ],
      ),
    );
  }
}
