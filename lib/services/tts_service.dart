import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static TtsEngine _engine = _FlutterTtsEngine();
  static int _requestId = 0;

  static bool enabled = true;

  static void setEnabled(bool value) {
    enabled = value;
    if (!value) {
      stop();
    }
  }

  @visibleForTesting
  static void replaceEngineForTesting(TtsEngine engine) {
    _engine = engine;
  }

  @visibleForTesting
  static void restoreDefaultEngine() {
    _engine = _FlutterTtsEngine();
    enabled = true;
    _requestId = 0;
  }

  static Future<void> speak(String text, String languageCode) async {
    if (!enabled) return;
    final requestId = ++_requestId;
    try {
      await _engine.stop();
      await _engine.awaitSpeakCompletion(false);
      await _engine.setLanguage(languageCode);
      await _engine.setSpeechRate(0.5);
      await _engine.setVolume(1.0);
      if (!kIsWeb) {
        await _engine.setPitch(1.0);
      }
      if (!enabled || requestId != _requestId) return;
      await _engine.speak(text);
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  static Future<void> stop() async {
    _requestId++;
    try {
      await _engine.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }
}

abstract class TtsEngine {
  Future<void> stop();
  Future<void> awaitSpeakCompletion(bool awaitCompletion);
  Future<void> setLanguage(String languageCode);
  Future<void> setSpeechRate(double rate);
  Future<void> setVolume(double volume);
  Future<void> setPitch(double pitch);
  Future<void> speak(String text);
}

class _FlutterTtsEngine implements TtsEngine {
  final FlutterTts _tts = FlutterTts();

  @override
  Future<void> awaitSpeakCompletion(bool awaitCompletion) async {
    await _tts.awaitSpeakCompletion(awaitCompletion);
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    await _tts.setLanguage(languageCode);
  }

  @override
  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume);
  }

  @override
  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
