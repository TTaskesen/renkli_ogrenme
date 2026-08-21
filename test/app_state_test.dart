import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:renkli_ogrenme/services/app_state.dart';
import 'package:renkli_ogrenme/services/tts_service.dart';

class _FakeTtsEngine implements TtsEngine {
  int stopCount = 0;
  final List<String> spokenTexts = [];
  final List<String> configuredLanguages = [];

  @override
  Future<void> awaitSpeakCompletion(bool awaitCompletion) async {}

  @override
  Future<void> setLanguage(String languageCode) async {
    configuredLanguages.add(languageCode);
  }

  @override
  Future<void> setPitch(double pitch) async {}

  @override
  Future<void> setSpeechRate(double rate) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> speak(String text) async => spokenTexts.add(text);

  @override
  Future<void> stop() async => stopCount++;
}

class _BlockingTtsEngine extends _FakeTtsEngine {
  final languageConfigured = Completer<void>();

  @override
  Future<void> setLanguage(String languageCode) => languageConfigured.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppState language', () {
    test('defaults to Turkish', () {
      final app = AppState();
      expect(app.language, AppLanguage.tr);
      expect(app.t('app_name'), 'Renkli Öğrenme');
      expect(app.langCode, 'tr-TR');
    });

    test('switches to English', () {
      SharedPreferences.setMockInitialValues({});
      final app = AppState();
      app.setLanguage(AppLanguage.en);
      expect(app.language, AppLanguage.en);
      expect(app.t('app_name'), 'Colorful Learning');
      expect(app.langCode, 'en-US');
    });

    test('persists sound preference across instances', () async {
      SharedPreferences.setMockInitialValues({});
      final engine = _FakeTtsEngine();
      TtsService.replaceEngineForTesting(engine);
      addTearDown(TtsService.restoreDefaultEngine);
      final app1 = AppState();
      await app1.init();
      expect(app1.soundEnabled, isTrue);
      app1.setSoundEnabled(false);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final app2 = AppState();
      await app2.init();
      expect(app2.soundEnabled, isFalse);
    });

    test('switches to French', () {
      SharedPreferences.setMockInitialValues({});
      final app = AppState();
      app.setLanguage(AppLanguage.fr);
      expect(app.language, AppLanguage.fr);
      expect(app.t('app_name'), 'Apprentissage Coloré');
      expect(app.langCode, 'fr-FR');
    });

    test('switches to Kurmanji', () {
      SharedPreferences.setMockInitialValues({});
      final app = AppState();
      app.setLanguage(AppLanguage.ku);
      expect(app.language, AppLanguage.ku);
      expect(app.t('app_name'), 'Hînkirina Rengîn');
      expect(app.langCode, 'ku');
    });

    test('falls back to the key for missing translations', () {
      final app = AppState();
      expect(app.t('missing_key_xyz'), 'missing_key_xyz');
    });

    test('persists language across instances', () async {
      SharedPreferences.setMockInitialValues({});
      final app1 = AppState();
      await app1.init();
      app1.setLanguage(AppLanguage.fr);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final app2 = AppState();
      await app2.init();
      expect(app2.language, AppLanguage.fr);
      expect(app2.t('app_name'), 'Apprentissage Coloré');
    });
  });

  group('AppState sound', () {
    tearDown(TtsService.restoreDefaultEngine);

    test('stops active speech as soon as sound is disabled', () async {
      final engine = _FakeTtsEngine();
      TtsService.replaceEngineForTesting(engine);
      final app = AppState();

      app.setSoundEnabled(false);
      await Future<void>.delayed(Duration.zero);

      expect(app.soundEnabled, isFalse);
      expect(TtsService.enabled, isFalse);
      expect(engine.stopCount, 1);
    });

    test('uses the engine again after sound is enabled', () async {
      final engine = _FakeTtsEngine();
      TtsService.replaceEngineForTesting(engine);
      final app = AppState();

      app.setSoundEnabled(false);
      await Future<void>.delayed(Duration.zero);
      app.setSoundEnabled(true);
      await TtsService.speak('Rouge', 'fr-FR');

      expect(engine.spokenTexts, ['Rouge']);
    });

    test('sends Kurmanji text with the Kurdish language code to TTS', () async {
      final engine = _FakeTtsEngine();
      TtsService.replaceEngineForTesting(engine);

      await TtsService.speak('Sor', 'ku');

      expect(engine.configuredLanguages, ['ku']);
      expect(engine.spokenTexts, ['Sor']);
    });

    test('cancels a queued speech request when sound is disabled', () async {
      final engine = _BlockingTtsEngine();
      TtsService.replaceEngineForTesting(engine);
      final app = AppState();

      final pendingSpeech = TtsService.speak('Rouge', 'fr-FR');
      await Future<void>.delayed(Duration.zero);
      app.setSoundEnabled(false);
      engine.languageConfigured.complete();
      await pendingSpeech;

      expect(engine.spokenTexts, isEmpty);
      expect(engine.stopCount, greaterThanOrEqualTo(2));
    });
  });

  group('AppState scores', () {
    test('records best score and keeps the highest', () {
      SharedPreferences.setMockInitialValues({});
      final app = AppState();

      final first = app.recordScore(GameIds.quiz, 70, 2);
      expect(first, isTrue);
      expect(app.bestScore(GameIds.quiz), 70);
      expect(app.starsFor(GameIds.quiz), 2);
      expect(app.totalStars, 2);

      final second = app.recordScore(GameIds.quiz, 50, 1);
      expect(second, isFalse);
      expect(app.bestScore(GameIds.quiz), 70);
      expect(app.starsFor(GameIds.quiz), 2);
      expect(app.totalStars, 2);
    });

    test('increases stars but keeps the higher value', () {
      SharedPreferences.setMockInitialValues({});
      final app = AppState();
      app.recordScore(GameIds.memory, 20, 1);
      app.recordScore(GameIds.memory, 40, 3);
      expect(app.starsFor(GameIds.memory), 3);
      expect(app.totalStars, 3);
    });

    test('persists scores across instances', () async {
      SharedPreferences.setMockInitialValues({});
      final app1 = AppState();
      await app1.init();
      app1.recordScore(GameIds.memory, 30, 3);
      app1.recordScore(GameIds.quiz, 100, 3);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final app2 = AppState();
      await app2.init();
      expect(app2.bestScore(GameIds.memory), 30);
      expect(app2.starsFor(GameIds.memory), 3);
      expect(app2.bestScore(GameIds.quiz), 100);
      expect(app2.totalStars, 6);
    });

    test('defaults scores to zero', () {
      SharedPreferences.setMockInitialValues({});
      final app = AppState();
      expect(app.bestScore(GameIds.puzzle), 0);
      expect(app.starsFor(GameIds.puzzle), 0);
      expect(app.starsFor(GameIds.coloring), 0);
      expect(app.totalStars, 0);
    });
  });

  group('starsForScore', () {
    test('returns correct star counts', () {
      expect(AppState.starsForScore(100, 100), 3);
      expect(AppState.starsForScore(70, 100), 2);
      expect(AppState.starsForScore(40, 100), 1);
      expect(AppState.starsForScore(39, 100), 0);
      expect(AppState.starsForScore(0, 100), 0);
    });
  });
}
