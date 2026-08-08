import 'package:flutter/material.dart';
import '../models/color_model.dart';

class ColorData {
  static const List<ColorItem> colors = [
    ColorItem(
      id: 'red',
      nameTr: 'Kırmızı',
      nameEn: 'Red',
      color: Color(0xFFE53935),
      icon: Icons.apple,
    ),
    ColorItem(
      id: 'orange',
      nameTr: 'Turuncu',
      nameEn: 'Orange',
      color: Color(0xFFFB8C00),
      icon: Icons.sunny,
    ),
    ColorItem(
      id: 'yellow',
      nameTr: 'Sarı',
      nameEn: 'Yellow',
      color: Color(0xFFFDD835),
      icon: Icons.wb_sunny,
    ),
    ColorItem(
      id: 'green',
      nameTr: 'Yeşil',
      nameEn: 'Green',
      color: Color(0xFF43A047),
      icon: Icons.eco,
    ),
    ColorItem(
      id: 'blue',
      nameTr: 'Mavi',
      nameEn: 'Blue',
      color: Color(0xFF1E88E5),
      icon: Icons.water_drop,
    ),
    ColorItem(
      id: 'purple',
      nameTr: 'Mor',
      nameEn: 'Purple',
      color: Color(0xFF8E24AA),
      icon: Icons.circle,
    ),
    ColorItem(
      id: 'pink',
      nameTr: 'Pembe',
      nameEn: 'Pink',
      color: Color(0xFFEC407A),
      icon: Icons.favorite,
    ),
    ColorItem(
      id: 'brown',
      nameTr: 'Kahverengi',
      nameEn: 'Brown',
      color: Color(0xFF6D4C41),
      icon: Icons.brightness_1,
    ),
    ColorItem(
      id: 'black',
      nameTr: 'Siyah',
      nameEn: 'Black',
      color: Color(0xFF212121),
      icon: Icons.nightlight_round,
    ),
    ColorItem(
      id: 'white',
      nameTr: 'Beyaz',
      nameEn: 'White',
      color: Color(0xFFFAFAFA),
      icon: Icons.cloud,
    ),
    ColorItem(
      id: 'gray',
      nameTr: 'Gri',
      nameEn: 'Gray',
      color: Color(0xFF9E9E9E),
      icon: Icons.landscape,
    ),
    ColorItem(
      id: 'sky',
      nameTr: 'Gök Mavisi',
      nameEn: 'Sky Blue',
      color: Color(0xFF29B6F6),
      icon: Icons.cloud_queue,
    ),
  ];
}
