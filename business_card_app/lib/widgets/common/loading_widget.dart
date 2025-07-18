import 'package:flutter/material.dart';
import '../../core/theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final double strokeWidth;
  final bool showMessage;

  const LoadingWidget({
    Key? key,
    this.message,
    this.size,
    this.color,
    this.strokeWidth = 4.0,
    this.showMessage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size ?? 40,
          height: size ?? 40,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
        if (showMessage && message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class FullScreenLoading extends StatelessWidget {
  final String? message;
  final bool barrierDismissible;
  final Color? backgroundColor;

  const FullScreenLoading({
    Key? key,
    this.message,
    this.barrierDismissible = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: barrierDismissible,
      child: Scaffold(
        backgroundColor: backgroundColor ?? Colors.black54,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: LoadingWidget(
              message: message ?? '載入中...',
              size: 50,
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  final String? message;
  final bool barrierDismissible;

  const LoadingDialog({
    Key? key,
    this.message,
    this.barrierDismissible = false,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => LoadingDialog(
        message: message,
        barrierDismissible: barrierDismissible,
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
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: LoadingWidget(
            message: message ?? '載入中...',
            size: 50,
          ),
        ),
      ),
    );
  }
}

class ButtonLoading extends StatelessWidget {
  final Color? color;
  final double size;

  const ButtonLoading({
    Key? key,
    this.color,
    this.size = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
  }
}

class RefreshLoading extends StatelessWidget {
  final String? message;

  const RefreshLoading({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.hintColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 使用範例：
// 1. 基本載入
// LoadingWidget()

// 2. 帶訊息的載入
// LoadingWidget(message: "正在處理...")

// 3. 全螢幕載入
// FullScreenLoading(message: "請稍候...")

// 4. 載入對話框
// await LoadingDialog.show(context, message: "儲存中...");
// LoadingDialog.hide(context);

// 5. 按鈕內載入
// ElevatedButton(
//   child: isLoading ? ButtonLoading() : Text("登入"),
//   onPressed: isLoading ? null : _login,
// )