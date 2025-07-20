// lib/data/models/user_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// 使用者資料模型
/// 
/// 使用 Freezed 包來創建不可變的資料類
/// 支援 JSON 序列化和反序列化
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String email,
    required String name,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// 使用者註冊請求模型
@freezed
class UserRegisterRequest with _$UserRegisterRequest {
  const factory UserRegisterRequest({
    required String email,
    required String password,
    String? name,
  }) = _UserRegisterRequest;

  factory UserRegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$UserRegisterRequestFromJson(json);
}

/// 使用者登入請求模型
@freezed
class UserLoginRequest with _$UserLoginRequest {
  const factory UserLoginRequest({
    required String email,
    required String password,
  }) = _UserLoginRequest;

  factory UserLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$UserLoginRequestFromJson(json);
}

/// 使用者登入響應模型
@freezed
class UserLoginResponse with _$UserLoginResponse {
  const factory UserLoginResponse({
    required int id,
    required String email,
    required String name,
    required String token,
  }) = _UserLoginResponse;

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$UserLoginResponseFromJson(json);
}

/// 忘記密碼請求模型
@freezed
class ForgotPasswordRequest with _$ForgotPasswordRequest {
  const factory ForgotPasswordRequest({
    required String email,
  }) = _ForgotPasswordRequest;

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);
}

/// 重設密碼請求模型
@freezed
class ResetPasswordRequest with _$ResetPasswordRequest {
  const factory ResetPasswordRequest({
    required String token,
    @JsonKey(name: 'new_password') required String newPassword,
  }) = _ResetPasswordRequest;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);
}

/// 更新使用者資料請求模型
@freezed
class UpdateUserRequest with _$UpdateUserRequest {
  const factory UpdateUserRequest({
    String? name,
    String? email,
  }) = _UpdateUserRequest;

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestFromJson(json);
}

/// 修改密碼請求模型
@freezed
class ChangePasswordRequest with _$ChangePasswordRequest {
  const factory ChangePasswordRequest({
    @JsonKey(name: 'old_password') required String oldPassword,
    @JsonKey(name: 'new_password') required String newPassword,
  }) = _ChangePasswordRequest;

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);
}

/// 使用者設定模型
@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default(true) bool notificationsEnabled,
    @Default(false) bool biometricEnabled,
    @Default('zh') String language,
    @Default('system') String themeMode,
    @Default(true) bool autoBackup,
    @Default(false) bool shareAnalytics,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

/// 使用者統計資料模型
@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    @Default(0) int totalCards,
    @Default(0) int publicCards,
    @Default(0) int totalGroups,
    @Default(0) int totalShares,
    @Default(0) int profileViews,
    @JsonKey(name: 'join_date') DateTime? joinDate,
    @JsonKey(name: 'last_active') DateTime? lastActive,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
}

