// lib/core/services/toast_service.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typography.dart';

/// 吐司提示服務
/// 
/// 提供統一的消息提示功能
/// 支援不同類型的提示樣式和位置
class ToastService {
  // 單例模式
  static final ToastService _instance = ToastService._internal();
  static ToastService get instance => _instance;
  ToastService._internal();

  /// 顯示一般提示
  void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: _durationToLength(duration),
      gravity: gravity,
      backgroundColor: AppColors.neutral,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// 顯示成功提示
  void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: _durationToLength(duration),
      gravity: gravity,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// 顯示錯誤提示
  void showError(
    String message, {
    Duration duration = const Duration(seconds: 3),
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: _durationToLength(duration),
      gravity: gravity,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// 顯示警告提示
  void showWarning(
    String message, {
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: _durationToLength(duration),
      gravity: gravity,
      backgroundColor: AppColors.warning,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// 顯示自定義 SnackBar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final context = NavigationService.instance.currentContext;
    if (context == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // 清除之前的 SnackBar
    scaffoldMessenger.clearSnackBars();
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: textColor ?? Colors.white,
                size: AppDimensions.iconSizeSm,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
            ],
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: textColor ?? Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: backgroundColor ?? AppColors.neutral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusSm,
        ),
        margin: AppDimensions.paddingMd,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction ?? () {},
                textColor: textColor ?? Colors.white,
              )
            : null,
      ),
    );
  }

  /// 顯示成功 SnackBar
  void showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showSnackBar(
      message,
      duration: duration,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 顯示錯誤 SnackBar
  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showSnackBar(
      message,
      duration: duration,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 顯示警告 SnackBar
  void showWarningSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showSnackBar(
      message,
      duration: duration,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_outlined,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 顯示資訊 SnackBar
  void showInfoSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showSnackBar(
      message,
      duration: duration,
      backgroundColor: AppColors.info,
      icon: Icons.info_outline,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 顯示載入中提示
  void showLoading(String message) {
    showSnackBar(
      message,
      duration: const Duration(seconds: 30), // 較長時間，需要手動隱藏
      backgroundColor: AppColors.primary,
      icon: Icons.hourglass_empty,
    );
  }

  /// 隱藏載入中提示
  void hideLoading() {
    final context = NavigationService.instance.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  /// 顯示複製成功提示
  void showCopySuccess([String? customMessage]) {
    showSuccess(customMessage ?? '已複製到剪貼簿');
  }

  /// 顯示網路錯誤提示
  void showNetworkError([String? customMessage]) {
    showError(customMessage ?? '網路連線異常，請檢查網路設定');
  }

  /// 顯示操作成功提示
  void showOperationSuccess([String? customMessage]) {
    showSuccess(customMessage ?? '操作成功');
  }

  /// 顯示操作失敗提示
  void showOperationError([String? customMessage]) {
    showError(customMessage ?? '操作失敗，請重試');
  }

  /// 顯示保存成功提示
  void showSaveSuccess() {
    showSuccess('保存成功');
  }

  /// 顯示刪除成功提示
  void showDeleteSuccess() {
    showSuccess('刪除成功');
  }

  /// 顯示更新成功提示
  void showUpdateSuccess() {
    showSuccess('更新成功');
  }

  /// 顯示分享成功提示
  void showShareSuccess() {
    showSuccess('分享成功');
  }

  /// 顯示自定義浮動提示
  void showFloatingMessage(
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    ToastPosition position = ToastPosition.bottom,
  }) {
    final context = NavigationService.instance.currentContext;
    if (context == null) return;

    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _FloatingMessage(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
        position: position,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    
    // 自動隱藏
    Future.delayed(duration, () {
      try {
        overlayEntry.remove();
      } catch (e) {
        // 忽略重複移除的錯誤
      }
    });
  }

  /// 轉換時長為 Toast 長度
  Toast _durationToLength(Duration duration) {
    return duration.inSeconds <= 2 ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG;
  }

  /// 取消所有提示
  void cancelAll() {
    Fluttertoast.cancel();
    final context = NavigationService.instance.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }
}

/// 浮動提示位置
enum ToastPosition {
  top,
  center,
  bottom,
}

/// 自定義浮動訊息組件
class _FloatingMessage extends StatefulWidget {
  final String message;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final ToastPosition position;
  final VoidCallback onDismiss;

  const _FloatingMessage({
    required this.message,
    this.backgroundColor,
    this.textColor,
    this.icon,
    required this.position,
    required this.onDismiss,
  });

  @override
  State<_FloatingMessage> createState() => _FloatingMessageState();
}

class _FloatingMessageState extends State<_FloatingMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: _getInitialOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getInitialOffset() {
    switch (widget.position) {
      case ToastPosition.top:
        return const Offset(0, -1);
      case ToastPosition.bottom:
        return const Offset(0, 1);
      case ToastPosition.center:
        return const Offset(0, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position == ToastPosition.top ? 100 : null,
      bottom: widget.position == ToastPosition.bottom ? 100 : null,
      left: AppDimensions.spacingMd,
      right: AppDimensions.spacingMd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: AppDimensions.paddingMd,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? AppColors.neutral,
                    borderRadius: AppDimensions.borderRadiusSm,
                    boxShadow: AppDimensions.shadowMd,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.textColor ?? Colors.white,
                          size: AppDimensions.iconSizeSm,
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                      ],
                      Flexible(
                        child: Text(
                          widget.message,
                          style: AppTypography.bodyMedium.copyWith(
                            color: widget.textColor ?? Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}