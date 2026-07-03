import 'package:flutter/material.dart';
import '../../core/constants/mosque_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// شريط أذكار متحرك بلا نهاية — يعتمد على قياس عرض المحتوى الفعلي
/// ثم تحريكه بسرعة ثابتة (بيكسل/ثانية) بدل مدة زمنية ثابتة،
/// حتى تبقى السرعة منطقية بغض النظر عن طول نص الأذكار.
class AzkarTickerWidget extends StatefulWidget {
  const AzkarTickerWidget({super.key});

  @override
  State<AzkarTickerWidget> createState() => _AzkarTickerWidgetState();
}

class _AzkarTickerWidgetState extends State<AzkarTickerWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final GlobalKey _contentKey = GlobalKey();
  double _contentWidth = 0;

  static const double _pixelsPerSecond = 55;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndStart());
  }

  void _measureAndStart() {
    final box = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final width = box.size.width;
    setState(() => _contentWidth = width);
    _controller.duration = Duration(milliseconds: (width / _pixelsPerSecond * 1000).round());
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAzkarRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: MosqueConfig.azkarList.map((z) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(z, style: AppTextStyles.tickerText),
              const SizedBox(width: 26),
              const Text('❖', style: TextStyle(color: AppColors.ember)),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offset = _contentWidth > 0 ? (_controller.value * _contentWidth) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
        gradient: LinearGradient(
          colors: [AppColors.bgPanel, AppColors.bgPanel2, AppColors.bgPanel],
        ),
      ),
      child: ClipRect(
        child: SizedBox(
          height: 26,
          child: Stack(
            children: [
              // نسخة مخفية فقط لقياس العرض الحقيقي للمحتوى
              Opacity(
                opacity: 0,
                child: Row(key: _contentKey, mainAxisSize: MainAxisSize.min, children: [_buildAzkarRow()]),
              ),
              if (_contentWidth > 0)
                Positioned(
                  top: 0,
                  right: -offset, // في RTL نحرّك من اليمين لليسار
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildAzkarRow(), _buildAzkarRow()], // تكرار لضمان تمرير سلس
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
