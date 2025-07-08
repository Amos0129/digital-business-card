import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool filled;
  final Icon? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.filled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = filled
        ? ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          )
        : OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: BorderSide(color: AppColors.primary),
          );

    final Widget child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon!.icon,
                color: filled ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: filled ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          )
        : Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: filled ? Colors.white : AppColors.primary,
            ),
          );

    return filled
        ? ElevatedButton(onPressed: onPressed, style: style, child: child)
        : OutlinedButton(onPressed: onPressed, style: style, child: child);
  }
}
