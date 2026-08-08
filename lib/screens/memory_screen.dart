import 'dart:math';
import 'package:flutter/material.dart';
import '../data/colors_data.dart';
import '../models/color_model.dart';
import '../services/app_state.dart';
import '../widgets/game_widgets.dart';

class MemoryScreen extends StatefulWidget {
  final AppState app;

  const MemoryScreen({super.key, required this.app});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  static const int _pairCount = 8;
  final Random _random = Random();

  late List<ColorItem> _deck;
  late List<int> _indices;
  late List<bool> _flipped;
  late List<bool> _matched;

  int? _firstIndex;
  bool _busy = false;
  int _score = 0;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    _deck = (List.of(ColorData.colors)..shuffle(_random)).sublist(0, _pairCount);
    _indices = [];
    for (var i = 0; i < _deck.length; i++) {
      _indices.addAll([i, i]);
    }
    _indices.shuffle(_random);
    _flipped = List.filled(_indices.length, false);
    _matched = List.filled(_indices.length, false);
    _firstIndex = null;
    _busy = false;
    _moves = 0;
  }

  void _flip(int i) {
    if (_busy || _flipped[i] || _matched[i]) return;
    setState(() {
      _flipped[i] = true;
      _moves++;
    });

    if (_firstIndex == null) {
      _firstIndex = i;
      return;
    }

    final a = _firstIndex!;
    _firstIndex = null;

    if (_indices[a] == _indices[i]) {
      setState(() {
        _matched[a] = true;
        _matched[i] = true;
        _score += 5;
      });
      if (_matched.every((m) => m)) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _showDone();
        });
      }
    } else {
      _busy = true;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() {
            _flipped[a] = false;
            _flipped[i] = false;
            _busy = false;
          });
        }
      });
    }
  }

  void _showDone() {
    final app = widget.app;
    final stars = AppState.starsForScore(_score, _pairCount * 5);
    final isRecord = app.recordScore(GameIds.memory, _score, stars);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _MemoryDoneDialog(
        app: app,
        score: _score,
        moves: _moves,
        stars: stars,
        isRecord: isRecord,
        onRestart: () {
          Navigator.of(ctx).pop();
          setState(_shuffle);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return GameScaffold(
      app: app,
      title: app.t('memory'),
      score: _score,
      body: Column(
        children: [
          Text(
            '${app.t('moves')}: $_moves',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: List.generate(_indices.length, (i) {
                  return _MemoryCard(
                    key: ValueKey('memory_card_$i'),
                    color: _deck[_indices[i]].color,
                    flipped: _flipped[i] || _matched[i],
                    matched: _matched[i],
                    onTap: () => _flip(i),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final Color color;
  final bool flipped;
  final bool matched;
  final VoidCallback onTap;

  const _MemoryCard({
    super.key,
    required this.color,
    required this.flipped,
    required this.matched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: flipped
            ? Container(
                key: ValueKey('back_$color'),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: color.computeLuminance() > 0.9
                      ? Border.all(color: Colors.black26)
                      : null,
                ),
                child: matched
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
              )
            : Container(
                key: const ValueKey('front'),
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF26A69A).withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star,
                  color: Color(0xFFFFD54F),
                  size: 28,
                ),
              ),
      ),
    );
  }
}

class _MemoryDoneDialog extends StatelessWidget {
  final AppState app;
  final int score;
  final int moves;
  final int stars;
  final bool isRecord;
  final VoidCallback onRestart;

  const _MemoryDoneDialog({
    required this.app,
    required this.score,
    required this.moves,
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
          const Icon(Icons.stars, size: 72, color: Color(0xFFFFD54F)),
          const SizedBox(height: 12),
          StarsRow(stars: stars),
          const SizedBox(height: 12),
          Text(
            '${app.t('score')}: $score   ${app.t('moves')}: $moves',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${app.t('best')}: ${app.bestScore(GameIds.memory)}',
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
