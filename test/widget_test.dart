import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:renkli_ogrenme/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches and shows the welcome menu', (WidgetTester tester) async {
    await tester.pumpWidget(const RenkliOgrenmeApp());
    await tester.pump();

    expect(find.text('Renkli Öğrenme'), findsOneWidget);
    expect(find.text('Oyna'), findsOneWidget);
    expect(find.text('Ses Açık'), findsOneWidget);
  });

  testWidgets('Play button opens the games screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RenkliOgrenmeApp());
    await tester.pump();

    await tester.tap(find.text('Oyna'));
    await tester.pumpAndSettle();

    expect(find.text('Oyunlar'), findsOneWidget);
    expect(find.text('Renkleri Öğren'), findsOneWidget);
    expect(find.text('Yapboz'), findsOneWidget);
  });

  testWidgets('Sound toggle switches sound off', (WidgetTester tester) async {
    await tester.pumpWidget(const RenkliOgrenmeApp());
    await tester.pump();

    expect(find.text('Ses Açık'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Ses Kapalı'), findsOneWidget);
  });
}
