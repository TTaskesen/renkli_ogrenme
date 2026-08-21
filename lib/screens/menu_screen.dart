import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_state.dart';
import '../widgets/language_buttons.dart';
import '../widgets/stars_pill.dart';
import 'home_screen.dart';
import 'privacy_screen.dart';

class MenuScreen extends StatelessWidget {
  final AppState app;

  const MenuScreen({super.key, required this.app});

  // Google Play yayını tamamlandığında derleme sırasında gerçek adresi ver:
  // --dart-define=PLAY_STORE_URL=https://play.google.com/store/apps/details?id=...
  static const _storeUrl = String.fromEnvironment('PLAY_STORE_URL');
  static const _developerName = 'Turgut Taşkesen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        key: const ValueKey('menu_background'),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E88E5), Color(0xFF6A1B9A)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  LanguageButtons(app: app),
                  const SizedBox(height: 48),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white38),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset(
                        'assets/icon/icon.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        app.t('app_name'),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
                  const SizedBox(height: 24),
                  StarsPill(app: app),
                  const SizedBox(height: 32),
                  _SoundToggle(app: app),
                  const SizedBox(height: 40),
                  _PlayButton(app: app),
                  const SizedBox(height: 40),
                  _FooterLinks(app: app),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundToggle extends StatelessWidget {
  final AppState app;

  const _SoundToggle({required this.app});

  @override
  Widget build(BuildContext context) {
    final on = app.soundEnabled;
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  on ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  on ? app.t('sound_on') : app.t('sound_off'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: on,
                  activeThumbColor: Colors.black87,
                  activeTrackColor: const Color(0xFFFFD54F),
                  onChanged: app.setSoundEnabled,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlayButton extends StatelessWidget {
  final AppState app;

  const _PlayButton({required this.app});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Material(
            color: const Color(0xFFFFD54F),
            borderRadius: BorderRadius.circular(32),
            elevation: 8,
            shadowColor: Colors.black45,
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => HomeScreen(app: app)));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 56,
                  vertical: 18,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow, size: 32, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      app.t('play'),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FooterLinks extends StatelessWidget {
  final AppState app;

  const _FooterLinks({required this.app});

  Future<void> _openStore(BuildContext context) async {
    if (MenuScreen._storeUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(app.t('coming_soon'))));
      return;
    }
    final uri = Uri.parse(MenuScreen._storeUrl);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('Could not launch $uri');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(app.t('coming_soon'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 24,
          runSpacing: 4,
          children: [
            _TextLink(
              label: app.t('privacy_policy'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PrivacyScreen(app: app)),
                );
              },
            ),
            _TextLink(
              label: app.t('rate_app'),
              onTap: () => _openStore(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${app.t('developer')}: ${MenuScreen._developerName} · ${app.t('version')} 1.0.3',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _TextLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TextLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