/// 使用者活動記錄模型
@freezed
class UserActivity with _$UserActivity {
  const factory UserActivity({
    required int id,
    required String action,
    required String description,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _UserActivity;

  factory UserActivity.fromJson(Map<String, dynamic> json) =>
      _$UserActivityFromJson(json);
}

/// 使用者偏好設定模型
@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default('grid') String cardDisplayMode, // 'grid', 'list'
    @Default('name') String defaultSort, // 'name', 'date', 'company'
    @Default(false) bool enableSounds,
    @Default(true) bool enableHaptics,
    @Default(true) bool showTutorials,
    @Default(20) int pageSize,
    @Default(30) int cacheExpirationDays,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

/// 使用者擴展方法
extension UserModelExtension on UserModel {
  /// 獲取使用者顯示名稱
  String get displayName {
    if (name.isNotEmpty) return name;
    return email.split('@').first;
  }

  /// 獲取使用者初始字母
  String get initials {
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  /// 檢查是否為新使用者（註冊後7天內）
  bool get isNewUser {
    if (createdAt == null) return true;
    final daysSinceJoin = DateTime.now().difference(createdAt!).inDays;
    return daysSinceJoin <= 7;
  }

  /// 獲取加入天數
  int get daysSinceJoined {
    if (createdAt == null) return 0;
    return DateTime.now().difference(createdAt!).inDays;
  }

  /// 檢查最後更新是否超過指定天數
  bool isLastUpdateOlderThan(int days) {
    if (updatedAt == null) return true;
    final daysSinceUpdate = DateTime.now().difference(updatedAt!).inDays;
    return daysSinceUpdate > days;
  }

  /// 複製並更新姓名
  UserModel updateName(String newName) {
    return copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );
  }

  /// 複製並更新電子郵件
  UserModel updateEmail(String newEmail) {
    return copyWith(
      email: newEmail,
      updatedAt: DateTime.now(),
    );
  }

  /// 轉換為 Map（用於 API 請求）
  Map<String, dynamic> toUpdateRequest() {
    return {
      'name': name,
      'email': email,
    };
  }

  /// 檢查資料是否完整
  bool get isProfileComplete {
    return name.isNotEmpty && email.isNotEmpty;
  }
}

/// 使用者設定擴展方法
extension UserSettingsExtension on UserSettings {
  /// 檢查是否啟用深色模式
  bool get isDarkMode {
    return themeMode == 'dark';
  }

  /// 檢查是否使用系統主題
  bool get isSystemTheme {
    return themeMode == 'system';
  }

  /// 檢查是否為中文語言
  bool get isChineseLanguage {
    return language == 'zh';
  }

  /// 獲取主題模式枚舉
  ThemeMode get themeModeEnum {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// 切換通知設定
  UserSettings toggleNotifications() {
    return copyWith(notificationsEnabled: !notificationsEnabled);
  }

  /// 切換生物識別設定
  UserSettings toggleBiometric() {
    return copyWith(biometricEnabled: !biometricEnabled);
  }

  /// 更新主題模式
  UserSettings updateThemeMode(String newThemeMode) {
    return copyWith(themeMode: newThemeMode);
  }

  /// 更新語言
  UserSettings updateLanguage(String newLanguage) {
    return copyWith(language: newLanguage);
  }

  /// 重設為預設值
  UserSettings resetToDefaults() {
    return const UserSettings();
  }
}

/// 使用者統計擴展方法
extension UserStatsExtension on UserStats {
  /// 獲取平均每日名片數量
  double get averageCardsPerDay {
    if (joinDate == null || totalCards == 0) return 0.0;
    final daysSinceJoin = DateTime.now().difference(joinDate!).inDays;
    if (daysSinceJoin <= 0) return totalCards.toDouble();
    return totalCards / daysSinceJoin;
  }

  /// 獲取公開名片比例
  double get publicCardRatio {
    if (totalCards == 0) return 0.0;
    return publicCards / totalCards;
  }

  /// 檢查是否為活躍使用者（最近7天內有活動）
  bool get isActiveUser {
    if (lastActive == null) return false;
    final daysSinceActive = DateTime.now().difference(lastActive!).inDays;
    return daysSinceActive <= 7;
  }

  /// 獲取使用者等級（基於名片數量）
  String get userLevel {
    if (totalCards >= 100) return '專家';
    if (totalCards >= 50) return '達人';
    if (totalCards >= 20) return '熟練';
    if (totalCards >= 5) return '新手';
    return '初學者';
  }

  /// 獲取下一個等級所需名片數量
  int get cardsToNextLevel {
    if (totalCards >= 100) return 0;
    if (totalCards >= 50) return 100 - totalCards;
    if (totalCards >= 20) return 50 - totalCards;
    if (totalCards >= 5) return 20 - totalCards;
    return 5 - totalCards;
  }
}

/// 使用者活動類型枚舉
enum UserActivityType {
  login('登入'),
  logout('登出'),
  createCard('建立名片'),
  editCard('編輯名片'),
  deleteCard('刪除名片'),
  shareCard('分享名片'),
  createGroup('建立群組'),
  editGroup('編輯群組'),
  deleteGroup('刪除群組'),
  updateProfile('更新個人資料'),
  changePassword('修改密碼');

  const UserActivityType(this.displayName);
  final String displayName;
}

/// 使用者活動擴展方法
extension UserActivityExtension on UserActivity {
  /// 獲取活動類型
  UserActivityType? get activityType {
    try {
      return UserActivityType.values.firstWhere(
        (type) => type.name == action,
      );
    } catch (e) {
      return null;
    }
  }

  /// 獲取格式化的時間
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} 天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} 小時前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} 分鐘前';
    } else {
      return '剛剛';
    }
  }

  /// 檢查是否為今天的活動
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  /// 獲取活動圖示
  String get activityIcon {
    switch (activityType) {
      case UserActivityType.login:
        return '🔑';
      case UserActivityType.logout:
        return '🚪';
      case UserActivityType.createCard:
        return '📇';
      case UserActivityType.editCard:
        return '✏️';
      case UserActivityType.deleteCard:
        return '🗑️';
      case UserActivityType.shareCard:
        return '📤';
      case UserActivityType.createGroup:
        return '📁';
      case UserActivityType.editGroup:
        return '📝';
      case UserActivityType.deleteGroup:
        return '🗂️';
      case UserActivityType.updateProfile:
        return '👤';
      case UserActivityType.changePassword:
        return '🔒';
      case null:
        return '📋';
    }
  }
}