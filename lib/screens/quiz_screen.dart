import 'dart:math';
import 'package:flutter/material.dart';
import '../data/colors_data.dart';
import '../models/color_model.dart';
import '../services/app_state.dart';
import '../services/tts_service.dart';
import '../widgets/game_widgets.dart';

class QuizScreen extends StatefulWidget {
  final AppState app;

  const QuizScreen({super.key, required this.app});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int _questionCount = 10;
  static const int _optionCount = 4;
  final Random _random = Random();

  late List<_Question> _questions;
  int _current = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _buildQuestions();
  }

  void _buildQuestions() {
    _questions = [];
    final pool = List.of(ColorData.colors);
    for (var i = 0; i < _questionCount; i++) {
      pool.shuffle(_random);
      final target = pool[i % pool.length];
      final others = pool.where((c) => c.id != target.id).toList()..shuffle(_random);
      final options = [target, ...others.take(_optionCount - 1)]..shuffle(_random);
      _questions.add(_Question(target: target, options: options));
    }
    _current = 0;
    _score = 0;
    _selected = null;
    _answered = false;
  }

  void _answer(int index) {
    if (_answered) return;
    final correct = _questions[_current].options[index].id ==
        _questions[_current].target.id;
    setState(() {
      _answered = true;
      _selected = index;
      if (correct) _score += 10;
    });
    final app = widget.app;
    TtsService.speak(
      correct ? app.t('correct') : app.t('wrong'),
      app.langCode,
    );
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        if (_current < _questionCount - 1) {
          _current++;
          _selected = null;
          _answered = false;
        } else {
          _showDone();
        }
      });
    });
  }

  void _showDone() {
    final app = widget.app;
    final stars = AppState.starsForScore(_score, _questionCount * 10);
    final isRecord = app.recordScore(GameIds.quiz, _score, stars);
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
            Icon(
              _score == _questionCount * 10
                  ? Icons.military_tech
                  : Icons.emoji_events,
              size: 72,
              color: const Color(0xFFFFD54F),
            ),
            const SizedBox(height: 12),
            StarsRow(stars: stars),
            const SizedBox(height: 12),
            Text(
              '${app.t('score')}: $_score / ${_questionCount * 10}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${app.t('best')}: ${app.bestScore(GameIds.quiz)}',
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
            color: const Color(0xFF00897B),
            onTap: () {
              Navigator.of(ctx).pop();
              if (mounted) setState(_buildQuestions);
            },
          ),
          const SizedBox(width: 12),
          RoundButton(
            label: app.t('menu'),
            icon: Icons.home,
            color: const Color(0xFF8E24AA),
            onTap: () {
              Navigator.of(ctx).popUntil((route) => route.isFirst);
            },
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
    final q = _questions[_current];
    final name = app.language == AppLanguage.tr ? q.target.nameTr : q.target.nameEn;

    return GameScaffold(
      app: app,
      title: app.t('quiz'),
      score: _score,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${app.t('level')} ${_current + 1}/$_questionCount',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => TtsService.speak(name, app.langCode),
              child: Container(
                height: 140,
                width: 180,
                decoration: BoxDecoration(
                  color: q.target.color,
                  borderRadius: BorderRadius.circular(28),
                  border: q.target.color.computeLuminance() > 0.9
                      ? Border.all(color: Colors.black26)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: q.target.color.withValues(alpha: 0.6),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.volume_up,
                  size: 52,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              app.t('what_color'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: List.generate(q.options.length, (i) {
                  final opt = q.options[i];
                  return _Option(
                    key: ValueKey('quiz_option_$i'),
                    text: app.language == AppLanguage.tr ? opt.nameTr : opt.nameEn,
                    color: opt.color,
                    state: _optionState(i),
                    onTap: () => _answer(i),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _OptionState _optionState(int index) {
    if (!_answered) return _OptionState.none;
    final correct = _questions[_current].options[index].id ==
        _questions[_current].target.id;
    if (correct) return _OptionState.correct;
    if (index == _selected) return _OptionState.wrong;
    return _OptionState.none;
  }
}

enum _OptionState { none, correct, wrong }

class _Option extends StatelessWidget {
  final String text;
  final Color color;
  final _OptionState state;
  final VoidCallback onTap;

  const _Option({
    super.key,
    required this.text,
    required this.color,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = color.computeLuminance() < 0.5;
    Color borderColor = Colors.transparent;
    IconData? icon;
    if (state == _OptionState.correct) {
      borderColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle;
    } else if (state == _OptionState.wrong) {
      borderColor = const Color(0xFFC62828);
      icon = Icons.cancel;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: state == _OptionState.none
              ? Border.all(color: Colors.black12, width: 2)
              : Border.all(color: borderColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 44, color: isDark ? Colors.white : Colors.black87)
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
        ),
      ),
    );
  }
}

class _Question {
  final ColorItem target;
  final List<ColorItem> options;

  _Question({required this.target, required this.options});
}
