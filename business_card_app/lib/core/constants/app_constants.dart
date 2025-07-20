// lib/core/constants/app_constants.dart
/// 應用程式常數配置
/// 
/// 集中管理應用程式中使用的所有常數
/// 包括字串、數值、鍵值等
class AppConstants {
  // 防止實例化
  AppConstants._();

  // ========== 應用程式基本資訊 ==========
  /// 應用程式名稱
  static const String appName = 'Digital Business Card';
  
  /// 應用程式版本
  static const String appVersion = '1.0.0';
  
  /// 應用程式包名
  static const String packageName = 'com.emfabro.business_card';
  
  /// 應用程式官網
  static const String appWebsite = 'https://digitalcard.emfabro.com';
  
  /// 客服郵件
  static const String supportEmail = 'support@emfabro.com';

  // ========== 儲存鍵值 ==========
  /// JWT Token 儲存鍵
  static const String tokenKey = 'auth_token';
  
  /// 使用者資訊儲存鍵
  static const String userDataKey = 'user_data';
  
  /// 主題模式儲存鍵
  static const String themeModeKey = 'theme_mode';
  
  /// 語言設定儲存鍵
  static const String languageKey = 'language';
  
  /// 第一次啟動標記
  static const String firstLaunchKey = 'first_launch';
  
  /// 生物識別認證啟用狀態
  static const String biometricEnabledKey = 'biometric_enabled';
  
  /// 推播通知啟用狀態
  static const String notificationsEnabledKey = 'notifications_enabled';
  
  /// 搜尋歷史儲存鍵
  static const String searchHistoryKey = 'search_history';
  
  /// 最近瀏覽的名片
  static const String recentCardsKey = 'recent_cards';

  // ========== 數值限制 ==========
  /// 名片名稱最大長度
  static const int maxCardNameLength = 50;
  
  /// 公司名稱最大長度
  static const int maxCompanyNameLength = 100;
  
  /// 職位最大長度
  static const int maxPositionLength = 50;
  
  /// 電話號碼最大長度
  static const int maxPhoneLength = 20;
  
  /// 電子郵件最大長度
  static const int maxEmailLength = 100;
  
  /// 地址最大長度
  static const int maxAddressLength = 200;
  
  /// 群組名稱最大長度
  static const int maxGroupNameLength = 30;
  
  /// 搜尋關鍵字最大長度
  static const int maxSearchKeywordLength = 50;
  
  /// 密碼最小長度
  static const int minPasswordLength = 6;
  
  /// 密碼最大長度
  static const int maxPasswordLength = 20;
  
  /// 頁面載入每頁數量
  static const int pageSize = 20;
  
  /// 搜尋歷史最大保存數量
  static const int maxSearchHistoryCount = 10;
  
  /// 最近瀏覽最大保存數量
  static const int maxRecentCardsCount = 20;

  // ========== 檔案相關 ==========
  /// 頭像檔案最大大小 (5MB)
  static const int maxAvatarFileSize = 5 * 1024 * 1024;
  
  /// 支援的圖片格式
  static const List<String> supportedImageFormats = [
    'jpg', 'jpeg', 'png', 'webp'
  ];
  
  /// 預設頭像 URL
  static const String defaultAvatarUrl = 'assets/images/default_avatar.png';
  
  /// 圖片品質壓縮比例
  static const int imageQuality = 85;
  
  /// 縮圖尺寸
  static const int thumbnailSize = 200;

  // ========== 網路設定 ==========
  /// 請求超時時間 (秒)
  static const int requestTimeoutSeconds = 30;
  
  /// 連線超時時間 (秒)
  static const int connectTimeoutSeconds = 15;
  
  /// 重試次數
  static const int maxRetryCount = 3;
  
  /// 快取過期時間 (小時)
  static const int cacheExpirationHours = 24;

  // ========== 動畫設定 ==========
  /// 頁面轉場動畫時長 (毫秒)
  static const int pageTransitionDuration = 300;
  
  /// 按鈕點擊動畫時長 (毫秒)
  static const int buttonAnimationDuration = 150;
  
