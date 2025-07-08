import 'package:flutter/material.dart';

class SocialField extends StatelessWidget {
  final String label;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final TextEditingController controller;

  const SocialField({
    super.key,
    required this.label,
    required this.enabled,
    required this.onToggle,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(label),
          value: enabled,
          onChanged: onToggle,
          activeColor: const Color(0xFF4A6CFF),
        ),
        if (enabled)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: '$label 連結',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
      ],
    );
  }
}
