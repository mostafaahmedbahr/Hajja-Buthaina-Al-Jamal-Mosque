import 'package:flutter/material.dart';

/// نظام الألوان — مبني على لون الهوية المأخوذ من صفحة mawaqit.net للمسجد (#da532c)
/// مع خلفية خضراء ليلية عميقة وتذهيب يوحي بأجواء المسجد.
class AppColors {
  AppColors._();

  static const Color bgDeep = Color(0xFF081713);
  static const Color bgPanel = Color(0xFF0D251F);
  static const Color bgPanel2 = Color(0xFF123024);

  static const Color gold = Color(0xFFD4AF37);
  static const Color goldSoft = Color(0xFFF2D98A);
  static const Color ember = Color(0xFFDA532C); // لون هوية mawaqit
  static const Color ivory = Color(0xFFF6ECD9);
  static const Color muted = Color(0xFF8FA89C);
  static const Color line = Color(0x3CD4AF37); // gold بشفافية 22%

  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgPanel, bgPanel2],
  );

  static const LinearGradient activeCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A3226), Color(0xFF14281F)],
  );

  static const LinearGradient domeFillGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [ember, gold, goldSoft],
  );
}
