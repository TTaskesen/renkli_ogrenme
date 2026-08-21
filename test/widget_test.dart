import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:renkli_ogrenme/main.dart';
import 'package:renkli_ogrenme/screens/menu_screen.dart';
import 'package:renkli_ogrenme/services/app_state.dart';

Future<void> pumpPastSplash(WidgetTester tester) async {
  await tester.pumpWidget(const RenkliOgrenmeApp());
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App shows the splash screen first', (WidgetTester tester) async {
    await tester.pumpWidget(const RenkliOgrenmeApp());
    await tester.pump();

    expect(find.text('Renkli Öğrenme'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Splash opens the welcome menu', (WidgetTester tester) async {
    await pumpPastSplash(tester);

    expect(find.text('Oyna'), findsOneWidget);
    expect(find.text('Ses Açık'), findsOneWidget);
  });

  testWidgets('Play button opens the games screen', (
    WidgetTester tester,
  ) async {
    await pumpPastSplash(tester);

    await tester.tap(find.text('Oyna'));
    await tester.pumpAndSettle();

    expect(find.text('Oyunlar'), findsOneWidget);
    expect(find.text('Renkleri Öğren'), findsOneWidget);
    expect(find.text('Yapboz'), findsOneWidget);
  });

  testWidgets('Sound toggle switches sound off', (WidgetTester tester) async {
    await pumpPastSplash(tester);

    expect(find.text('Ses Açık'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Ses Kapalı'), findsOneWidget);
  });

  testWidgets('French menu has no overflow on a narrow screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final app = AppState();
    app.setLanguage(AppLanguage.fr);

    await tester.pumpWidget(MaterialApp(home: MenuScreen(app: app)));
    await tester.pump();

    final privacy = find.text('Politique de confidentialité');
    final rating = find.text("Noter l'application");
    expect(privacy, findsOneWidget);
    expect(rating, findsOneWidget);
    expect(
      tester.getTopLeft(rating).dy,
      greaterThan(tester.getTopLeft(privacy).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kurmanji menu fills the full screen without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final app = AppState();
    app.setLanguage(AppLanguage.ku);

    await tester.pumpWidget(MaterialApp(home: MenuScreen(app: app)));
    await tester.pump();

    expect(
      tester.getSize(find.byKey(const ValueKey('menu_background'))),
      const Size(393, 852),
    );
    expect(find.text('Hînkirina Rengîn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
