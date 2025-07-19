import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme.dart';

enum IOSButtonStyle {
  filled,     // 填充按鈕
  tinted,     // 淡色按鈕
  plain,      // 純文字按鈕
  bordered,   // 邊框按鈕
}

enum IOSButtonSize {
  small,      // 小尺寸
  medium,     // 中等尺寸
  large,      // 大尺寸
}

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IOSButtonStyle style;
  final IOSButtonSize size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;
  final Widget? icon;
  final bool enabled;
  final bool isDestructive;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.style = IOSButtonStyle.filled,
    this.size = IOSButtonSize.medium,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.icon,
    this.enabled = true,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> 
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.enabled || widget.isLoading || widget.onPressed == null;
    
    return GestureDetector(
      onTapDown: isDisabled ? null : (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: isDisabled ? null : (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      onTapCancel: isDisabled ? null : () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildButton(context, isDisabled),
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    final buttonConfig = _getButtonConfig();
    
    return Container(
      width: widget.width,
      height: buttonConfig.height,
      padding: widget.padding ?? buttonConfig.padding,
      decoration: BoxDecoration(
        color: _getBackgroundColor(isDisabled),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(IOSConstants.radiusMedium),
        border: _getBorder(),
        boxShadow: widget.style == IOSButtonStyle.filled && !isDisabled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: widget.isLoading
          ? _buildLoadingContent()
          : _buildButtonContent(isDisabled),
    );
  }

  Widget _buildButtonContent(bool isDisabled) {
    final textColor = _getTextColor(isDisabled);
    final buttonConfig = _getButtonConfig();
    
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(
              color: textColor,
              size: buttonConfig.iconSize,
            ),
            child: widget.icon!,
          ),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize ?? buttonConfig.fontSize,
              fontWeight: widget.fontWeight ?? buttonConfig.fontWeight,
              color: textColor,
              fontFamily: '.SF Pro Text',
            ),
          ),
        ],
      );
    }
    
    return Center(
      child: Text(
        widget.text,
        style: TextStyle(
          fontSize: widget.fontSize ?? buttonConfig.fontSize,
          fontWeight: widget.fontWeight ?? buttonConfig.fontWeight,
          color: textColor,
          fontFamily: '.SF Pro Text',
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CupertinoActivityIndicator(
          color: _getTextColor(false),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDisabled) {
    if (isDisabled) {
      return widget.style == IOSButtonStyle.filled 
          ? AppTheme.tertiaryTextColor
          : Colors.transparent;
    }
    
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }
    
    if (widget.isDestructive) {
      switch (widget.style) {
        case IOSButtonStyle.filled:
          return AppTheme.destructiveColor;
        case IOSButtonStyle.tinted:
          return AppTheme.destructiveColor.withOpacity(0.1);
        case IOSButtonStyle.plain:
        case IOSButtonStyle.bordered:
          return Colors.transparent;
      }
    }
    
    switch (widget.style) {
      case IOSButtonStyle.filled:
        return AppTheme.primaryColor;
      case IOSButtonStyle.tinted:
        return AppTheme.primaryColor.withOpacity(0.1);
      case IOSButtonStyle.plain:
      case IOSButtonStyle.bordered:
        return Colors.transparent;
    }
  }

  Color _getTextColor(bool isDisabled) {
    if (isDisabled) {
      return AppTheme.tertiaryTextColor;
    }
    
    if (widget.textColor != null) {
      return widget.textColor!;
    }
    
    if (widget.isDestructive) {
      switch (widget.style) {
        case IOSButtonStyle.filled:
          return Colors.white;
        case IOSButtonStyle.tinted:
        case IOSButtonStyle.plain:
        case IOSButtonStyle.bordered:
          return AppTheme.destructiveColor;
      }
    }
    
    switch (widget.style) {
      case IOSButtonStyle.filled:
        return Colors.white;
      case IOSButtonStyle.tinted:
      case IOSButtonStyle.plain:
      case IOSButtonStyle.bordered:
        return AppTheme.primaryColor;
    }
  }

  Border? _getBorder() {
    if (widget.style == IOSButtonStyle.bordered) {
      return Border.all(
        color: widget.isDestructive 
            ? AppTheme.destructiveColor 
            : AppTheme.primaryColor,
        width: 1.0,
      );
    }
    return null;
  }

  _ButtonConfig _getButtonConfig() {
    switch (widget.size) {
      case IOSButtonSize.small:
        return _ButtonConfig(
          height: 36,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          iconSize: 16,
        );
      case IOSButtonSize.medium:
        return _ButtonConfig(
          height: 44,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          iconSize: 18,
        );
      case IOSButtonSize.large:
        return _ButtonConfig(
          height: 50,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          iconSize: 20,
        );
    }
  }
}

class _ButtonConfig {
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;
  final double iconSize;

  _ButtonConfig({
    required this.height,
    required this.fontSize,
    required this.fontWeight,
    required this.padding,
    required this.iconSize,
  });
}

// iOS 風格專用按鈕
class IOSPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  const IOSPrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      style: IOSButtonStyle.filled,
      size: IOSButtonSize.large,
      icon: icon,
      width: double.infinity,
    );
  }
}

class IOSSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  const IOSSecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      style: IOSButtonStyle.tinted,
      size: IOSButtonSize.large,
      icon: icon,
      width: double.infinity,
    );
  }
}

class IOSDestructiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IOSButtonStyle style;

  const IOSDestructiveButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.style = IOSButtonStyle.plain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      style: style,
      size: IOSButtonSize.medium,
      isDestructive: true,
    );
  }
}

class IOSLinkButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;

  const IOSLinkButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      style: IOSButtonStyle.plain,
      size: IOSButtonSize.medium,
      icon: icon,
    );
  }
}