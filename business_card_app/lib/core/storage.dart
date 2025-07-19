import 'package:flutter/material.dart';
import 'constants.dart';

class AppUtils {
  // 顯示SnackBar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  // 顯示確認對話框
  static Future<bool> showConfirmDialog(
    BuildContext context, 
    String title, 
    String message,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('確定'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  // 顯示載入對話框
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
  
  // 隱藏載入對話框
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  // 電子郵件驗證
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
  
  // 密碼驗證
  static bool isValidPassword(String password) {
    return password.length >= AppConstants.minPasswordLength;
  }
  
  // 格式化電話號碼
  static String formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }
  
  // 取得名片樣式顏色
  static Color getStyleColor(String? style) {
    switch (style) {
      case 'minimal':
        return Colors.grey.shade900;
      case 'pink_card':
        return Colors.pink;
      case 'mint_card':
        return Colors.green;
      default:
        return const Color(0xFF4A6CFF);
    }
  }
  
  // 取得社交媒體圖示
  static IconData getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'line':
        return Icons.chat;
      case 'threads':
        return Icons.forum;
      default:
        return Icons.link;
    }
  }
  
  // 取得社交媒體顏色
  static Color getSocialColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'line':
        return const Color(0xFF00C300);
      case 'threads':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
  
  // 建立完整的頭像URL
  static String? getFullAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return null;
    if (avatarUrl.startsWith('http')) return avatarUrl;
    return '${AppConstants.baseUrl}$avatarUrl';
  }
  
  // 截斷文字
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  // 取得時間差描述
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小時前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分鐘前';
    } else {
      return '剛剛';
    }
  }
  
  // 複製到剪貼簿
  static Future<void> copyToClipboard(String text) async {
    // 實作複製功能
    // await Clipboard.setData(ClipboardData(text: text));
  }
  
  // 開啟URL
  static Future<void> launchUrl(String url) async {
    // 實作開啟URL功能
    // await launch(url);
  }
}