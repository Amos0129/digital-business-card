import 'package:flutter/material.dart';

final List<Map<String, dynamic>> styles = [
  {
    'id': 'default',
    'name': '預設樣式',
    'bg': Colors.white,
    'text': Colors.black87,
    'accent': const Color(0xFF4A6CFF),
  },
  {
    'id': 'minimal',
    'name': '極簡風',
    'bg': Colors.grey.shade900,
    'text': Colors.white,
    'accent': Colors.white,
  },
  {
    'id': 'pink_card',
    'name': '卡片風格 A',
    'bg': Colors.pink.shade50,
    'text': Colors.pink.shade900,
    'accent': Colors.pink,
  },
  {
    'id': 'mint_card',
    'name': '卡片風格 B',
    'bg': Colors.green.shade50,
    'text': Colors.green.shade900,
    'accent': Colors.green,
  },
];

Map<String, dynamic> getStyleById(String id) {
  return styles.firstWhere((s) => s['id'] == id, orElse: () => styles[0]);
}
