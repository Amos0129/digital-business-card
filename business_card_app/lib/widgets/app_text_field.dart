import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final bool required;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;

  const AppTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: (val) {
          if (required && (val == null || val.trim().isEmpty)) {
            return '請輸入 $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: GoogleFonts.notoSans(),
      ),
    );
  }
}