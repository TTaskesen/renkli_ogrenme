import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();

  static bool enabled = true;

  static Future<void> speak(String text, String languageCode) async {
    if (!enabled) return;
    try {
      await _tts.stop();
      await _tts.awaitSpeakCompletion(false);
      await _tts.setLanguage(languageCode);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      if (!kIsWeb) {
        await _tts.setPitch(1.0);
      }
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }
}
