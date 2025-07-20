// lib/core/constants/route_paths.dart
/// 路由路徑常數
/// 
/// 統一管理應用程式中所有的路由路徑
/// 支援命名路由和路由參數
class RoutePaths {
  // 防止實例化
  RoutePaths._();

  // ========== 基礎路由 ==========
  /// 根路由
  static const String root = '/';
  
  /// 啟動畫面
  static const String splash = '/splash';
  
  /// 引導頁面
  static const String onboarding = '/onboarding';
  
  /// 主要導航
  static const String mainNavigation = '/main';

  // ========== 認證相關路由 ==========
  /// 登入頁面
  static const String login = '/auth/login';
  
  /// 註冊頁面
  static const String register = '/auth/register';
  
  /// 忘記密碼頁面
  static const String forgotPassword = '/auth/forgot-password';
  
  /// 重設密碼頁面
  static const String resetPassword = '/auth/reset-password';
  
  /// 電子郵件驗證頁面
  static const String emailVerification = '/auth/email-verification';

  // ========== 首頁相關路由 ==========
  /// 首頁
  static const String home = '/home';
  
  /// 儀表板
  static const String dashboard = '/dashboard';
  
  /// 快速操作
  static const String quickActions = '/quick-actions';

  // ========== 名片相關路由 ==========
  /// 名片列表
  static const String cardsList = '/cards';
  
  /// 我的名片
  static const String myCards = '/cards/my';
  
  /// 名片詳情
  static const String cardDetail = '/cards/detail';
  
  /// 建立名片
  static const String createCard = '/cards/create';
  
  /// 編輯名片
  static const String editCard = '/cards/edit';
  
  /// 名片預覽
  static const String cardPreview = '/cards/preview';
  
  /// 公開名片
  static const String publicCards = '/cards/public';
  
  /// 名片分享
  static const String shareCard = '/cards/share';
  
  /// 名片QR碼
  static const String cardQrCode = '/cards/qr-code';

  // ========== 群組相關路由 ==========
  /// 群組列表
  static const String groups = '/groups';
  
  /// 群組詳情
  static const String groupDetail = '/groups/detail';
  
  /// 建立群組
  static const String createGroup = '/groups/create';
  
  /// 編輯群組
  static const String editGroup = '/groups/edit';
  
  /// 群組管理
  static const String groupManagement = '/groups/management';

  // ========== 搜尋相關路由 ==========
  /// 搜尋頁面
  static const String search = '/search';
  
  /// 搜尋結果
  static const String searchResults = '/search/results';
  
  /// 搜尋歷史
  static const String searchHistory = '/search/history';
  
  /// 高級搜尋
  static const String advancedSearch = '/search/advanced';

  // ========== 掃描相關路由 ==========
  /// QR碼掃描器
  static const String qrScanner = '/scanner';
  
  /// 掃描結果
  static const String scanResult = '/scanner/result';
  
  /// 掃描歷史
  static const String scanHistory = '/scanner/history';

  // ========== 個人資料相關路由 ==========
  /// 個人資料
  static const String profile = '/profile';
  
  /// 編輯個人資料
  static const String editProfile = '/profile/edit';
  
  /// 帳戶設定
  static const String accountSettings = '/profile/account';
  
  /// 修改密碼
  static const String changePassword = '/profile/change-password';
  
  /// 隱私設定
  static const String privacySettings = '/profile/privacy';
  
  /// 通知設定
  static const String notificationSettings = '/profile/notifications';

  // ========== 設定相關路由 ==========
  /// 設定頁面
  static const String settings = '/settings';
  
  /// 一般設定
  static const String generalSettings = '/settings/general';
  
  /// 主題設定
  static const String themeSettings = '/settings/theme';
  
  /// 語言設定
  static const String languageSettings = '/settings/language';
  
  /// 安全設定
  static const String securitySettings = '/settings/security';
  
  /// 關於我們
  static const String about = '/settings/about';
  
  /// 隱私政策
  static const String privacyPolicy = '/settings/privacy-policy';
  
  /// 服務條款
  static const String termsOfService = '/settings/terms-of-service';
  
  /// 意見回饋
  static const String feedback = '/settings/feedback';

  // ========== 收藏和歷史相關路由 ==========
  /// 收藏夾
  static const String favorites = '/favorites';
  
  /// 最近瀏覽
  static const String recentlyViewed = '/recently-viewed';
  
  /// 瀏覽歷史
  static const String viewHistory = '/view-history';

  // ========== 分享和匯出相關路由 ==========
  /// 分享選項
  static const String shareOptions = '/share';
  
  /// 匯出資料
  static const String exportData = '/export';
  
  /// 匯入資料
  static const String importData = '/import';

