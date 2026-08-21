import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:renkli_ogrenme/screens/privacy_screen.dart';
import 'package:renkli_ogrenme/services/app_state.dart';

void main() {
  testWidgets('shows the support email and action', (tester) async {
    final app = AppState();
    await tester.pumpWidget(MaterialApp(home: PrivacyScreen(app: app)));

    expect(find.text('E-posta gönder'), findsOneWidget);
    expect(find.text('turguttaskesen@gmail.com'), findsOneWidget);
  });

  testWidgets('shows the Kurmanji privacy text', (tester) async {
    final app = AppState();
    app.setLanguage(AppLanguage.ku);
    await tester.pumpWidget(MaterialApp(home: PrivacyScreen(app: app)));

    expect(find.text('Polîtîkaya Taybetiyê'), findsNWidgets(2));
    expect(find.text('E-name bişîne'), findsOneWidget);
  });
}
