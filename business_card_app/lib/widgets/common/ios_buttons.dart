// lib/widgets/common/ios_buttons.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum IOSButtonStyle {
  filled,
  tinted,
  bordered,
  plain,
}

enum IOSButtonSize {
  small,
  medium,
  large,
}

class IOSPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IOSButtonStyle style;
  final IOSButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const IOSPrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style = IOSButtonStyle.filled,
    this.size = IOSButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _IOSButton(
      text: text,
      onPressed: onPressed,
      style: style,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isPrimary: true,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}

class IOSSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IOSButtonStyle style;
  final IOSButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const IOSSecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style = IOSButtonStyle.tinted,
    this.size = IOSButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _IOSButton(
      text: text,
      onPressed: onPressed,
      style: style,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isPrimary: false,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IOSButtonStyle style;
  final IOSButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style = IOSButtonStyle.filled,
    this.size = IOSButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _IOSButton(
      text: text,
      onPressed: onPressed,
      style: style,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isPrimary: true,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}

class _IOSButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IOSButtonStyle style;
  final IOSButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isPrimary;
  final Color? backgroundColor;
  final Color? textColor;

  const _IOSButton({
    Key? key,
    required this.text,
    this.onPressed,
    required this.style,
    required this.size,
    this.icon,
    required this.isLoading,
    required this.isPrimary,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Color buttonBackgroundColor;
    Color buttonTextColor;
    double height;
    double fontSize;
    BorderRadius borderRadius;
    EdgeInsets padding;

    // Size configurations
    switch (size) {
      case IOSButtonSize.small:
        height = 36;
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 16);
        break;
      case IOSButtonSize.medium:
        height = 44;
        fontSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 20);
        break;
      case IOSButtonSize.large:
        height = 52;
        fontSize = 18;
        padding = const EdgeInsets.symmetric(horizontal: 24);
        break;
    }

    borderRadius = BorderRadius.circular(height / 2);

    // Color configurations
    final primaryColor = theme.primaryColor;
    
    if (backgroundColor != null && textColor != null) {
      buttonBackgroundColor = backgroundColor!;
      buttonTextColor = textColor!;
    } else {
      switch (style) {
        case IOSButtonStyle.filled:
          if (isPrimary) {
            buttonBackgroundColor = primaryColor;
            buttonTextColor = Colors.white;
          } else {
            buttonBackgroundColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
            buttonTextColor = isDark ? Colors.white : Colors.black87;
          }
          break;
        case IOSButtonStyle.tinted:
          buttonBackgroundColor = primaryColor.withOpacity(0.15);
          buttonTextColor = primaryColor;
          break;
        case IOSButtonStyle.bordered:
          buttonBackgroundColor = Colors.transparent;
          buttonTextColor = primaryColor;
          break;
        case IOSButtonStyle.plain:
          buttonBackgroundColor = Colors.transparent;
          buttonTextColor = primaryColor;
          break;
      }
    }

    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: buttonBackgroundColor,
          borderRadius: borderRadius,
          border: style == IOSButtonStyle.bordered
              ? Border.all(color: primaryColor, width: 1)
              : null,
        ),
        child: CupertinoButton(
          padding: padding,
          borderRadius: borderRadius,
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CupertinoActivityIndicator(
                    color: buttonTextColor,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: buttonTextColor,
                        size: fontSize * 1.2,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        color: buttonTextColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        fontFamily: '.SF Pro Text',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}