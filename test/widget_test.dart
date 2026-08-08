import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:renkli_ogrenme/main.dart';

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

  testWidgets('Play button opens the games screen', (WidgetTester tester) async {
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
}
