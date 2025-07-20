// lib/core/constants/asset_paths.dart
/// 資源檔案路徑常數
/// 
/// 統一管理應用程式中所有的資源檔案路徑
/// 包括圖片、圖示、動畫、字體等
class AssetPaths {
  // 防止實例化
  AssetPaths._();

  // ========== 基礎路徑 ==========
  /// 圖片資源根目錄
  static const String _imagesPath = 'assets/images';
  
  /// 圖示資源根目錄
  static const String _iconsPath = 'assets/icons';
  
  /// 動畫資源根目錄
  static const String _animationsPath = 'assets/animations';
  
  /// 字體資源根目錄
  static const String _fontsPath = 'assets/fonts';

  // ========== Logo 和品牌圖片 ==========
  /// 應用程式 Logo
  static const String appLogo = '$_imagesPath/logo.png';
  
  /// 應用程式 Logo (白色)
  static const String appLogoWhite = '$_imagesPath/logo_white.png';
  
  /// 應用程式圖示
  static const String appIcon = '$_imagesPath/app_icon.png';
  
  /// 啟動畫面 Logo
  static const String splashLogo = '$_imagesPath/splash_logo.png';
  
  /// 浮水印
  static const String watermark = '$_imagesPath/watermark.png';

  // ========== 預設圖片 ==========
  /// 預設頭像
  static const String defaultAvatar = '$_imagesPath/default_avatar.png';
  
  /// 預設名片背景
  static const String defaultCardBackground = '$_imagesPath/default_card_bg.png';
  
  /// 空狀態圖片
  static const String emptyState = '$_imagesPath/empty_state.png';
  
  /// 錯誤狀態圖片
  static const String errorState = '$_imagesPath/error_state.png';
  
  /// 網路錯誤圖片
  static const String networkError = '$_imagesPath/network_error.png';
  
  /// 無搜尋結果圖片
  static const String noResults = '$_imagesPath/no_results.png';

  // ========== 插圖和引導圖片 ==========
  /// 歡迎頁面插圖
  static const String welcomeIllustration = '$_imagesPath/welcome.png';
  
  /// 登入頁面插圖
  static const String loginIllustration = '$_imagesPath/login.png';
  
  /// 註冊頁面插圖
  static const String registerIllustration = '$_imagesPath/register.png';
  
  /// 忘記密碼插圖
  static const String forgotPasswordIllustration = '$_imagesPath/forgot_password.png';
  
  /// 成功插圖
  static const String successIllustration = '$_imagesPath/success.png';
  
  /// 引導步驟1插圖
  static const String onboarding1 = '$_imagesPath/onboarding_1.png';
  
  /// 引導步驟2插圖
  static const String onboarding2 = '$_imagesPath/onboarding_2.png';
  
  /// 引導步驟3插圖
  static const String onboarding3 = '$_imagesPath/onboarding_3.png';

  // ========== 名片樣式背景 ==========
  /// 經典樣式背景
  static const String classicCardBg = '$_imagesPath/card_styles/classic_bg.png';
  
  /// 現代樣式背景
  static const String modernCardBg = '$_imagesPath/card_styles/modern_bg.png';
  
  /// 優雅樣式背景
  static const String elegantCardBg = '$_imagesPath/card_styles/elegant_bg.png';
  
  /// 極簡樣式背景
  static const String minimalCardBg = '$_imagesPath/card_styles/minimal_bg.png';
  
  /// 創意樣式背景
  static const String creativeCardBg = '$_imagesPath/card_styles/creative_bg.png';
  
  /// 專業樣式背景
  static const String professionalCardBg = '$_imagesPath/card_styles/professional_bg.png';

  // ========== 圖示 ==========
  /// 首頁圖示
  static const String homeIcon = '$_iconsPath/home.svg';
  
  /// 名片圖示
  static const String cardsIcon = '$_iconsPath/cards.svg';
  
  /// 群組圖示
  static const String groupsIcon = '$_iconsPath/groups.svg';
  
  /// 搜尋圖示
  static const String searchIcon = '$_iconsPath/search.svg';
  
  /// 個人資料圖示
  static const String profileIcon = '$_iconsPath/profile.svg';
  
  /// 設定圖示
  static const String settingsIcon = '$_iconsPath/settings.svg';
  
  /// QR 碼圖示
  static const String qrCodeIcon = '$_iconsPath/qr_code.svg';
  
  /// 分享圖示
  static const String shareIcon = '$_iconsPath/share.svg';
  
  /// 編輯圖示
  static const String editIcon = '$_iconsPath/edit.svg';
  
  /// 刪除圖示
  static const String deleteIcon = '$_iconsPath/delete.svg';
  
  /// 添加圖示
  static const String addIcon = '$_iconsPath/add.svg';
  