  /// 載入動畫時長 (毫秒)
  static const int loadingAnimationDuration = 1200;
  
  /// 下拉刷新動畫時長 (毫秒)
  static const int pullToRefreshDuration = 800;

  // ========== 名片樣式 ==========
  /// 可用的名片樣式
  static const Map<String, String> cardStyles = {
    'classic': '經典',
    'modern': '現代',
    'elegant': '優雅',
    'minimal': '極簡',
    'creative': '創意',
    'professional': '專業',
  };
  
  /// 預設名片樣式
  static const String defaultCardStyle = 'modern';

  // ========== 社交媒體平台 ==========
  /// 支援的社交媒體平台
  static const Map<String, String> socialMediaPlatforms = {
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'line': 'LINE',
    'threads': 'Threads',
    'twitter': 'Twitter',
    'linkedin': 'LinkedIn',
    'wechat': '微信',
    'telegram': 'Telegram',
    'whatsapp': 'WhatsApp',
  };

  // ========== 錯誤訊息 ==========
  /// 網路錯誤訊息
  static const String networkErrorMessage = '網路連線異常，請檢查網路設定';
  
  /// 伺服器錯誤訊息
  static const String serverErrorMessage = '伺服器異常，請稍後再試';
  
  /// 認證失敗訊息
  static const String authErrorMessage = '認證失敗，請重新登入';
  
  /// 資料不存在訊息
  static const String dataNotFoundMessage = '找不到相關資料';
  
  /// 權限不足訊息
  static const String permissionDeniedMessage = '權限不足，無法執行此操作';
  
  /// 檔案上傳失敗訊息
  static const String fileUploadErrorMessage = '檔案上傳失敗，請重試';
  
  /// 檔案大小超限訊息
  static const String fileSizeExceededMessage = '檔案大小超過限制';
  
  /// 檔案格式不支援訊息
  static const String unsupportedFileFormatMessage = '不支援的檔案格式';

  // ========== 成功訊息 ==========
  /// 操作成功訊息
  static const String operationSuccessMessage = '操作成功';
  
  /// 儲存成功訊息
  static const String saveSuccessMessage = '儲存成功';
  
  /// 刪除成功訊息
  static const String deleteSuccessMessage = '刪除成功';
  
  /// 更新成功訊息
  static const String updateSuccessMessage = '更新成功';
  
  /// 分享成功訊息
  static const String shareSuccessMessage = '分享成功';
  
  /// 複製成功訊息
  static const String copySuccessMessage = '已複製到剪貼簿';

  // ========== 確認對話框訊息 ==========
  /// 刪除確認訊息
  static const String deleteConfirmMessage = '確定要刪除嗎？此操作無法復原。';
  
  /// 登出確認訊息
  static const String logoutConfirmMessage = '確定要登出嗎？';
  
  /// 清除快取確認訊息
  static const String clearCacheConfirmMessage = '確定要清除快取嗎？';
  
  /// 重設設定確認訊息
  static const String resetSettingsConfirmMessage = '確定要重設所有設定嗎？';

  // ========== 預設群組名稱 ==========
  /// 預設群組名稱列表
  static const List<String> defaultGroupNames = [
    '全部',
    '客戶',
    '朋友',
    '家人',
    '同事',
    '商業夥伴',
  ];

  // ========== 正則表達式 ==========
  /// Email 驗證正則
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  
  /// 手機號碼驗證正則
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  
  /// URL 驗證正則
  static const String urlRegex = r'^https?:\/\/[^\s$.?#].[^\s]*$';

  // ========== 工具方法 ==========
  /// 檢查檔案大小是否符合限制
  static bool isFileSizeValid(int fileSizeBytes) {
    return fileSizeBytes <= maxAvatarFileSize;
  }
  
  /// 檢查圖片格式是否支援
  static bool isImageFormatSupported(String extension) {
    return supportedImageFormats.contains(extension.toLowerCase());
  }
  
  /// 獲取檔案擴展名
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }
  
  /// 格式化檔案大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}