import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/translations.dart';
import 'tts_service.dart';

enum AppLanguage { tr, en, fr, ku }

abstract class GameIds {
  static const quiz = 'quiz';
  static const match = 'match';
  static const memory = 'memory';
  static const puzzle = 'puzzle';
  static const coloring = 'coloring';
}

class AppState extends ChangeNotifier {
  AppLanguage _language = AppLanguage.tr;
  bool _soundEnabled = true;

  final Map<String, int> _bestScores = {};
  final Map<String, int> _stars = {};

  static const _languageKey = 'app_language';
  static const _soundKey = 'sound_enabled';
  static const _bestPrefix = 'best_score_';
  static const _starsPrefix = 'stars_';

  static const allGameIds = [
    GameIds.quiz,
    GameIds.match,
    GameIds.memory,
    GameIds.puzzle,
    GameIds.coloring,
  ];

  AppLanguage get language => _language;

  bool get soundEnabled => _soundEnabled;

  String get langCode {
    switch (_language) {
      case AppLanguage.tr:
        return 'tr-TR';
      case AppLanguage.en:
        return 'en-US';
      case AppLanguage.fr:
        return 'fr-FR';
      case AppLanguage.ku:
        return 'ku';
    }
  }

  int get totalStars => _stars.values.fold(0, (a, b) => a + b);

  int bestScore(String gameId) => _bestScores[gameId] ?? 0;

  int starsFor(String gameId) => _stars[gameId] ?? 0;

  static int starsForScore(int score, int maxScore) {
    if (score >= maxScore) return 3;
    if (score >= (maxScore * 0.7).round()) return 2;
    if (score >= (maxScore * 0.4).round()) return 1;
    return 0;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final langName = prefs.getString(_languageKey);
    final saved = langName != null
        ? AppLanguage.values.asNameMap()[langName]
        : null;
    if (saved != null) {
      _language = saved;
    }
    _soundEnabled = prefs.getBool(_soundKey) ?? true;
    TtsService.enabled = _soundEnabled;
    for (final id in allGameIds) {
      _bestScores[id] = prefs.getInt('$_bestPrefix$id') ?? 0;
      _stars[id] = prefs.getInt('$_starsPrefix$id') ?? 0;
    }
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    _language = lang;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_languageKey, lang.name);
    });
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    TtsService.setEnabled(value);
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_soundKey, value);
    });
  }

  bool recordScore(String gameId, int score, int stars) {
    final isRecord = score > (_bestScores[gameId] ?? 0);
    if (isRecord) _bestScores[gameId] = score;
    if (stars > (_stars[gameId] ?? 0)) _stars[gameId] = stars;
    notifyListeners();
    _persistScore(gameId);
    return isRecord;
  }

  void _persistScore(String gameId) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('$_bestPrefix$gameId', _bestScores[gameId] ?? 0);
      prefs.setInt('$_starsPrefix$gameId', _stars[gameId] ?? 0);
    });
  }

  String t(String key) {
    switch (_language) {
      case AppLanguage.tr:
        return Strings.tr[key] ?? Strings.en[key] ?? key;
      case AppLanguage.en:
        return Strings.en[key] ?? Strings.tr[key] ?? key;
      case AppLanguage.fr:
        return Strings.fr[key] ?? Strings.en[key] ?? key;
      case AppLanguage.ku:
        return Strings.ku[key] ?? Strings.en[key] ?? key;
    }
  }
}
