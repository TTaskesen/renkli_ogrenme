import 'package:flutter/material.dart';

class ColorItem {
  final String id;
  final String nameTr;
  final String nameEn;
  final String nameFr;
  final String nameKu;
  final Color color;
  final IconData icon;

  const ColorItem({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.nameFr,
    required this.nameKu,
    required this.color,
    required this.icon,
  });

  String nameForLanguageCode(String languageCode) {
    if (languageCode.startsWith('tr')) return nameTr;
    if (languageCode.startsWith('fr')) return nameFr;
    if (languageCode.startsWith('ku')) return nameKu;
    return nameEn;
  }
}