  /// 電話圖示
  static const String phoneIcon = '$_iconsPath/phone.svg';
  
  /// 郵件圖示
  static const String emailIcon = '$_iconsPath/email.svg';
  
  /// 地址圖示
  static const String addressIcon = '$_iconsPath/address.svg';
  
  /// 網站圖示
  static const String websiteIcon = '$_iconsPath/website.svg';
  
  /// 收藏圖示
  static const String favoriteIcon = '$_iconsPath/favorite.svg';
  
  /// 已收藏圖示
  static const String favoriteFilledIcon = '$_iconsPath/favorite_filled.svg';
  
  /// 通知圖示
  static const String notificationIcon = '$_iconsPath/notification.svg';
  
  /// 相機圖示
  static const String cameraIcon = '$_iconsPath/camera.svg';
  
  /// 相片圖示
  static const String galleryIcon = '$_iconsPath/gallery.svg';

  // ========== 社交媒體圖示 ==========
  /// Facebook 圖示
  static const String facebookIcon = '$_iconsPath/social/facebook.svg';
  
  /// Instagram 圖示
  static const String instagramIcon = '$_iconsPath/social/instagram.svg';
  
  /// LINE 圖示
  static const String lineIcon = '$_iconsPath/social/line.svg';
  
  /// Threads 圖示
  static const String threadsIcon = '$_iconsPath/social/threads.svg';
  
  /// Twitter 圖示
  static const String twitterIcon = '$_iconsPath/social/twitter.svg';
  
  /// LinkedIn 圖示
  static const String linkedinIcon = '$_iconsPath/social/linkedin.svg';
  
  /// 微信圖示
  static const String wechatIcon = '$_iconsPath/social/wechat.svg';
  
  /// Telegram 圖示
  static const String telegramIcon = '$_iconsPath/social/telegram.svg';
  
  /// WhatsApp 圖示
  static const String whatsappIcon = '$_iconsPath/social/whatsapp.svg';

  // ========== 動畫檔案 ==========
  /// 載入動畫
  static const String loadingAnimation = '$_animationsPath/loading.json';
  
  /// 成功動畫
  static const String successAnimation = '$_animationsPath/success.json';
  
  /// 錯誤動畫
  static const String errorAnimation = '$_animationsPath/error.json';
  
  /// 空狀態動畫
  static const String emptyAnimation = '$_animationsPath/empty.json';
  
  /// 搜尋動畫
  static const String searchAnimation = '$_animationsPath/search.json';
  
  /// 下拉刷新動畫
  static const String pullToRefreshAnimation = '$_animationsPath/pull_to_refresh.json';
  
  /// QR 碼掃描動畫
  static const String qrScanAnimation = '$_animationsPath/qr_scan.json';
  
  /// 分享動畫
  static const String shareAnimation = '$_animationsPath/share.json';

  // ========== 字體檔案 ==========
  /// Inter 字體家族
  static const String interFont = '$_fontsPath/Inter';
  
  /// Poppins 字體家族
  static const String poppinsFont = '$_fontsPath/Poppins';
  
  /// SF Mono 字體家族
  static const String sfMonoFont = '$_fontsPath/SFMono';

  // ========== 工具方法 ==========
  /// 獲取社交媒體圖示路徑
  static String getSocialMediaIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return facebookIcon;
      case 'instagram':
        return instagramIcon;
      case 'line':
        return lineIcon;
      case 'threads':
        return threadsIcon;
      case 'twitter':
        return twitterIcon;
      case 'linkedin':
        return linkedinIcon;
      case 'wechat':
        return wechatIcon;
      case 'telegram':
        return telegramIcon;
      case 'whatsapp':
        return whatsappIcon;
      default:
        return websiteIcon;
    }
  }
  
  /// 獲取名片樣式背景圖片路徑
  static String getCardStyleBackground(String style) {
    switch (style.toLowerCase()) {
      case 'classic':
        return classicCardBg;
      case 'modern':
        return modernCardBg;
      case 'elegant':
        return elegantCardBg;
      case 'minimal':
        return minimalCardBg;
      case 'creative':
        return creativeCardBg;
      case 'professional':
        return professionalCardBg;
      default:
        return modernCardBg;
    }
  }
  
  /// 檢查檔案是否存在 (需要配合 AssetBundle 使用)
  static Future<bool> assetExists(String path) async {
    try {
      await DefaultAssetBundle.of(NavigationService.instance.currentContext!)
          .load(path);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 獲取所有預設群組圖示
  static List<String> getDefaultGroupIcons() {
    return [
      groupsIcon,
      '$_iconsPath/business.svg',
      '$_iconsPath/friends.svg',
      '$_iconsPath/family.svg',
      '$_iconsPath/colleagues.svg',
      '$_iconsPath/partners.svg',
    ];
  }
}