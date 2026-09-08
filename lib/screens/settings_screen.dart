import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/tts_service.dart';
import '../widgets/game_widgets.dart';

class SettingsScreen extends StatelessWidget {
  final AppState app;

  const SettingsScreen({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      app: app,
      title: app.t('settings'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            app.t('settings_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: app.highContrast ? Colors.black : const Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 20),
          _SettingSwitch(
            title: app.t('sound'),
            value: app.soundEnabled,
            icon: Icons.volume_up,
            onChanged: app.setSoundEnabled,
          ),
          _SettingSwitch(
            title: app.t('large_text'),
            value: app.largeText,
            icon: Icons.format_size,
            onChanged: app.setLargeText,
          ),
          _SettingSwitch(
            title: app.t('high_contrast'),
            value: app.highContrast,
            icon: Icons.contrast,
            onChanged: app.setHighContrast,
          ),
          _SettingSwitch(
            title: app.t('show_color_names'),
            value: app.showColorNames,
            icon: Icons.label_outline,
            onChanged: app.setShowColorNames,
          ),
          _SettingSwitch(
            title: app.t('shape_hints'),
            value: app.shapeHints,
            icon: Icons.category_outlined,
            onChanged: app.setShapeHints,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: app.soundEnabled
                ? () => TtsService.speak(app.t('repeat_sound'), app.langCode)
                : null,
            icon: const Icon(Icons.volume_up),
            label: Text(app.t('repeat_sound')),
          ),
        ],
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.title,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile.adaptive(
        secondary: Icon(icon),
        title: Text(title),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
