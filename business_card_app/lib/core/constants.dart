class AppConstants {
  // API相關
  static const String baseUrl = 'http://192.168.0.170:5566';
  static const String apiPrefix = '/api';
  
  // 本地儲存Key
  static const String keyJwtToken = 'jwt_token';
  static const String keyUserData = 'user_data';
  static const String keyRememberMe = 'remember_me';
  
  // 名片樣式
  static const List<String> cardStyles = [
    'default',
    'minimal',
    'pink_card',
    'mint_card',
  ];
  
  // 社交媒體
  static const List<String> socialPlatforms = [
    'facebook',
    'instagram',
    'line',
    'threads',
  ];
  
  // 預設群組
  static const List<String> defaultGroups = [
    '客戶',
    '朋友',
    '家人',
  ];
  
  // 錯誤訊息
  static const String errorNetwork = '網路連線錯誤，請檢查您的網路設定';
  static const String errorUnknown = '發生未知錯誤，請稍後再試';
  static const String errorAuth = '身份驗證失敗，請重新登入';
  static const String errorNotFound = '找不到指定的資源';
  
  // 成功訊息
  static const String successLogin = '登入成功';
  static const String successRegister = '註冊成功';
  static const String successSaved = '儲存成功';
  static const String successDeleted = '刪除成功';
  
  // 頁面標題
  static const String titleLogin = '登入';
  static const String titleRegister = '註冊';
  static const String titleHome = '首頁';
  static const String titleCards = '名片';
  static const String titleGroups = '群組';
  static const String titleProfile = '個人資料';
  static const String titleSettings = '設定';
  
  // 驗證規則
  static const int minPasswordLength = 6;
  static const int maxGroupNameLength = 20;
  static const int maxCardNameLength = 50;
  
  // 圖片
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
}

// 路由常數
class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String cards = '/cards';
  static const String cardDetail = '/card-detail';
  static const String editCard = '/edit-card';
  static const String groups = '/groups';
  static const String groupDetail = '/group-detail';
  static const String profile = '/profile';
  static const String qrScanner = '/qr-scanner';
  static const String search = '/search';
}

// API端點
class ApiEndpoints {
  // 使用者相關
  static const String login = '/api/user/login';
  static const String register = '/api/user/register';
  static const String me = '/api/user/me';
  static const String forgotPassword = '/api/user/forgot-password';
  static const String resetPassword = '/api/user/reset-password';
  static const String updateDisplayName = '/api/user/display-name';
  static const String changePassword = '/api/user/password';
  
  // 名片相關
  static const String myCards = '/api/cards/my';
  static const String createCard = '/api/cards/my';
  static const String searchPublicCards = '/api/cards/public/search';
  static String cardById(int id) => '/api/cards/$id';
  static String updateCard(int id) => '/api/cards/$id';
  static String deleteCard(int id) => '/api/cards/$id';
  static String uploadAvatar(int id) => '/api/cards/$id/avatar';
  static String clearAvatar(int id) => '/api/cards/$id/clear-avatar';
  static String updateCardPublic(int id) => '/api/cards/$id/public';
  
  // 群組相關
  static const String groupsByUser = '/api/group/by-user';
  static const String createGroup = '/api/group/create';
  static const String defaultGroup = '/api/group/default';
  static String renameGroup(int id) => '/api/group/rename/$id';
  static String deleteGroup(int id) => '/api/group/$id';
  
  // 名片群組關聯
  static const String cardGroupsByUser = '/api/card-group/by-user';
  static const String userGroupOfCard = '/api/card-group/user-group-of-card';
  static const String changeCardGroup = '/api/card-group/change';
  static const String addCardToGroup = '/api/card-group/add';
  static const String removeCardFromGroup = '/api/card-group/remove';
  static const String addToDefaultGroup = '/api/card-group/add-to-default';
  static String cardsByGroup(int id) => '/api/card-group/by-group/$id';
  static String groupsByCard(int id) => '/api/card-group/by-card/$id';
}