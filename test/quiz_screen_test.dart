import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:renkli_ogrenme/screens/quiz_screen.dart';
import 'package:renkli_ogrenme/services/app_state.dart';

void main() {
  testWidgets('quiz advances through 10 questions and shows the done dialog',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final app = AppState();
    await app.init();
    await tester.pumpWidget(MaterialApp(home: QuizScreen(app: app)));
    await tester.pump();

    expect(find.text('Bölüm 1/10'), findsOneWidget);

    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byKey(const ValueKey('quiz_option_0')));
      await tester.pump(const Duration(milliseconds: 1400));
    }

    expect(find.text('Tebrikler! Bölümü tamamladın!'), findsOneWidget);
    expect(find.textContaining('Skor:'), findsOneWidget);
  });

  testWidgets('restart resets the quiz', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final app = AppState();
    await app.init();
    await tester.pumpWidget(MaterialApp(home: QuizScreen(app: app)));
    await tester.pump();

    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byKey(const ValueKey('quiz_option_0')));
      await tester.pump(const Duration(milliseconds: 1400));
    }

    expect(find.text('Tebrikler! Bölümü tamamladın!'), findsOneWidget);
    await tester.tap(find.text('Tekrar Oyna'));
    await tester.pumpAndSettle();

    expect(find.text('Bölüm 1/10'), findsOneWidget);
  });
}
