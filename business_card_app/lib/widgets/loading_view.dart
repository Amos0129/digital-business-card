// lib/widgets/loading_view.dart
import 'package:flutter/cupertino.dart';
import '../core/theme.dart';

class LoadingView extends StatelessWidget {
  final String? message;
  final bool isOverlay;
  final Color? backgroundColor;

  const LoadingView({
    super.key,
    this.message,
    this.isOverlay = false,
    this.backgroundColor,
  });

  // 全屏載入
  static Widget fullScreen({String? message}) {
    return LoadingView(
      message: message,
      isOverlay: true,
      backgroundColor: AppTheme.backgroundColor,
    );
  }

  // 卡片載入
  static Widget card({String? message}) {
    return LoadingView(
      message: message,
      backgroundColor: AppTheme.cardColor,
    );
  }

  // 透明覆蓋
  static Widget overlayWidget({String? message}) {
    return LoadingView(
      message: message,
      isOverlay: true,
      backgroundColor: CupertinoColors.black.withOpacity(0.3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // iOS 風格載入指示器
        const CupertinoActivityIndicator(
          radius: 14,
        ),
        
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTheme.footnote.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isOverlay) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: backgroundColor,
        child: Center(child: content),
      );
    }

    return Container(
      padding: const EdgeInsets.all(32),
      color: backgroundColor,
      child: Center(child: content),
    );
  }
}

// 載入對話框
class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({
    super.key,
    required this.message,
  });

  static void show(BuildContext context, {String message = '載入中...'}) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: AppTheme.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 下拉刷新載入
class PullToRefreshLoading extends StatelessWidget {
  final bool isRefreshing;
  final Future<void> Function() onRefresh;
  final Widget child;

  const PullToRefreshLoading({
    super.key,
    required this.isRefreshing,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
        ),
        SliverToBoxAdapter(
          child: child,
        ),
      ],
    );
  }
}