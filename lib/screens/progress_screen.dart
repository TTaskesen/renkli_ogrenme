import 'package:flutter/material.dart';

import '../data/colors_data.dart';
import '../models/color_model.dart';
import '../services/app_state.dart';
import '../widgets/game_widgets.dart';
import '../widgets/parent_gate.dart';

class ProgressScreen extends StatelessWidget {
  final AppState app;

  const ProgressScreen({super.key, required this.app});

  Future<void> _reset(BuildContext context) async {
    if (!await ParentGate.request(context, app) || !context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(app.t('reset_progress')),
        content: Text(app.t('reset_progress_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(app.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(app.t('confirm')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await app.resetGameProgress();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(app.t('reset_done'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      app: app,
      title: app.t('progress_summary'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _TotalStars(app: app),
          const SizedBox(height: 16),
          Text(
            app.t('games'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final gameId in AppState.allGameIds)
            _GameProgressCard(app: app, gameId: gameId),
          const SizedBox(height: 18),
          Text(
            app.t('review_colors'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...ColorData.colors.map(
            (color) => _ColorProgressRow(app: app, color: color),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _reset(context),
            icon: const Icon(Icons.delete_outline),
            label: Text(app.t('reset_progress')),
          ),
        ],
      ),
    );
  }
}

class _TotalStars extends StatelessWidget {
  final AppState app;

  const _TotalStars({required this.app});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF3CD),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Color(0xFFF9A825), size: 40),
            const SizedBox(width: 12),
            Text(
              '${app.t('total_stars')}: ${app.totalStars}',
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameProgressCard extends StatelessWidget {
  final AppState app;
  final String gameId;

  const _GameProgressCard({required this.app, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              app.t(gameId),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${app.t('best')}: ${app.bestScore(gameId)}'),
                StarsRow(stars: app.starsFor(gameId), size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [
                for (var level = 1; level <= 3; level++)
                  Chip(
                    label: Text(
                      '${app.t('level')} $level: ${app.starsForLevel(gameId, level)}★',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorProgressRow extends StatelessWidget {
  final AppState app;
  final ColorItem color;

  const _ColorProgressRow({required this.app, required this.color});

  @override
  Widget build(BuildContext context) {
    final attempts = app.colorAttempts(color.id);
    final correct = app.colorCorrect(color.id);
    final status = app.colorStatus(color.id);
    final label = app.t(status);
    if (status != 'review' && attempts == 0) return const SizedBox.shrink();
    return Card(
      child: ListTile(
        leading: Icon(
          status == 'learned' ? Icons.check_circle : Icons.refresh,
          color: status == 'learned' ? Colors.green : Colors.orange,
        ),
        title: Text(color.nameForLanguageCode(app.langCode)),
        subtitle: Text(
          '$label · ${app.t('attempts')}: $attempts · ${app.t('correct_answers')}: $correct',
        ),
      ),
    );
  }
}
