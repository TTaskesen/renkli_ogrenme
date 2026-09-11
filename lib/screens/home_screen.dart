import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../widgets/stars_pill.dart';
import 'learn_screen.dart';
import 'match_screen.dart';
import 'memory_screen.dart';
import 'coloring_screen.dart';
import 'puzzle_screen.dart';
import 'quiz_screen.dart';
import 'mixing_screen.dart';
import 'level_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppState app;

  const HomeScreen({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF6A1B9A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      app.t('games'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Icon(
                  Icons.palette,
                  size: 56,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 12),
                Text(
                  app.t('app_name'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  app.t('app_tagline'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 16),
                StarsPill(app: app),
                const SizedBox(height: 32),
                _MenuGrid(app: app),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  final AppState app;

  const _MenuGrid({required this.app});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem(app.t('learn'), Icons.palette, const Color(0xFFE53935), () {
        _open(context, LearnScreen(app: app));
      }),
      _MenuItem(
        app.t('match'),
        Icons.compare_arrows,
        const Color(0xFFFB8C00),
        () {
          _openLevels(
            context,
            GameIds.match,
            (level) => MatchScreen(app: app, level: level),
          );
        },
      ),
      _MenuItem(app.t('memory'), Icons.psychology, const Color(0xFF43A047), () {
        _openLevels(
          context,
          GameIds.memory,
          (level) => MemoryScreen(app: app, level: level),
        );
      }),
      _MenuItem(app.t('coloring'), Icons.brush, const Color(0xFF1E88E5), () {
        _openLevels(
          context,
          GameIds.coloring,
          (level) => ColoringScreen(app: app, level: level),
        );
      }),
      _MenuItem(app.t('puzzle'), Icons.extension, const Color(0xFF8E24AA), () {
        _openLevels(
          context,
          GameIds.puzzle,
          (level) => PuzzleScreen(app: app, level: level),
        );
      }),
      _MenuItem(app.t('quiz'), Icons.quiz, const Color(0xFF00897B), () {
        _openLevels(
          context,
          GameIds.quiz,
          (level) => QuizScreen(app: app, level: level),
        );
      }),
      _MenuItem(app.t('mixing'), Icons.blender, const Color(0xFFD81B60), () {
        _openLevels(
          context,
          GameIds.mixing,
          (level) => MixingScreen(app: app, level: level),
        );
      }),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: List.generate(items.length, (i) => items[i].build(context)),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _openLevels(
    BuildContext context,
    String gameId,
    Widget Function(int level) builder,
  ) {
    _open(
      context,
      LevelSelectionScreen(app: app, gameId: gameId, gameBuilder: builder),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem(this.label, this.icon, this.color, this.onTap);

  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
