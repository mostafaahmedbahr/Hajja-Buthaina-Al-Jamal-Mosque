import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// خدمة معزولة مسؤولة فقط عن "الصوت": نغمة تنبيه + نطق جملة الأذان بالعربية.
/// معزولة تمامًا عن الـ Cubit حتى يسهل استبدالها لاحقًا (مثلاً بتشغيل ملف
/// أذان حقيقي بدل الجملة المنطوقة) دون المساس بأي طبقة أخرى.
class AthanAnnouncerService {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _ttsConfigured = false;

  Future<void> _configureTtsIfNeeded() async {
    if (_ttsConfigured) return;
    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(0.42); // بطيء نسبيًا ليكون واضحًا في صالة المسجد
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _ttsConfigured = true;
  }

  /// تشغيل نغمة الترحيب القصيرة (assets/audio/chime.wav)
  Future<void> playChime() async {
    try {
      await _player.play(AssetSource('audio/chime.wav'));
    } catch (_) {
      // لو تعذر تشغيل الصوت لأي سبب، لا نوقف باقي التطبيق
    }
  }

  /// نطق: "حان الآن موعد صلاة الظهر" (أو أي صلاة أخرى)
  Future<void> announce(String prayerArabicName) async {
    await playChime();
    await _configureTtsIfNeeded();
    // تأخير بسيط حتى تنتهي النغمة قبل بدء الكلام
    await Future.delayed(const Duration(milliseconds: 1300));
    await _tts.speak('حان الآن موعد صلاة $prayerArabicName');
  }

  void dispose() {
    _player.dispose();
    _tts.stop();
  }
}
