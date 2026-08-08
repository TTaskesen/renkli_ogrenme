import 'package:flutter/material.dart';

class ColorItem {
  final String id;
  final String nameTr;
  final String nameEn;
  final Color color;
  final IconData icon;

  const ColorItem({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.color,
    required this.icon,
  });
}
