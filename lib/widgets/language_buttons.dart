import 'package:flutter/material.dart';
import '../services/app_state.dart';

class LanguageButtons extends StatelessWidget {
  final AppState app;

  const LanguageButtons({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      children: [
        _LanguageButton(
          selected: app.language == AppLanguage.tr,
          label: 'TR',
          onTap: () => app.setLanguage(AppLanguage.tr),
        ),
        _LanguageButton(
          selected: app.language == AppLanguage.en,
          label: 'EN',
          onTap: () => app.setLanguage(AppLanguage.en),
        ),
        _LanguageButton(
          selected: app.language == AppLanguage.fr,
          label: 'FR',
          onTap: () => app.setLanguage(AppLanguage.fr),
        ),
        _LanguageButton(
          selected: app.language == AppLanguage.ku,
          label: 'KU',
          onTap: () => app.setLanguage(AppLanguage.ku),
        ),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFD54F) : Colors.white24,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
