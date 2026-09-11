import 'dart:math';

import 'package:flutter/material.dart';

import '../data/colors_data.dart';
import '../models/color_model.dart';
import '../services/app_state.dart';
import '../services/tts_service.dart';
import '../widgets/game_widgets.dart';

class MixingScreen extends StatefulWidget {
  final AppState app;
  final int level;

  const MixingScreen({super.key, required this.app, this.level = 1});

  @override
  State<MixingScreen> createState() => _MixingScreenState();
}

class _MixingScreenState extends State<MixingScreen> {
  final Random _random = Random();

  static const _pairs = [
    _MixPair('red', 'yellow', 'orange'),
    _MixPair('yellow', 'blue', 'green'),
    _MixPair('blue', 'red', 'purple'),
  ];

  int get _roundCount => widget.level * 3;
  int get _optionCount => widget.level + 2;

  late List<_MixChallenge> _challenges;
  int _current = 0;
  int _score = 0;
  String? _selectedId;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _buildChallenges();
  }

  ColorItem _color(String id) =>
      ColorData.colors.firstWhere((color) => color.id == id);

  void _buildChallenges() {
    final order = List.of(_pairs)..shuffle(_random);
    final secondary = ['orange', 'green', 'purple', 'pink', 'brown', 'sky'];
    _challenges = List.generate(_roundCount, (index) {
      final pair = order[index % order.length];
      final target = _color(pair.resultId);
      final distractors =
          <ColorItem>[
              ...secondary.map(_color),
              ...ColorData.colors,
            ].where((color) => color.id != target.id).toSet().toList()
            ..shuffle(_random);
      final options = <ColorItem>[target, ...distractors.take(_optionCount - 1)]
        ..shuffle(_random);
      return _MixChallenge(pair: pair, options: options);
    });
    _current = 0;
    _score = 0;
    _selectedId = null;
    _answered = false;
    _speakChallenge();
  }

  void _speakChallenge() {
    final challenge = _challenges[_current];
    final app = widget.app;
    final first = _color(
      challenge.pair.firstId,
    ).nameForLanguageCode(app.langCode);
    final second = _color(
      challenge.pair.secondId,
    ).nameForLanguageCode(app.langCode);
    TtsService.speak('$first + $second', app.langCode);
  }

  void _select(ColorItem selected) {
    if (_answered) return;
    final challenge = _challenges[_current];
    final correct = selected.id == challenge.pair.resultId;
    setState(() {
      _answered = true;
      _selectedId = selected.id;
      if (correct) _score += 10;
    });
    widget.app.recordColorAttempt(challenge.pair.resultId, correct);
    TtsService.speak(
      correct ? widget.app.t('correct') : widget.app.t('wrong'),
      widget.app.langCode,
    );
    Future.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      if (_current < _challenges.length - 1) {
        setState(() {
          _current++;
          _selectedId = null;
          _answered = false;
        });
        _speakChallenge();
      } else {
        _showDone();
      }
    });
  }

  void _showDone() {
    final app = widget.app;
    final maxScore = _roundCount * 10;
    final stars = AppState.starsForScore(_score, maxScore);
    final isRecord = app.recordScore(
      GameIds.mixing,
      _score,
      stars,
      level: widget.level,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          app.t('congrats'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.blender, size: 72, color: Color(0xFFD81B60)),
            const SizedBox(height: 12),
            StarsRow(stars: stars),
            const SizedBox(height: 12),
            Text(
              '${app.t('score')}: $_score / $maxScore',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${app.t('best')}: ${app.bestScore(GameIds.mixing)}',
              style: const TextStyle(fontSize: 16, color: Color(0xFF546E7A)),
            ),
            if (isRecord) ...[
              const SizedBox(height: 4),
              Text(
                app.t('new_record'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF9A825),
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          RoundButton(
            label: app.t('restart'),
            icon: Icons.replay,
            color: const Color(0xFFD81B60),
            onTap: () {
              Navigator.of(ctx).pop();
              setState(_buildChallenges);
            },
          ),
          const SizedBox(width: 12),
          RoundButton(
            label: app.t('menu'),
            icon: Icons.home,
            color: const Color(0xFF8E24AA),
            onTap: () => Navigator.of(ctx).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final challenge = _challenges[_current];
    final first = _color(challenge.pair.firstId);
    final second = _color(challenge.pair.secondId);
    final firstName = first.nameForLanguageCode(app.langCode);
    final secondName = second.nameForLanguageCode(app.langCode);

    return GameScaffold(
      app: app,
      title: app.t('mixing'),
      score: _score,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${app.t('level')} ${_current + 1} / $_roundCount',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              app.t('mix_instruction'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, color: Color(0xFF455A64)),
            ),
            const SizedBox(height: 16),
            _MixFormula(
              first: first.color,
              second: second.color,
              label: app.showColorNames
                  ? '$firstName + $secondName = ?'
                  : '? + ? = ?',
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: List.generate(challenge.options.length, (index) {
                  final color = challenge.options[index];
                  final selected = _selectedId == color.id;
                  final isCorrect = color.id == challenge.pair.resultId;
                  return _MixOption(
                    key: ValueKey('mixing_option_$index'),
                    color: color,
                    label: app.showColorNames
                        ? color.nameForLanguageCode(app.langCode)
                        : null,
                    languageCode: app.langCode,
                    selected: selected,
                    answered: _answered,
                    correct: isCorrect,
                    onTap: () => _select(color),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MixPair {
  final String firstId;
  final String secondId;
  final String resultId;

  const _MixPair(this.firstId, this.secondId, this.resultId);
}

class _MixChallenge {
  final _MixPair pair;
  final List<ColorItem> options;

  const _MixChallenge({required this.pair, required this.options});
}

class _MixFormula extends StatelessWidget {
  final Color first;
  final Color second;
  final String label;

  const _MixFormula({
    required this.first,
    required this.second,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 112,
          width: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(left: 24, child: _Circle(color: first)),
              Positioned(right: 24, child: _Circle(color: second)),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '+',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final Color color;

  const _Circle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: color.computeLuminance() > 0.9
            ? Border.all(color: Colors.black26, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _MixOption extends StatelessWidget {
  final ColorItem color;
  final String? label;
  final String languageCode;
  final bool selected;
  final bool answered;
  final bool correct;
  final VoidCallback onTap;

  const _MixOption({
    super.key,
    required this.color,
    required this.label,
    required this.languageCode,
    required this.selected,
    required this.answered,
    required this.correct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resultIcon = answered && correct
        ? const Icon(Icons.check_circle, color: Colors.white, size: 38)
        : answered && selected
        ? const Icon(Icons.cancel, color: Colors.white, size: 38)
        : null;
    return Semantics(
      button: true,
      label: label ?? color.nameForLanguageCode(languageCode),
      child: Material(
        color: color.color,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: answered ? null : onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: color.color.computeLuminance() > 0.9
                  ? Border.all(color: Colors.black26, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ?resultIcon,
                if (label != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    label!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color.color.computeLuminance() > 0.55
                          ? Colors.black87
                          : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
