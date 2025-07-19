import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final bool showButton;
  final IOSErrorStyle style;

  const AppErrorWidget({
    Key? key,
    this.title,
    required this.message,
    this.buttonText,
    this.onRetry,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.showButton = true,
    this.style = IOSErrorStyle.standard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case IOSErrorStyle.standard:
        return _buildStandardError();
      case IOSErrorStyle.card:
        return _buildCardError();
      case IOSErrorStyle.minimal:
        return _buildMinimalError();
    }
  }

  Widget _buildStandardError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: AppTheme.title2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            Text(
              message,
              style: AppTheme.body.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (showButton && onRetry != null) ...[
              const SizedBox(height: 32),
              AppButton(
                text: buttonText ?? '重試',
                onPressed: onRetry,
                style: IOSButtonStyle.filled,
                size: IOSButtonSize.medium,
                icon: const Icon(CupertinoIcons.refresh),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardError() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 20),
            if (title != null) ...[
              Text(
                title!,
                style: AppTheme.headline.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: AppTheme.subheadline.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (showButton && onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: buttonText ?? '重試',
                onPressed: onRetry,
                style: IOSButtonStyle.tinted,
                width: double.infinity,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalError() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon ?? CupertinoIcons.exclamationmark_triangle,
            size: iconSize ?? 20,
            color: iconColor ?? AppTheme.errorColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTheme.footnote.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          if (showButton && onRetry != null) ...[
            const SizedBox(width: 12),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minSize: 0,
              onPressed: onRetry,
              child: Text(
                buttonText ?? '重試',
                style: AppTheme.footnote.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: iconSize ?? 64,
      height: iconSize ?? 64,
      decoration: BoxDecoration(
        color: (iconColor ?? AppTheme.errorColor).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon ?? CupertinoIcons.exclamationmark_triangle,
        size: (iconSize ?? 64) * 0.6,
        color: iconColor ?? AppTheme.errorColor,
      ),
    );
  }
}

enum IOSErrorStyle {
  standard,  // 標準錯誤樣式
  card,      // 卡片錯誤樣式
  minimal,   // 簡約錯誤樣式
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;
  final IOSErrorStyle style;

  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
    this.message,
    this.style = IOSErrorStyle.standard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: '網路連線錯誤',
      message: message ?? '請檢查您的網路連線並重試',
      icon: CupertinoIcons.wifi_slash,
      onRetry: onRetry,
      style: style,
    );
  }
}

class NotFoundWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onGoBack;
  final IOSErrorStyle style;

  const NotFoundWidget({
    Key? key,
    this.title,
    this.message,
    this.onGoBack,
    this.style = IOSErrorStyle.standard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: title ?? '找不到內容',
      message: message ?? '您要查看的內容不存在或已被移除',
      icon: CupertinoIcons.search_circle,
      buttonText: '返回',
      onRetry: onGoBack ?? () => Navigator.of(context).pop(),
      style: style,
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;
  final IOSErrorStyle style;
  final Widget? illustration;

  const EmptyStateWidget({
    Key? key,
    this.title,
    required this.message,
    this.icon,
    this.actionText,
    this.onAction,
    this.style = IOSErrorStyle.standard,
    this.illustration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            illustration ?? _buildIcon(),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: AppTheme.title3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            Text(
              message,
              style: AppTheme.body.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              AppButton(
                text: actionText!,
                onPressed: onAction,
                style: IOSButtonStyle.tinted,
                size: IOSButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.separatorColor.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon ?? CupertinoIcons.tray,
        size: 40,
        color: AppTheme.tertiaryTextColor,
      ),
    );
  }
}

// iOS 風格的 SnackBar
class IOSSnackBar {
  static void show(
    BuildContext context,
    String message, {
    IOSSnackBarType type = IOSSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? actionText,
    VoidCallback? onAction,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _IOSSnackBarWidget(
        message: message,
        type: type,
        onTap: onTap,
        actionText: actionText,
        onAction: onAction,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static void showError(BuildContext context, String message) {
    show(context, message, type: IOSSnackBarType.error);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message, type: IOSSnackBarType.success);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message, type: IOSSnackBarType.warning);
  }
}

enum IOSSnackBarType {
  info,
  success,
  error,
  warning,
}

class _IOSSnackBarWidget extends StatefulWidget {
  final String message;
  final IOSSnackBarType type;
  final VoidCallback? onTap;
  final String? actionText;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const _IOSSnackBarWidget({
    Key? key,
    required this.message,
    required this.type,
    this.onTap,
    this.actionText,
    this.onAction,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_IOSSnackBarWidget> createState() => _IOSSnackBarWidgetState();
}

class _IOSSnackBarWidgetState extends State<_IOSSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: _buildSnackBar(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSnackBar() {
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: (details) {
        if (details.delta.dy < -5) {
          _dismiss();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(IOSConstants.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              _getIcon(),
              color: _getIconColor(),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.message,
                style: AppTheme.subheadline.copyWith(
                  color: _getTextColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.actionText != null && widget.onAction != null) ...[
              const SizedBox(width: 12),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minSize: 0,
                onPressed: widget.onAction,
                child: Text(
                  widget.actionText!,
                  style: AppTheme.footnote.copyWith(
                    color: _getActionColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case IOSSnackBarType.success:
        return AppTheme.successColor.withOpacity(0.9);
      case IOSSnackBarType.error:
        return AppTheme.errorColor.withOpacity(0.9);
      case IOSSnackBarType.warning:
        return AppTheme.warningColor.withOpacity(0.9);
      case IOSSnackBarType.info:
        return AppTheme.secondaryBackgroundColor;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case IOSSnackBarType.success:
        return CupertinoIcons.check_mark_circled_solid;
      case IOSSnackBarType.error:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case IOSSnackBarType.warning:
        return CupertinoIcons.exclamationmark_triangle;
      case IOSSnackBarType.info:
        return CupertinoIcons.info_circle;
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case IOSSnackBarType.success:
      case IOSSnackBarType.error:
      case IOSSnackBarType.warning:
        return Colors.white;
      case IOSSnackBarType.info:
        return AppTheme.primaryColor;
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case IOSSnackBarType.success:
      case IOSSnackBarType.error:
      case IOSSnackBarType.warning:
        return Colors.white;
      case IOSSnackBarType.info:
        return AppTheme.textColor;
    }
  }

  Color _getActionColor() {
    switch (widget.type) {
      case IOSSnackBarType.success:
      case IOSSnackBarType.error:
      case IOSSnackBarType.warning:
        return Colors.white.withOpacity(0.9);
      case IOSSnackBarType.info:
        return AppTheme.primaryColor;
    }
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }
}

// iOS 風格的 Alert Dialog
class IOSAlert {
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '確定',
    String cancelText = '取消',
  }) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            isDefaultAction: true,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = '好的',
  }) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            isDefaultAction: true,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = '好的',
  }) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            isDefaultAction: true,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}