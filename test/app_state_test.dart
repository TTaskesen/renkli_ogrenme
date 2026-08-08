import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:renkli_ogrenme/services/app_state.dart';

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
