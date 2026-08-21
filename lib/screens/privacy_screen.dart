import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_state.dart';

class PrivacyScreen extends StatelessWidget {
  final AppState app;

  static const _supportEmail = 'turguttaskesen@gmail.com';
  static const _privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue:
        'https://ttaskesen.github.io/renkli_ogrenme/privacy-policy.html',
  );

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
      'contact':
          'Sorularınız ve geri bildirimleriniz için bize ulaşabilirsiniz.',
      'contact_action': 'E-posta gönder',
      'contact_error': 'E-posta uygulaması açılamadı.',
      'contact_body': 'Renkli Öğrenme hakkında destek isteği:',
      'public_policy_action': 'Web gizlilik politikasını aç',
      'public_policy_error': 'Gizlilik politikası açılamadı.',
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
      'contact': 'Contact us with your questions and feedback.',
      'contact_action': 'Send email',
      'contact_error': 'Could not open an email app.',
      'contact_body': 'Support request about Colorful Learning:',
      'public_policy_action': 'Open the online privacy policy',
      'public_policy_error': 'Could not open the privacy policy.',
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
      'contact': 'Contactez-nous pour vos questions et vos commentaires.',
      'contact_action': 'Envoyer un e-mail',
      'contact_error': 'Impossible d’ouvrir une application e-mail.',
      'contact_body': 'Demande d’assistance concernant Apprentissage Coloré :',
      'public_policy_action': 'Ouvrir la politique en ligne',
      'public_policy_error':
          'Impossible d’ouvrir la politique de confidentialité.',
    },
    'ku': {
      'title': 'Polîtîkaya Taybetiyê',
      'intro':
          'Hînkirina Rengîn ji bo ku zarok bi lîstikan rengan hîn bibin hatiye çêkirin.',
      'data':
          'Ev serlêdan tu danegeha kesane kom nake, nahêle an bi aliyên sêyemîn re parve nake.',
      'local':
          'Pêşketina lîstikê, stêrk û bijarteyên ziman/dengê tenê li ser cîhaza we têne hilanîn.',
      'ads': 'Serlêdan reklam, çerez an şopîneran bi kar nake.',
      'contact': 'Ji bo pirs û şîroveyên xwe bi me re têkilî daynin.',
      'contact_action': 'E-name bişîne',
      'contact_error': 'Sepana e-nameyê nehat vekirin.',
      'contact_body': 'Daxwaza piştgiriyê derbarê Hînkirina Rengîn de:',
      'public_policy_action': 'Polîtîkaya serhêl veke',
      'public_policy_error': 'Polîtîkaya taybetiyê venebû.',
    },
  };

  Future<void> _openSupportEmail(
    BuildContext context,
    Map<String, String> s,
  ) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': app.t('app_name'),
        'body': s['contact_body']!,
      },
    );
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $uri');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(s['contact_error']!)));
      }
    }
  }

  Future<void> _openPublicPolicy(
    BuildContext context,
    Map<String, String> s,
  ) async {
    try {
      if (!await launchUrl(
        Uri.parse(_privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $_privacyPolicyUrl');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(s['public_policy_error']!)));
      }
    }
  }

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
                Center(
                  child: FilledButton.icon(
                    onPressed: () => _openSupportEmail(context, s),
                    icon: const Icon(Icons.email_outlined),
                    label: Text(s['contact_action']!),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _openPublicPolicy(context, s),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(s['public_policy_action']!),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _supportEmail,
                    style: TextStyle(
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
