import 'package:flutter/material.dart';
import '../services/app_state.dart';

class PrivacyScreen extends StatelessWidget {
  final AppState app;

  const PrivacyScreen({super.key, required this.app});

  static const _sections = {
    'tr': {
      'title': 'Gizlilik Politikası',
      'intro':
          'Renkli Öğrenme, çocukların renkleri eğlenceli oyunlarla öğrenmesi için tasarlanmıştır.',
      'data':
          'Bu uygulama hiçbir kişisel veri toplamaz, saklamaz veya üçüncü taraflarla paylaşmaz.',
      'local':
          'Oyun ilerlemeniz, yıldızlarınız ve dil/ ses tercihleriniz yalnızca cihazınızda yerel olarak saklanır.',
      'ads': 'Uygulama reklam, çerez veya izleyici kullanmaz.',
      'contact': 'Sorularınız için geliştiriciyle iletişime geçebilirsiniz.',
    },
    'en': {
      'title': 'Privacy Policy',
      'intro':
          'Colorful Learning is designed to help children learn colors through fun games.',
      'data':
          'This app does not collect, store, or share any personal data with third parties.',
      'local':
          'Your game progress, stars, and language/sound preferences are stored locally only on your device.',
      'ads': 'The app uses no ads, cookies, or trackers.',
      'contact': 'You can contact the developer with any questions.',
    },
    'fr': {
      'title': 'Politique de confidentialité',
      'intro':
          'Apprentissage Coloré est conçu pour aider les enfants à apprendre les couleurs par le jeu.',
      'data':
          'Cette application ne collecte, ne stocke ni ne partage aucune donnée personnelle avec des tiers.',
      'local':
          'Votre progression, vos étoiles et vos préférences de langue/son sont stockées uniquement sur votre appareil.',
      'ads': 'L\'application n\'utilise ni publicité, ni cookies, ni traceurs.',
      'contact': 'Vous pouvez contacter le développeur pour toute question.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final s = _sections[app.language.name] ?? _sections['en']!;
    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(s['title']!),
      ),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s['title']!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                for (final key in ['intro', 'data', 'local', 'ads', 'contact'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      s[key]!,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
