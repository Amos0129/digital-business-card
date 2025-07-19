// lib/screens/profile/profile_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('個人資料'),
      ),
      child: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildUserHeader(user),
                  const SizedBox(height: 32),
                  _buildMenuSection(context),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context, authProvider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserHeader(user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
        boxShadow: AppTheme.iosCardShadow,
      ),
      child: Column(
        children: [
          // 頭像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              CupertinoIcons.person_fill,
              size: 40,
              color: AppTheme.primaryColor.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 用戶名稱
          Text(
            user?.name ?? '使用者',
            style: AppTheme.title2,
          ),
          
          const SizedBox(height: 4),
          
          // 電子郵件
          Text(
            user?.email ?? '',
            style: AppTheme.footnote.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(IOSConstants.radiusLarge),
        boxShadow: AppTheme.iosCardShadow,
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context: context,
            icon: CupertinoIcons.person,
            title: '編輯個人資料',
            onTap: () => _editProfile(context),
          ),
          _buildMenuItem(
            context: context,
            icon: CupertinoIcons.lock,
            title: '變更密碼',
            onTap: () => _changePassword(context),
          ),
          _buildMenuItem(
            context: context,
            icon: CupertinoIcons.bell,
            title: '通知設定',
            onTap: () => _notificationSettings(context),
          ),
          _buildMenuItem(
            context: context,
            icon: CupertinoIcons.shield,
            title: '隱私設定',
            onTap: () => _privacySettings(context),
          ),
          _buildMenuItem(
            context: context,
            icon: CupertinoIcons.question_circle,
            title: '幫助與支援',
            onTap: () => _helpSupport(context),
          ),
          _buildMenuItem(
            context: context,
            icon: CupertinoIcons.info,
            title: '關於我們',
            onTap: () => _aboutUs(context),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        CupertinoButton(
          padding: const EdgeInsets.all(16),
          onPressed: onTap,
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.body,
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: AppTheme.tertiaryTextColor,
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            margin: const EdgeInsets.only(left: 56),
            height: 0.5,
            color: AppTheme.separatorColor,
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: CupertinoButton(
        color: CupertinoColors.systemRed,
        onPressed: () => _showLogoutDialog(context, authProvider),
        child: const Text('登出'),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    _showComingSoon(context, '編輯個人資料');
  }

  void _changePassword(BuildContext context) {
    _showComingSoon(context, '變更密碼');
  }

  void _notificationSettings(BuildContext context) {
    _showComingSoon(context, '通知設定');
  }

  void _privacySettings(BuildContext context) {
    _showComingSoon(context, '隱私設定');
  }

  void _helpSupport(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('幫助與支援'),
        content: const Text('如有問題請聯繫客服：support@digitalcard.com'),
        actions: [
          CupertinoDialogAction(
            child: const Text('確定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _aboutUs(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('關於數位名片'),
        content: const Text('版本 1.0.0\n\n讓名片交換更簡單、更環保。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('確定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(feature),
        content: const Text('功能開發中...'),
        actions: [
          CupertinoDialogAction(
            child: const Text('確定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('確定要登出嗎？'),
        content: const Text('登出後需要重新輸入帳號密碼'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
            },
            child: const Text('登出'),
          ),
        ],
      ),
    );
  }
}