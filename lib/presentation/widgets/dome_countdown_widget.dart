import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../cubit/prayer_state.dart';

/// العنصر المميز في التصميم: قوس محراب يمتلئ تدريجيًا (كساعة رملية)
/// كلما اقترب موعد الصلاة القادمة، ويصل لامتلائه الكامل بالضبط عند دخول الوقت.
class DomeCountdownWidget extends StatelessWidget {
  final PrayerState state;
  const DomeCountdownWidget({super.key, required this.state});

  String _fmtCountdown(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final pad = (int n) => n.toString().padLeft(2, '0');
    return '${pad(h)}:${pad(m)}:${pad(s)}';
  }

  String _fmtHM(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final pad = (int n) => n.toString().padLeft(2, '0');
    final mer = d.hour >= 12 ? 'م' : 'ص';
    return '${pad(h12)}:${pad(d.minute)} $mer';
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer = state.nextPrayer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 240,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // القوس + الامتلاء المتصاعد
              CustomPaint(
                size: const Size(240, 300),
                painter: _ArchPainter(progress: state.windowProgress),
              ),

              // النصوص المتراكبة فوق القوس
              Positioned(
                top: 90,
                child: Text('الصلاة القادمة', style: AppTextStyles.domeLabel),
              ),
              Positioned(
                top: 112,
                child: Text(
                  nextPrayer?.arabicName ?? '—',
                  style: AppTextStyles.domePrayerName,
                ),
              ),
              Positioned(
                top: 165,
                child: Text(
                  _fmtCountdown(state.secondsToNext),
                  style: AppTextStyles.domeCountdown,
                ),
              ),
              Positioned(
                top: 200,
                child: Text(
                  nextPrayer != null ? 'عند ${_fmtHM(nextPrayer.time)}' : '',
                  style: AppTextStyles.domeTargetTime,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'تحسب الشاشة الوقت المتبقي تلقائيًا وتنبّه عند دخول الوقت',
          style: AppTextStyles.domeLabel,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ArchPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  _ArchPainter({required this.progress});

  Path _archPath(Size size) {
    // قوس محراب مبسّط: قاعدة مستطيلة + قمة منحنية (شبيه بمدخل المسجد)
    final path = Path();
    path.moveTo(42, 300);
    path.lineTo(42, 150);
    path.quadraticBezierTo(42, 58, 120, 28);
    path.quadraticBezierTo(198, 58, 198, 150);
    path.lineTo(198, 300);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final archPath = _archPath(size);

    // خلفية القوس
    final bgPaint = Paint()..color = AppColors.bgPanel2;
    canvas.drawPath(archPath, bgPaint);

    // الامتلاء المتدرج مقصوصًا داخل شكل القوس فقط
    canvas.save();
    canvas.clipPath(archPath);

    const double archTop = 28;
    const double archBottom = 300;
    final fillHeight = progress * (archBottom - archTop);
    final fillRect = Rect.fromLTWH(0, archBottom - fillHeight, size.width, fillHeight);

    final fillPaint = Paint()
      ..shader = AppColors.domeFillGradient.createShader(
        Rect.fromLTWH(0, archTop, size.width, archBottom - archTop),
      );
    canvas.drawRect(fillRect, fillPaint);
    canvas.restore();

    // إطار القوس الذهبي
    final strokePaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(archPath, strokePaint);

    // هلال زخرفي أعلى القوس
    final crescentPaint = Paint()..color = AppColors.gold;
    canvas.drawCircle(const Offset(120, 14), 9, crescentPaint);
    final maskPaint = Paint()..color = AppColors.bgDeep;
    canvas.drawCircle(const Offset(124, 11), 8, maskPaint);
  }

  @override
  bool shouldRepaint(covariant _ArchPainter oldDelegate) => oldDelegate.progress != progress;
}
