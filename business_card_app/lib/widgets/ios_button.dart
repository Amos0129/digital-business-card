// lib/widgets/ios_button.dart
import 'package:flutter/cupertino.dart';
import '../core/theme.dart';

enum IOSButtonType {
  primary,
  secondary,
  destructive,
  plain,
}

enum IOSButtonSize {
  small,
  medium,
  large,
}

class IOSButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IOSButtonType type;
  final IOSButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final Color? customColor;

  const IOSButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = IOSButtonType.primary,
    this.size = IOSButtonSize.medium,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.customColor,
  });

  // 主要按鈕
  static Widget primary({
    required String text,
    VoidCallback? onPressed,
    IOSButtonSize size = IOSButtonSize.medium,
    IconData? icon,
    bool loading = false,
    bool fullWidth = false,
  }) {
    return IOSButton(
      text: text,
      onPressed: onPressed,
      type: IOSButtonType.primary,
      size: size,
      icon: icon,
      loading: loading,
      fullWidth: fullWidth,
    );
  }

  // 次要按鈕
  static Widget secondary({
    required String text,
    VoidCallback? onPressed,
    IOSButtonSize size = IOSButtonSize.medium,
    IconData? icon,
    bool loading = false,
    bool fullWidth = false,
  }) {
    return IOSButton(
      text: text,
      onPressed: onPressed,
      type: IOSButtonType.secondary,
      size: size,
      icon: icon,
      loading: loading,
      fullWidth: fullWidth,
    );
  }

  // 警告按鈕
  static Widget destructive({
    required String text,
    VoidCallback? onPressed,
    IOSButtonSize size = IOSButtonSize.medium,
    IconData? icon,
    bool loading = false,
    bool fullWidth = false,
  }) {
    return IOSButton(
      text: text,
      onPressed: onPressed,
      type: IOSButtonType.destructive,
      size: size,
      icon: icon,
      loading: loading,
      fullWidth: fullWidth,
    );
  }

  // 純文字按鈕
  static Widget plain({
    required String text,
    VoidCallback? onPressed,
    IOSButtonSize size = IOSButtonSize.medium,
    IconData? icon,
    bool loading = false,
    Color? color,
  }) {
    return IOSButton(
      text: text,
      onPressed: onPressed,
      type: IOSButtonType.plain,
      size: size,
      icon: icon,
      loading: loading,
      customColor: color,
    );
  }

  @override
  State<IOSButton> createState() => _IOSButtonState();
}

class _IOSButtonState extends State<IOSButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final config = _getButtonConfig();
    
    Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: widget.fullWidth ? double.infinity : null,
        height: config.height,
        padding: config.padding,
        decoration: BoxDecoration(
          color: _isPressed ? config.pressedColor : config.backgroundColor,
          borderRadius: BorderRadius.circular(config.borderRadius),
          border: config.borderColor != null
              ? Border.all(color: config.borderColor!, width: 1)
              : null,
          boxShadow: widget.type != IOSButtonType.plain && !_isPressed
              ? AppTheme.iosCardShadow
              : null,
        ),
        child: _buildContent(config),
      ),
    );

    if (widget.type == IOSButtonType.plain) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: widget.loading ? null : widget.onPressed,
        child: button,
      );
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: widget.loading ? null : widget.onPressed,
      child: button,
    );
  }

  Widget _buildContent(_ButtonConfig config) {
    final widgets = <Widget>[];

    if (widget.loading) {
      widgets.add(
        SizedBox(
          width: config.fontSize,
          height: config.fontSize,
          child: CupertinoActivityIndicator(
            color: config.textColor,
            radius: config.fontSize * 0.4,
          ),
        ),
      );
    } else if (widget.icon != null) {
      widgets.add(
        Icon(
          widget.icon,
          color: config.textColor,
          size: config.fontSize,
        ),
      );
    }

    if (widgets.isNotEmpty && !widget.loading) {
      widgets.add(SizedBox(width: config.spacing));
    }

    widgets.add(
      Text(
        widget.text,
        style: TextStyle(
          fontSize: config.fontSize,
          fontWeight: config.fontWeight,
          color: config.textColor,
          fontFamily: '.SF Pro Text',
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }

  _ButtonConfig _getButtonConfig() {
    switch (widget.type) {
      case IOSButtonType.primary:
        return _ButtonConfig(
          backgroundColor: widget.customColor ?? AppTheme.primaryColor,
          pressedColor: (widget.customColor ?? AppTheme.primaryColor).withOpacity(0.8),
          textColor: CupertinoColors.white,
          borderColor: null,
          height: _getHeight(),
          padding: _getPadding(),
          borderRadius: _getBorderRadius(),
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
          spacing: 8,
        );

      case IOSButtonType.secondary:
        return _ButtonConfig(
          backgroundColor: AppTheme.cardColor,
          pressedColor: AppTheme.separatorColor,
          textColor: AppTheme.primaryColor,
          borderColor: AppTheme.separatorColor,
          height: _getHeight(),
          padding: _getPadding(),
          borderRadius: _getBorderRadius(),
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
          spacing: 8,
        );

      case IOSButtonType.destructive:
        return _ButtonConfig(
          backgroundColor: AppTheme.errorColor,
          pressedColor: AppTheme.errorColor.withOpacity(0.8),
          textColor: CupertinoColors.white,
          borderColor: null,
          height: _getHeight(),
          padding: _getPadding(),
          borderRadius: _getBorderRadius(),
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
          spacing: 8,
        );

      case IOSButtonType.plain:
        return _ButtonConfig(
          backgroundColor: CupertinoColors.clear,
          pressedColor: AppTheme.separatorColor.withOpacity(0.3),
          textColor: widget.customColor ?? AppTheme.primaryColor,
          borderColor: null,
          height: _getHeight(),
          padding: _getPadding(),
          borderRadius: _getBorderRadius(),
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w400,
          spacing: 6,
        );
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case IOSButtonSize.small:
        return 36;
      case IOSButtonSize.medium:
        return 44;
      case IOSButtonSize.large:
        return 50;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case IOSButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case IOSButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case IOSButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 15);
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case IOSButtonSize.small:
        return 8;
      case IOSButtonSize.medium:
        return 10;
      case IOSButtonSize.large:
        return 12;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case IOSButtonSize.small:
        return 14;
      case IOSButtonSize.medium:
        return 16;
      case IOSButtonSize.large:
        return 17;
    }
  }
}

class _ButtonConfig {
  final Color backgroundColor;
  final Color pressedColor;
  final Color textColor;
  final Color? borderColor;
  final double height;
  final EdgeInsets padding;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final double spacing;

  _ButtonConfig({
    required this.backgroundColor,
    required this.pressedColor,
    required this.textColor,
    this.borderColor,
    required this.height,
    required this.padding,
    required this.borderRadius,
    required this.fontSize,
    required this.fontWeight,
    required this.spacing,
  });
}