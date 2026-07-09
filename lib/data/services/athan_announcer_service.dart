import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// خدمة معزولة مسؤولة فقط عن "الصوت": نطق جملة الأذان بالعربية بصوت رجل.
class AthanAnnouncerService {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _ttsConfigured = false;

  static const List<Map<String, String>> _maleVoices = [
    {'name': 'Microsoft Naayf Mobile', 'locale': 'ar-SA'},
    {'name': 'Naayf', 'locale': 'ar-SA'},
    {'name': 'Maged', 'locale': 'ar-SA'},
    {'name': 'HamedNeural', 'locale': 'ar-SA'},
    {'name': 'ShakirNeural', 'locale': 'ar-EG'},
    {'name': 'ar-sa-x-asa-network', 'locale': 'ar-SA'},
    {'name': 'ar-eg-x-arc-network', 'locale': 'ar-EG'},
  ];

  Future<void> _configureTtsIfNeeded() async {
    if (_ttsConfigured) return;
    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(0.55);
    await _tts.setVolume(1.0);
    for (final v in _maleVoices) {
      try {
        await _tts.setVoice(v);
        break;
      } catch (_) {
        continue;
      }
    }
    _ttsConfigured = true;
  }

  /// نطق: "حان الآن موعد صلاة الظهر" بصوت رجل
  Future<void> announce(String prayerArabicName) async {
    await _configureTtsIfNeeded();

    await _tts.setVoice({
      "name": "ar-xa-x-ard-network",
      "locale": "ar",
    });

    // await _tts.setVoice({
    //   "name": "ar-xa-x-arc-network",
    //   "locale": "ar",
    // });
    // await _tts.setVoice({
    //   "name": "ar-xa-x-arz-local",
    //   "locale": "ar",
    // });
    // await _tts.setVoice({
    //   "name": "ar-xa-x-arz-local",
    //   "locale": "ar",
    // });
    await _player.play(
      AssetSource('audio/chime.wav'),
    );

    await Future.delayed(const Duration(milliseconds: 1300));

    await _tts.speak('حان الآن موعد صلاة $prayerArabicName');
  }

  void dispose() {
    _player.dispose();
    _tts.stop();
  }
}
