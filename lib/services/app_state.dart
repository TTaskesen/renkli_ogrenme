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
  static const mixing = 'mixing';
}

class AppState extends ChangeNotifier {
  static const appVersion = '1.2.0';
  AppLanguage _language = AppLanguage.tr;
  bool _soundEnabled = true;
  bool _largeText = false;
  bool _highContrast = false;
  bool _showColorNames = true;
  bool _shapeHints = true;

  final Map<String, int> _bestScores = {};
  final Map<String, int> _stars = {};

  static const _languageKey = 'app_language';
  static const _soundKey = 'sound_enabled';
  static const _largeTextKey = 'accessibility_large_text';
  static const _highContrastKey = 'accessibility_high_contrast';
  static const _showColorNamesKey = 'accessibility_color_names';
  static const _shapeHintsKey = 'accessibility_shape_hints';
  static const _bestPrefix = 'best_score_';
  static const _starsPrefix = 'stars_';
  static const _levelBestPrefix = 'best_score_level_';
  static const _levelStarsPrefix = 'stars_level_';
  static const _colorAttemptsPrefix = 'color_attempts_';
  static const _colorCorrectPrefix = 'color_correct_';

  static const allGameIds = [
    GameIds.quiz,
    GameIds.match,
    GameIds.memory,
    GameIds.puzzle,
    GameIds.coloring,
    GameIds.mixing,
  ];

  AppLanguage get language => _language;

  bool get soundEnabled => _soundEnabled;

  bool get largeText => _largeText;

  bool get highContrast => _highContrast;

  bool get showColorNames => _showColorNames;

  bool get shapeHints => _shapeHints;

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

  int get totalStars => allGameIds.fold(
    0,
    (total, gameId) =>
        total +
        [1, 2, 3].fold(0, (sum, level) => sum + starsForLevel(gameId, level)),
  );

  int bestScore(String gameId) => _bestScores[gameId] ?? 0;

  int starsFor(String gameId) => _stars[gameId] ?? 0;

  int bestScoreForLevel(String gameId, int level) =>
      _bestScores['${gameId}_level_$level'] ??
      (!_hasLevelData(gameId) && level == 1 ? bestScore(gameId) : 0);

  int starsForLevel(String gameId, int level) =>
      _stars['${gameId}_level_$level'] ??
      (!_hasLevelData(gameId) && level == 1 ? starsFor(gameId) : 0);

  bool _hasLevelData(String gameId) =>
      _bestScores.keys.any((key) => key.startsWith('${gameId}_level_')) ||
      _stars.keys.any((key) => key.startsWith('${gameId}_level_'));

  int colorAttempts(String colorId) => _colorAttempts[colorId] ?? 0;

  int colorCorrect(String colorId) => _colorCorrect[colorId] ?? 0;

  String colorStatus(String colorId) {
    final attempts = colorAttempts(colorId);
    if (attempts < 3) return 'developing';
    final ratio = colorCorrect(colorId) / attempts;
    if (ratio < 0.7) return 'review';
    if (ratio >= 0.8) return 'learned';
    return 'developing';
  }

