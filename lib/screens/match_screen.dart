import 'dart:math';
import 'package:flutter/material.dart';
import '../data/colors_data.dart';
import '../models/color_model.dart';
import '../services/app_state.dart';
import '../services/tts_service.dart';
import '../widgets/game_widgets.dart';

class MatchScreen extends StatefulWidget {
  final AppState app;

  const MatchScreen({super.key, required this.app});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  static const int _roundColorCount = 4;
  final Random _random = Random();

  late List<ColorItem> _roundColors;
  late List<ColorItem> _options;
  late ColorItem _targetIndex;
  late List<ColorItem> _targets;
  final Set<String> _matchedIds = {};
  int _round = 1;
  int _score = 0;
  int _matches = 0;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    final shuffled = List.of(ColorData.colors)..shuffle(_random);
    _roundColors = shuffled.sublist(0, _roundColorCount);
    _targets = List.of(_roundColors)..shuffle(_random);
    _matches = 0;
    _matchedIds.clear();
    _locked = false;
    _currentTarget();
  }

  void _currentTarget() {
    _targetIndex = _targets[_matches];
    _options = List.of(_roundColors)..shuffle(_random);
    _speak();
  }

  void _speak() {
    final app = widget.app;
    final name = _targetIndex.nameForLanguageCode(app.langCode);
    TtsService.speak(name, app.langCode);
  }

  void _select(ColorItem selected) {
    if (_locked) return;
    setState(() {
      if (selected.id == _targetIndex.id) {
        _score += 10;
        _matches++;
        _matchedIds.add(selected.id);
        if (_matches == _roundColorCount) {
          _locked = true;
          if (_round < 3) {
            TtsService.speak(widget.app.t('great'), widget.app.langCode);
            Future.delayed(const Duration(milliseconds: 900), () {
              if (mounted) {
                setState(() {
                  _round++;
                  _startRound();
                });
              }
            });
          } else {
            _showDone();
          }
        } else {
          _currentTarget();
        }
      } else {
        TtsService.speak(widget.app.t('wrong'), widget.app.langCode);
      }
    });
  }

  void _showDone() {
    final app = widget.app;
    TtsService.speak(app.t('great'), app.langCode);
    final maxScore = 3 * _roundColorCount * 10;
    final stars = AppState.starsForScore(_score, maxScore);
    final isRecord = app.recordScore(GameIds.match, _score, stars);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DoneDialog(
        app: app,
        score: _score,
        stars: stars,
        isRecord: isRecord,
        onRestart: () {
          Navigator.of(ctx).pop();
          setState(() {
            _round = 1;
            _score = 0;
            _startRound();
          });
        },
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
    return GameScaffold(
      app: app,
      title: app.t('match'),
      score: _score,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${app.t('level')} $_round',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 16),
            _TargetCard(color: _targetIndex.color, app: app, onTap: _speak),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: List.generate(_options.length, (i) {
                  final c = _options[i];
                  final matched = _matchedIds.contains(c.id);
                  return _OptionCard(
                    color: c.color,
                    matched: matched,
                    onTap: matched ? null : () => _select(c),
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

class _TargetCard extends StatelessWidget {
  final Color color;
  final AppState app;
  final VoidCallback onTap;

  const _TargetCard({
    required this.color,
    required this.app,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 110,
            width: 140,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
              border: color.computeLuminance() > 0.9
                  ? Border.all(color: Colors.black26)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.question_mark,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          app.t('pairs'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF37474F),
          ),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final Color color;
  final bool matched;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.color,
    required this.matched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: color.computeLuminance() > 0.9
            ? Border.all(color: Colors.black26)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: matched
              ? const Icon(Icons.check_circle, size: 48, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _DoneDialog extends StatelessWidget {
  final AppState app;
  final int score;
  final int stars;
  final bool isRecord;
  final VoidCallback onRestart;

  const _DoneDialog({
    required this.app,
    required this.score,
    required this.stars,
    required this.isRecord,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        app.t('congrats'),
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, size: 72, color: Color(0xFFFFD54F)),
          const SizedBox(height: 12),
          StarsRow(stars: stars),
          const SizedBox(height: 12),
          Text(
            '${app.t('score')}: $score',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${app.t('best')}: ${app.bestScore(GameIds.match)}',
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
          color: const Color(0xFF26A69A),
          onTap: onRestart,
        ),
        const SizedBox(width: 12),
        RoundButton(
          label: app.t('menu'),
          icon: Icons.home,
          color: const Color(0xFF8E24AA),
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }
}
