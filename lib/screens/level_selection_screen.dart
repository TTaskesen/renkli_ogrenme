import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../widgets/game_widgets.dart';

class LevelSelectionScreen extends StatelessWidget {
  final AppState app;
  final String gameId;
  final Widget Function(int level) gameBuilder;

  const LevelSelectionScreen({
    super.key,
    required this.app,
    required this.gameId,
    required this.gameBuilder,
  });

  String _label(int level) {
    switch (level) {
      case 1:
        return app.t('easy');
      case 2:
        return app.t('medium');
      default:
        return app.t('hard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = app.t(gameId);
    return GameScaffold(
      app: app,
      title: '${app.t('levels')}: $title',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              app.t('choose_level'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            for (var level = 1; level <= 3; level++) ...[
              _LevelCard(
                level: level,
                label: _label(level),
                bestScore: app.bestScoreForLevel(gameId, level),
                stars: app.starsForLevel(gameId, level),
                app: app,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => gameBuilder(level))),
              ),
              if (level < 3) const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final String label;
  final int bestScore;
  final int stars;
  final AppState app;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.label,
    required this.bestScore,
    required this.stars,
    required this.app,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label. ${app.t('best')}: $bestScore',
      child: Material(
        color: const Color(0xFF26A69A),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFFFD54F),
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${app.t('best')}: $bestScore',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                StarsRow(stars: stars, size: 26),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
