import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';
import 'services/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
          ),
          home: MenuScreen(app: _appState),
        );
      },
    );
  }
}