  // ========== 幫助和支援相關路由 ==========
  /// 幫助中心
  static const String helpCenter = '/help';
  
  /// 常見問題
  static const String faq = '/help/faq';
  
  /// 教學指南
  static const String tutorial = '/help/tutorial';
  
  /// 聯絡客服
  static const String contactSupport = '/help/contact';

  // ========== 錯誤和狀態頁面 ==========
  /// 404錯誤頁面
  static const String notFound = '/404';
  
  /// 網路錯誤頁面
  static const String networkError = '/network-error';
  
  /// 維護頁面
  static const String maintenance = '/maintenance';
  
  /// 無權限頁面
  static const String unauthorized = '/unauthorized';

  // ========== 帶參數的路由生成器 ==========
  /// 生成名片詳情路由
  static String cardDetailWithId(int cardId) => '$cardDetail/$cardId';
  
  /// 生成編輯名片路由
  static String editCardWithId(int cardId) => '$editCard/$cardId';
  
  /// 生成群組詳情路由
  static String groupDetailWithId(int groupId) => '$groupDetail/$groupId';
  
  /// 生成編輯群組路由
  static String editGroupWithId(int groupId) => '$editGroup/$groupId';
  
  /// 生成搜尋結果路由
  static String searchResultsWithQuery(String query) => '$searchResults?q=$query';
  
  /// 生成名片QR碼路由
  static String cardQrCodeWithId(int cardId) => '$cardQrCode/$cardId';
  
  /// 生成分享名片路由
  static String shareCardWithId(int cardId) => '$shareCard/$cardId';

  // ========== 路由參數鍵 ==========
  /// 名片ID參數鍵
  static const String cardIdParam = 'cardId';
  
  /// 群組ID參數鍵
  static const String groupIdParam = 'groupId';
  
  /// 搜尋查詢參數鍵
  static const String queryParam = 'q';
  
  /// 頁面參數鍵
  static const String pageParam = 'page';
  
  /// 排序參數鍵
  static const String sortParam = 'sort';
  
  /// 篩選參數鍵
  static const String filterParam = 'filter';
  
  /// 返回URL參數鍵
  static const String returnUrlParam = 'returnUrl';

  // ========== 路由守衛類型 ==========
  /// 需要認證的路由
  static const List<String> authRequiredRoutes = [
    myCards,
    createCard,
    editCard,
    groups,
    createGroup,
    editGroup,
    profile,
    editProfile,
    settings,
    favorites,
  ];
  
  /// 僅限訪客的路由
  static const List<String> guestOnlyRoutes = [
    login,
    register,
    forgotPassword,
    resetPassword,
  ];
  
  /// 公開路由（無需認證）
  static const List<String> publicRoutes = [
    splash,
    onboarding,
    publicCards,
    cardDetail,
    qrScanner,
    about,
    privacyPolicy,
    termsOfService,
  ];

  // ========== 工具方法 ==========
  /// 檢查路由是否需要認證
  static bool requiresAuth(String route) {
    return authRequiredRoutes.any((authRoute) => route.startsWith(authRoute));
  }
  
  /// 檢查路由是否僅限訪客
  static bool isGuestOnly(String route) {
    return guestOnlyRoutes.any((guestRoute) => route.startsWith(guestRoute));
  }
  
  /// 檢查路由是否為公開路由
  static bool isPublicRoute(String route) {
    return publicRoutes.any((publicRoute) => route.startsWith(publicRoute));
  }
  
  /// 從路由中提取ID參數
  static int? extractIdFromRoute(String route, String basePath) {
    if (!route.startsWith(basePath)) return null;
    
    final segments = route.substring(basePath.length).split('/');
    if (segments.length < 2) return null;
    
    return int.tryParse(segments[1]);
  }
  
  /// 從查詢參數中提取值
  static String? extractQueryParam(String route, String paramKey) {
    final uri = Uri.parse(route);
    return uri.queryParameters[paramKey];
  }
  
  /// 構建帶查詢參數的路由
  static String buildRouteWithQuery(String basePath, Map<String, String> queryParams) {
    if (queryParams.isEmpty) return basePath;
    
    final uri = Uri.parse(basePath);
    final newUri = uri.replace(queryParameters: queryParams);
    return newUri.toString();
  }
  
  /// 獲取路由的麵包屑導航
  static List<String> getBreadcrumbs(String route) {
    final segments = route.split('/').where((s) => s.isNotEmpty).toList();
    final breadcrumbs = <String>[];
    
    for (int i = 0; i < segments.length; i++) {
      final path = '/' + segments.take(i + 1).join('/');
      breadcrumbs.add(path);
    }
    
    return breadcrumbs;
  }
}