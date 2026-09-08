import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'services/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final app = AppState();
  await app.init();
  runApp(RenkliOgrenmeApp(appState: app));
}

class RenkliOgrenmeApp extends StatefulWidget {
  final AppState? appState;

  const RenkliOgrenmeApp({super.key, this.appState});

  @override
  State<RenkliOgrenmeApp> createState() => _RenkliOgrenmeAppState();
}

class _RenkliOgrenmeAppState extends State<RenkliOgrenmeApp> {
  late final AppState _appState = widget.appState ?? AppState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: _appState.t('app_name'),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: _appState.highContrast
                  ? Colors.black
                  : const Color(0xFF1E88E5),
              contrastLevel: _appState.highContrast ? 1.0 : 0.0,
            ),
            focusColor: _appState.highContrast ? Colors.black : null,
          ),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(_appState.largeText ? 1.2 : 1.0),
              ),
              child: child!,
            );
          },
          home: SplashScreen(app: _appState),
        );
      },
    );
  }
}
