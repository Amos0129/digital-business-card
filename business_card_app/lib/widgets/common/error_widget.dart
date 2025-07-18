import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final bool showButton;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: iconSize ?? 64,
              color: iconColor ?? AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (showButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(buttonText ?? '重試'),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: '網路連線錯誤',
      message: message ?? '請檢查您的網路連線並重試',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

class NotFoundWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onGoBack;

  const NotFoundWidget({
    Key? key,
    this.title,
    this.message,
    this.onGoBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: title ?? '找不到內容',
      message: message ?? '您要查看的內容不存在或已被移除',
      icon: Icons.search_off,
      buttonText: '返回',
      onRetry: onGoBack ?? () => Navigator.of(context).pop(),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    Key? key,
    this.title,
    required this.message,
    this.icon,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: AppTheme.hintColor,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorSnackBar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '關閉',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

class SuccessSnackBar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// 使用範例：
// 1. 一般錯誤
// AppErrorWidget(
//   title: "載入失敗",
//   message: "無法載入資料，請稍後再試",
//   onRetry: () => _loadData(),
// )

// 2. 網路錯誤
// NetworkErrorWidget(onRetry: () => _loadData())

// 3. 找不到內容
// NotFoundWidget()

// 4. 空狀態
// EmptyStateWidget(
//   title: "沒有名片",
//   message: "您還沒有建立任何名片",
//   actionText: "建立第一張名片",
//   onAction: () => _createCard(),
// )

// 5. 錯誤訊息
// ErrorSnackBar.show(context, "操作失敗")

// 6. 成功訊息
// SuccessSnackBar.show(context, "儲存成功")