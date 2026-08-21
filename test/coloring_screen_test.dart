import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:renkli_ogrenme/screens/coloring_screen.dart';
import 'package:renkli_ogrenme/services/app_state.dart';
import 'package:renkli_ogrenme/services/tts_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TtsService.enabled = false;
  });

  tearDown(TtsService.restoreDefaultEngine);

  test('scales normalized painting coordinates to the canvas size', () {
    expect(
      scaleNormalizedPoints(const [
        Offset(0.25, 0.5),
        Offset(1, 1),
      ], const Size(200, 120)),
      const [Offset(50, 60), Offset(200, 120)],
    );
  });

  test('uses elapsed time to calculate a coloring score', () {
    expect(coloringScoreFor(Duration.zero), 180);
    expect(coloringScoreFor(const Duration(seconds: 54)), 126);
    expect(coloringScoreFor(const Duration(seconds: 180)), 0);
    expect(coloringScoreFor(const Duration(minutes: 5)), 0);
  });

  testWidgets('uses French picture names and records a completed coloring', (
    tester,
  ) async {
    final app = AppState();
    app.setLanguage(AppLanguage.fr);
    await tester.pumpWidget(MaterialApp(home: ColoringScreen(app: app)));
    await tester.pump();

    expect(find.text('Coloriage - Maison'), findsOneWidget);

    final box = tester.renderObject<RenderBox>(
      find.byKey(const ValueKey('coloring_canvas')),
    );
    final origin = box.localToGlobal(Offset.zero);
    final size = box.size;
    final regions = [
      const Offset(0.50, 0.25), // roof
      const Offset(0.27, 0.75), // wall
      const Offset(0.50, 0.75), // door
      const Offset(0.35, 0.58), // first window
      const Offset(0.65, 0.58), // second window
      const Offset(0.70, 0.40), // chimney, above the roof hit layer
    ];

    for (final point in regions) {
      await tester.tapAt(
        origin + Offset(point.dx * size.width, point.dy * size.height),
      );
      await tester.pump();
    }

    expect(
      find.text('Félicitations ! Tu as terminé le niveau !'),
      findsOneWidget,
    );
    expect(app.bestScore(GameIds.coloring), 180);
    expect(app.starsFor(GameIds.coloring), 3);
  });

  testWidgets('uses the Kurmanji picture name', (tester) async {
    final app = AppState();
    app.setLanguage(AppLanguage.ku);
    await tester.pumpWidget(MaterialApp(home: ColoringScreen(app: app)));
    await tester.pump();

    expect(find.text('Rengkirin - Mal'), findsOneWidget);
  });
}
