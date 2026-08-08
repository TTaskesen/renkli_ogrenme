import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:renkli_ogrenme/screens/memory_screen.dart';
import 'package:renkli_ogrenme/services/app_state.dart';

void main() {
  testWidgets('memory game flips cards and counts moves',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final app = AppState();
    await app.init();
    await tester.pumpWidget(MaterialApp(home: MemoryScreen(app: app)));
    await tester.pump();

    expect(find.text('Hamle: 0'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('memory_card_0')));
    await tester.pump();
    expect(find.text('Hamle: 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('memory_card_1')));
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('Hamle: 2'), findsOneWidget);
  });
}
