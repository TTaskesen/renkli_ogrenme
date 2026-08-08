import 'package:flutter_test/flutter_test.dart';

import 'package:renkli_ogrenme/data/colors_data.dart';

void main() {
  test('contains the expected number of colors', () {
    expect(ColorData.colors.length, 12);
  });

  test('all color ids are unique', () {
    final ids = ColorData.colors.map((c) => c.id).toSet();
    expect(ids.length, ColorData.colors.length);
  });

  test('every color has a Turkish and English name', () {
    for (final c in ColorData.colors) {
      expect(c.nameTr, isNotEmpty, reason: '${c.id} missing TR name');
      expect(c.nameEn, isNotEmpty, reason: '${c.id} missing EN name');
    }
  });
}