  final Map<String, int> _colorAttempts = {};
  final Map<String, int> _colorCorrect = {};

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
    _largeText = prefs.getBool(_largeTextKey) ?? false;
    _highContrast = prefs.getBool(_highContrastKey) ?? false;
    _showColorNames = prefs.getBool(_showColorNamesKey) ?? true;
    _shapeHints = prefs.getBool(_shapeHintsKey) ?? true;
    TtsService.enabled = _soundEnabled;
    for (final id in allGameIds) {
      _bestScores[id] = prefs.getInt('$_bestPrefix$id') ?? 0;
      _stars[id] = prefs.getInt('$_starsPrefix$id') ?? 0;
      for (var level = 1; level <= 3; level++) {
        final best = prefs.getInt('$_levelBestPrefix${id}_$level');
        final stars = prefs.getInt('$_levelStarsPrefix${id}_$level');
        if (best != null) _bestScores['${id}_level_$level'] = best;
        if (stars != null) _stars['${id}_level_$level'] = stars;
      }
    }
    for (final color in _colorIds) {
      _colorAttempts[color] = prefs.getInt('$_colorAttemptsPrefix$color') ?? 0;
      _colorCorrect[color] = prefs.getInt('$_colorCorrectPrefix$color') ?? 0;
    }
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    _language = lang;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_languageKey, _language.name);
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

  void setLargeText(bool value) {
    _largeText = value;
    notifyListeners();
    _persistBool(_largeTextKey, value);
  }

  void setHighContrast(bool value) {
    _highContrast = value;
    notifyListeners();
    _persistBool(_highContrastKey, value);
  }

  void setShowColorNames(bool value) {
    _showColorNames = value;
    notifyListeners();
    _persistBool(_showColorNamesKey, value);
  }

  void setShapeHints(bool value) {
    _shapeHints = value;
    notifyListeners();
    _persistBool(_shapeHintsKey, value);
  }

  bool recordScore(String gameId, int score, int stars, {int level = 1}) {
    if (level > 1 && !_hasLevelData(gameId)) {
      _bestScores['${gameId}_level_1'] = bestScore(gameId);
      _stars['${gameId}_level_1'] = starsFor(gameId);
    }
    final isRecord = score > (_bestScores[gameId] ?? 0);
    if (isRecord) _bestScores[gameId] = score;
    if (stars > (_stars[gameId] ?? 0)) _stars[gameId] = stars;
    final levelKey = '${gameId}_level_$level';
    if (score > (_bestScores[levelKey] ?? 0)) _bestScores[levelKey] = score;
    if (stars > (_stars[levelKey] ?? 0)) _stars[levelKey] = stars;
    notifyListeners();
    _persistScore(gameId, level);
    if (level > 1) _persistScore(gameId, 1);
    return isRecord;
  }

  void recordColorAttempt(String colorId, bool correct) {
    _colorAttempts[colorId] = colorAttempts(colorId) + 1;
    if (correct) _colorCorrect[colorId] = colorCorrect(colorId) + 1;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('$_colorAttemptsPrefix$colorId', colorAttempts(colorId));
      prefs.setInt('$_colorCorrectPrefix$colorId', colorCorrect(colorId));
    });
  }

  Future<void> resetGameProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (final id in allGameIds) {
      _bestScores.remove(id);
      _stars.remove(id);
      await prefs.remove('$_bestPrefix$id');
      await prefs.remove('$_starsPrefix$id');
      for (var level = 1; level <= 3; level++) {
        _bestScores.remove('${id}_level_$level');
        _stars.remove('${id}_level_$level');
        await prefs.remove('$_levelBestPrefix${id}_$level');
        await prefs.remove('$_levelStarsPrefix${id}_$level');
      }
    }
    for (final color in _colorIds) {
      _colorAttempts[color] = 0;
      _colorCorrect[color] = 0;
      await prefs.remove('$_colorAttemptsPrefix$color');
      await prefs.remove('$_colorCorrectPrefix$color');
    }
    notifyListeners();
  }

  void _persistBool(String key, bool value) {
    SharedPreferences.getInstance().then((prefs) => prefs.setBool(key, value));
  }

  void _persistScore(String gameId, int level) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('$_bestPrefix$gameId', _bestScores[gameId] ?? 0);
      prefs.setInt('$_starsPrefix$gameId', _stars[gameId] ?? 0);
      final levelKey = '${gameId}_level_$level';
      prefs.setInt(
        '$_levelBestPrefix${gameId}_$level',
        _bestScores[levelKey] ?? 0,
      );
      prefs.setInt('$_levelStarsPrefix${gameId}_$level', _stars[levelKey] ?? 0);
    });
  }

  static const _colorIds = [
    'red',
    'orange',
    'yellow',
    'green',
    'blue',
    'purple',
    'pink',
    'brown',
    'black',
    'white',
    'gray',
    'sky',
  ];

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
