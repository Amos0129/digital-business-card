import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final bool showMessage;
  final IOSLoadingStyle style;

  const LoadingWidget({
    Key? key,
    this.message,
    this.size,
    this.color,
    this.showMessage = true,
    this.style = IOSLoadingStyle.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLoadingIndicator(),
        if (showMessage && message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTheme.body.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    switch (style) {
      case IOSLoadingStyle.activity:
        return CupertinoActivityIndicator(
          radius: (size ?? 40) / 2,
          color: color ?? AppTheme.primaryColor,
        );
      case IOSLoadingStyle.progress:
        return SizedBox(
          width: size ?? 40,
          height: size ?? 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppTheme.primaryColor,
            ),
          ),
        );
      case IOSLoadingStyle.dots:
        return _DotsLoadingIndicator(
          size: size ?? 40,
          color: color ?? AppTheme.primaryColor,
        );
    }
  }
}

enum IOSLoadingStyle {
  activity,  // iOS 原生 CupertinoActivityIndicator
  progress,  // Material 風格的 CircularProgressIndicator
  dots,      // 點狀載入動畫
}

class _DotsLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;

  const _DotsLoadingIndicator({
    Key? key,
    required this.size,
    required this.color,
  }) : super(key: key);

  @override
  State<_DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<_DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < _controllers.length; i++) {
        _controllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 200));
      }
      await Future.delayed(const Duration(milliseconds: 200));
      for (final controller in _controllers) {
        controller.reverse();
      }
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size / 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: 0.5 + (_animations[index].value * 0.5),
                child: Container(
                  width: widget.size / 6,
                  height: widget.size / 6,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.3 + (_animations[index].value * 0.7)),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class FullScreenLoading extends StatelessWidget {
  final String? message;
  final bool barrierDismissible;
  final Color? backgroundColor;
  final IOSLoadingStyle style;

  const FullScreenLoading({
    Key? key,
    this.message,
    this.barrierDismissible = false,
    this.backgroundColor,
    this.style = IOSLoadingStyle.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: barrierDismissible,
      child: Scaffold(
        backgroundColor: backgroundColor ?? Colors.black.withOpacity(0.3),
        body: Center(
          child: _IOSLoadingCard(
            message: message ?? '載入中...',
            style: style,
          ),
        ),
      ),
    );
  }
}

class _IOSLoadingCard extends StatelessWidget {
  final String message;
  final IOSLoadingStyle style;

  const _IOSLoadingCard({
    Key? key,
    required this.message,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingWidget(
            message: null,
            size: 50,
            style: style,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.body.copyWith(
              color: AppTheme.textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  final String? message;
  final bool barrierDismissible;
  final IOSLoadingStyle style;

  const LoadingDialog({
    Key? key,
    this.message,
    this.barrierDismissible = false,
    this.style = IOSLoadingStyle.activity,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
    IOSLoadingStyle style = IOSLoadingStyle.activity,
  }) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => LoadingDialog(
        message: message,
        barrierDismissible: barrierDismissible,
        style: style,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: barrierDismissible,
      child: CupertinoAlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(16),
          child: LoadingWidget(
            message: message ?? '載入中...',
            size: 50,
            style: style,
          ),
        ),
      ),
    );
  }
}

class ButtonLoading extends StatelessWidget {
  final Color? color;
  final double size;
  final IOSLoadingStyle style;

  const ButtonLoading({
    Key? key,
    this.color,
    this.size = 20,
    this.style = IOSLoadingStyle.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case IOSLoadingStyle.activity:
        return CupertinoActivityIndicator(
          radius: size / 2,
          color: color ?? Colors.white,
        );
      case IOSLoadingStyle.progress:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Colors.white,
            ),
          ),
        );
      case IOSLoadingStyle.dots:
        return _DotsLoadingIndicator(
          size: size,
          color: color ?? Colors.white,
        );
    }
  }
}

class RefreshLoading extends StatelessWidget {
  final String? message;
  final IOSLoadingStyle style;

  const RefreshLoading({
    Key? key,
    this.message,
    this.style = IOSLoadingStyle.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingWidget(
            message: null,
            style: style,
            size: 30,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: AppTheme.footnote.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// iOS 風格的進度條
class IOSProgressBar extends StatelessWidget {
  final double? value;
  final String? label;
  final Color? backgroundColor;
  final Color? valueColor;
  final double height;

  const IOSProgressBar({
    Key? key,
    this.value,
    this.label,
    this.backgroundColor,
    this.valueColor,
    this.height = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTheme.footnote.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTheme.separatorColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: value != null
              ? FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value!.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: valueColor ?? AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

// iOS 風格的載入狀態管理器
class IOSLoadingOverlay extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final IOSLoadingStyle loadingStyle;

  const IOSLoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.loadingStyle = IOSLoadingStyle.activity,
  }) : super(key: key);

  @override
  State<IOSLoadingOverlay> createState() => _IOSLoadingOverlayState();
}

class _IOSLoadingOverlayState extends State<IOSLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isLoading) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(IOSLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: _IOSLoadingCard(
                      message: widget.loadingMessage ?? '載入中...',
                      style: widget.loadingStyle,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// 骨架載入動畫
class IOSSkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const IOSSkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<IOSSkeletonLoader> createState() => _IOSSkeletonLoaderState();
}

class _IOSSkeletonLoaderState extends State<IOSSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.separatorColor.withOpacity(0.3),
                AppTheme.separatorColor.withOpacity(0.1),
                AppTheme.separatorColor.withOpacity(0.3),
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}