import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:renkli_ogrenme/screens/mixing_screen.dart';
import 'package:renkli_ogrenme/services/app_state.dart';

void main() {
  testWidgets('mixing game presents primary colors and completes a level', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final app = AppState();
    await app.init();
    await tester.pumpWidget(MaterialApp(home: MixingScreen(app: app)));
    await tester.pump();

    expect(find.text('Ana Renkleri Karıştır'), findsOneWidget);
    expect(
      find.text('İki ana rengi karıştır. Hangi renk oluşur?'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('mixing_option_0'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('mixing_option_1'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('mixing_option_2'), skipOffstage: false),
      findsOneWidget,
    );

    for (var round = 0; round < 3; round++) {
      await tester.tap(find.byKey(const ValueKey('mixing_option_0')));
      await tester.pump(const Duration(milliseconds: 900));
    }
    await tester.pump();

    expect(find.text('Tebrikler! Bölümü tamamladın!'), findsOneWidget);
    expect(app.bestScore(GameIds.mixing), greaterThanOrEqualTo(0));
  });
}
