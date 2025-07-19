// lib/widgets/empty_view.dart
import 'package:flutter/cupertino.dart';
import '../core/theme.dart';

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;

  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
  });

  // 預設樣式
  static Widget noCards({VoidCallback? onCreateCard}) {
    return EmptyView(
      icon: CupertinoIcons.person_2,
      title: '還沒有名片',
      message: '建立您的第一張數位名片，\n開始與他人分享聯絡資訊',
      buttonText: '建立名片',
      onButtonPressed: onCreateCard,
      iconColor: AppTheme.primaryColor,
    );
  }

  static Widget noGroups({VoidCallback? onCreateGroup}) {
    return EmptyView(
      icon: CupertinoIcons.folder,
      title: '還沒有群組',
      message: '建立群組來整理您的名片，\n讓管理更有條理',
      buttonText: '建立群組',
      onButtonPressed: onCreateGroup,
      iconColor: AppTheme.secondaryColor,
    );
  }

  static Widget noSearchResults() {
    return const EmptyView(
      icon: CupertinoIcons.search,
      title: '找不到相關名片',
      message: '試試其他關鍵字，\n或瀏覽推薦的公開名片',
      iconColor: AppTheme.secondaryTextColor,
    );
  }

  static Widget networkError({VoidCallback? onRetry}) {
    return EmptyView(
      icon: CupertinoIcons.wifi_slash,
      title: '網路連線錯誤',
      message: '請檢查您的網路設定，\n然後重試',
      buttonText: '重試',
      onButtonPressed: onRetry,
      iconColor: AppTheme.errorColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 圖示
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 40,
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.6),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 標題
            Text(
              title,
              style: AppTheme.title3.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // 描述
            Text(
              message,
              style: AppTheme.subheadline.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 按鈕
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              CupertinoButton.filled(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}