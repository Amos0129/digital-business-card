// lib/presentation/widgets/common/app_button.dart
import 'package:flutter/material.dart';

/// 自定義按鈕元件
/// 
/// 提供統一的按鈕樣式和載入狀態
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;
  final ButtonType type;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.icon,
    this.type = ButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color getBackgroundColor() {
      if (backgroundColor != null) return backgroundColor!;
      
      switch (type) {
        case ButtonType.primary:
          return Colors.white;
        case ButtonType.secondary:
          return Colors.transparent;
        case ButtonType.danger:
          return Colors.red;
      }
    }

    Color getTextColor() {
      if (textColor != null) return textColor!;
      
      switch (type) {
        case ButtonType.primary:
          return const Color(0xFF2196F3);
        case ButtonType.secondary:
          return Colors.white;
        case ButtonType.danger:
          return Colors.white;
      }
    }

    BorderSide? getBorderSide() {
      switch (type) {
        case ButtonType.secondary:
          return const BorderSide(color: Colors.white, width: 2);
        default:
          return null;
      }
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          foregroundColor: getTextColor(),
          elevation: type == ButtonType.primary ? 8 : 0,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: getBorderSide() ?? BorderSide.none,
          ),
          disabledBackgroundColor: getBackgroundColor().withOpacity(0.6),
          disabledForegroundColor: getTextColor().withOpacity(0.6),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: getTextColor(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 按鈕類型枚舉
enum ButtonType {
  primary,
  secondary,
  danger,
}