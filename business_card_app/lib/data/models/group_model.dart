// lib/data/models/group_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

/// 群組資料模型
/// 
/// 使用 Freezed 包來創建不可變的資料類
/// 支援 JSON 序列化和反序列化
@freezed
class GroupModel with _$GroupModel {
  const factory GroupModel({
    required int id,
    @JsonKey(name: 'user_id') int? userId,
    required String name,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @Default(0) int cardCount,
    String? description,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);
}

/// 群組建立/更新請求模型
@freezed
class GroupRequest with _$GroupRequest {
  const factory GroupRequest({
    required String name,
    String? description,
  }) = _GroupRequest;

  factory GroupRequest.fromJson(Map<String, dynamic> json) =>
      _$GroupRequestFromJson(json);
}

/// 群組詳細資料模型
@freezed
class GroupDetailModel with _$GroupDetailModel {
  const factory GroupDetailModel({
    required GroupModel group,
    @Default([]) List<CardBasicInfo> cards,
    @Default(0) int totalCards,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
  }) = _GroupDetailModel;

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) =>
      _$GroupDetailModelFromJson(json);
}

/// 卡片基本資訊模型（用於群組中顯示）
@freezed
class CardBasicInfo with _$CardBasicInfo {
  const factory CardBasicInfo({
    required int id,
    required String name,
    String? company,
    String? phone,
    String? email,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
  }) = _CardBasicInfo;

  factory CardBasicInfo.fromJson(Map<String, dynamic> json) =>
      _$CardBasicInfoFromJson(json);
}

/// 群組統計模型
@freezed
class GroupStats with _$GroupStats {
  const factory GroupStats({
    @JsonKey(name: 'group_id') required int groupId,
    @Default(0) int totalCards,
    @Default(0) int publicCards,
    @Default(0) int privateCards,
    @JsonKey(name: 'last_updated') DateTime? lastUpdated,
    @Default(0) int recentlyAdded,
  }) = _GroupStats;

  factory GroupStats.fromJson(Map<String, dynamic> json) =>
      _$GroupStatsFromJson(json);
}

/// 群組模型擴展方法
extension GroupModelExtension on GroupModel {
  /// 檢查是否為預設群組
  bool get isDefaultGroup => name == '全部' || name == '所有名片';

  /// 檢查是否為系統預設群組
  bool get isSystemDefault {
    const systemGroups = ['全部', '客戶', '朋友', '家人', '同事', '商業夥伴'];
    return systemGroups.contains(name);
  }

  /// 檢查是否為新群組（建立後7天內）
  bool get isNewGroup {
    if (createdAt == null) return true;
    final daysSinceCreated = DateTime.now().difference(createdAt!).inDays;
    return daysSinceCreated <= 7;
  }

  /// 獲取建立天數
  int get daysSinceCreated {
    if (createdAt == null) return 0;
    return DateTime.now().difference(createdAt!).inDays;
  }

  /// 檢查是否為空群組
  bool get isEmpty => cardCount == 0;

  /// 檢查是否有卡片
  bool get hasCards => cardCount > 0;

  /// 轉換為 GroupRequest
  GroupRequest toRequest() {
    return GroupRequest(
      name: name,
      description: description,
    );
  }

  /// 複製群組並更新名稱
  GroupModel updateName(String newName) {
    return copyWith(name: newName);
  }

  /// 複製群組並更新描述
  GroupModel updateDescription(String? newDescription) {
    return copyWith(description: newDescription);
  }

  /// 複製群組並更新卡片數量
  GroupModel updateCardCount(int count) {
    return copyWith(cardCount: count);
  }
}

/// 群組請求擴展方法
extension GroupRequestExtension on GroupRequest {
  /// 檢查名稱是否有效
  bool get isNameValid => name.isNotEmpty && name.length <= 30;

  /// 檢查是否為系統預設群組名稱
  bool get isSystemGroupName {
    const systemGroups = ['全部', '客戶', '朋友', '家人', '同事', '商業夥伴'];
    return systemGroups.contains(name);
  }

  /// 轉換為 JSON
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty) 'description': description,
    };
  }
}

/// 群組詳細資料擴展方法
extension GroupDetailModelExtension on GroupDetailModel {
  /// 獲取公開卡片數量
  int get publicCardCount {
    return cards.where((card) => card.isPublic).length;
  }

  /// 獲取私人卡片數量
  int get privateCardCount {
    return cards.where((card) => !card.isPublic).length;
  }

  /// 檢查是否有公開卡片
  bool get hasPublicCards => publicCardCount > 0;

  /// 檢查是否有私人卡片
  bool get hasPrivateCards => privateCardCount > 0;

  /// 獲取最近添加的卡片（7天內）
  List<CardBasicInfo> get recentCards {
    // 這裡需要根據實際的卡片創建時間來過濾
    // 由於 CardBasicInfo 沒有創建時間，這裡返回空列表
    return [];
  }
}

/// 卡片基本資訊擴展方法
extension CardBasicInfoExtension on CardBasicInfo {
  /// 檢查是否有頭像
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// 檢查是否有完整的聯絡資訊
  bool get hasContactInfo {
    return (phone != null && phone!.isNotEmpty) ||
           (email != null && email!.isNotEmpty);
  }

  /// 檢查是否有公司資訊
  bool get hasCompanyInfo {
    return company != null && company!.isNotEmpty;
  }

  /// 獲取顯示名稱
  String get displayName {
    if (hasCompanyInfo) {
      return '$name - $company';
    }
    return name;
  }

  /// 獲取副標題
  String? get subtitle {
    if (hasCompanyInfo) return company;
    if (phone != null && phone!.isNotEmpty) return phone;
    if (email != null && email!.isNotEmpty) return email;
    return null;
  }
}

/// 群組類型枚舉
enum GroupType {
  default_('default', '預設群組'),
  custom('custom', '自訂群組'),
  system('system', '系統群組');

  const GroupType(this.value, this.displayName);
  final String value;
  final String displayName;

  static GroupType fromString(String value) {
    return GroupType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => GroupType.custom,
    );
  }
}

/// 群組排序選項
enum GroupSortOption {
  name('name', '名稱'),
  cardCount('cardCount', '卡片數量'),
  createdAt('createdAt', '建立時間');

  const GroupSortOption(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 群組過濾選項
enum GroupFilterOption {
  all('all', '全部群組'),
  hasCards('hasCards', '有卡片的群組'),
  empty('empty', '空群組'),
  system('system', '系統群組'),
  custom('custom', '自訂群組');

  const GroupFilterOption(this.value, this.displayName);
  final String value;
  final String displayName;
}