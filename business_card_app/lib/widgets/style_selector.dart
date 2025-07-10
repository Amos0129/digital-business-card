import 'package:flutter/material.dart';

class StyleSelector extends StatelessWidget {
  final String selectedId;
  final List<Map<String, dynamic>> styles;
  final Function(String) onSelect;

  const StyleSelector({
    super.key,
    required this.selectedId,
    required this.styles,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: styles.map((style) {
          final selected = style['id'] == selectedId;
          return GestureDetector(
            onTap: () => onSelect(style['id']),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: style['bg'],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? style['accent'] : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Text(
                style['name'] ?? '',
                style: TextStyle(color: style['text']),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
