// lib/core/constants/api_endpoints.dart
/// API 端點配置
/// 
/// 統一管理所有後端 API 端點
/// 支援不同環境的 URL 配置
class ApiEndpoints {
  // 防止實例化
  ApiEndpoints._();

  // ========== 基礎配置 ==========
  /// 開發環境基礎 URL
  static const String _devBaseUrl = 'http://192.168.205.58:8080';
  
  /// 生產環境基礎 URL
  static const String _prodBaseUrl = 'https://api.digitalcard.com';
  
  /// 當前環境基礎 URL
  static const String baseUrl = _devBaseUrl; // TODO: 根據環境動態切換
  
  /// API 版本前綴
  static const String apiPrefix = '/api';
  
  /// 公開端點前綴
  static const String publicPrefix = '/pub';
  
  /// 私有端點前綴
  static const String privatePrefix = '/priv';

  // ========== 認證相關端點 ==========
  /// 使用者註冊
  static const String register = '$apiPrefix/user/register';
  
  /// 使用者登入
  static const String login = '$apiPrefix/user/login';
  
  /// 忘記密碼
  static const String forgotPassword = '$apiPrefix/user/forgot-password';
  
  /// 重設密碼
  static const String resetPassword = '$apiPrefix/user/reset-password';
  
  /// 獲取當前使用者資訊
  static const String userMe = '$apiPrefix/user/me';
  
  /// 檢查使用者是否存在
  static const String userExists = '$apiPrefix/user/exists';
  
  /// 根據 Email 查找使用者
  static const String userByEmail = '$apiPrefix/user/by-email';
  
  /// 更新顯示名稱
  static const String updateDisplayName = '$apiPrefix/user/display-name';
  
  /// 修改密碼
  static const String changePassword = '$apiPrefix/user/password';

  // ========== 名片相關端點 ==========
  /// 獲取我的名片列表
  static const String myCards = '$apiPrefix/cards/my';
  
  /// 建立我的名片
  static const String createMyCard = '$apiPrefix/cards/my';
  
  /// 更新名片
  static String updateCard(int cardId) => '$apiPrefix/cards/$cardId';
  
  /// 刪除名片
  static String deleteCard(int cardId) => '$apiPrefix/cards/$cardId';
  
  /// 獲取名片詳情
  static String getCard(int cardId) => '$apiPrefix/cards/$cardId';
  
  /// 搜尋公開名片
  static const String searchPublicCards = '$apiPrefix/cards/public/search';
  
  /// 更新名片公開狀態
  static String updateCardPublicStatus(int cardId) => '$apiPrefix/cards/$cardId/public';
  
  /// 上傳名片頭像
  static String uploadCardAvatar(int cardId) => '$apiPrefix/cards/$cardId/avatar';
  
  /// 清除名片頭像
  static String clearCardAvatar(int cardId) => '$apiPrefix/cards/$cardId/clear-avatar';

  // ========== 群組相關端點 ==========
  /// 獲取預設群組
  static const String defaultGroup = '$apiPrefix/group/default';
  
  /// 建立群組
  static const String createGroup = '$apiPrefix/group/create';
  
  /// 重新命名群組
  static String renameGroup(int groupId) => '$apiPrefix/group/rename/$groupId';
  
  /// 獲取使用者的群組列表
  static const String userGroups = '$apiPrefix/group/by-user';
  
  /// 刪除群組
  static String deleteGroup(int groupId) => '$apiPrefix/group/$groupId';

  // ========== 名片群組關聯端點 ==========
  /// 獲取名片所屬群組
  static const String userGroupOfCard = '$apiPrefix/card-group/user-group-of-card';
  
  /// 更改名片群組
  static const String changeCardGroup = '$apiPrefix/card-group/change';
  
  /// 添加到預設群組
  static const String addToDefaultGroup = '$apiPrefix/card-group/add-to-default';
  
  /// 添加名片到群組
  static const String addCardToGroup = '$apiPrefix/card-group/add';
  
  /// 從群組移除名片
  static const String removeCardFromGroup = '$apiPrefix/card-group/remove';
  
  /// 根據名片獲取群組
  static String getGroupsByCard(int cardId) => '$apiPrefix/card-group/by-card/$cardId';
  
  /// 根據群組獲取名片
  static String getCardsByGroup(int groupId) => '$apiPrefix/card-group/by-group/$groupId';
  
  /// 獲取使用者的名片和群組資料
  static const String cardsByUser = '$apiPrefix/card-group/by-user';

  // ========== 名片分享端點 ==========
  /// 分享名片
  static const String shareCard = '$apiPrefix/share/send';
  
  /// 獲取名片的分享記錄
  static String getSharesByCard(int cardId) => '$apiPrefix/share/by-card/$cardId';
  
  /// 獲取接收到的名片
  static const String getReceivedCards = '$apiPrefix/share/by-email';
  
  /// 刪除名片的分享記錄
  static String deleteSharesByCard(int cardId) => '$apiPrefix/share/by-card/$cardId';

  // ========== 工具方法 ==========
  /// 構建完整的 URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  /// 構建帶查詢參數的 URL
  static String buildUrlWithQuery(String endpoint, Map<String, dynamic> queryParams) {
    final uri = Uri.parse('$baseUrl$endpoint');
    final newUri = uri.replace(queryParameters: queryParams.map(
      (key, value) => MapEntry(key, value.toString()),
    ));
    return newUri.toString();
  }
  
  /// 檢查是否為絕對 URL
  static bool isAbsoluteUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }
  
  /// 處理相對 URL
  static String resolveUrl(String url) {
    if (isAbsoluteUrl(url)) {
      return url;
    }
    return '$baseUrl$url';
  }
}