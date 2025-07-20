// lib/data/models/card_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../constants/app_constants.dart';

part 'card_model.freezed.dart';
part 'card_model.g.dart';

/// 名片資料模型
/// 
/// 使用 Freezed 包來創建不可變的資料類
/// 支援 JSON 序列化和反序列化
@freezed
class CardModel with _$CardModel {
  const factory CardModel({
    required int id,
    @JsonKey(name: 'user_id') int? userId,
    required String name,
    String? phone,
    String? email,
    String? company,
    String? position,
    String? address,
    @Default('modern') String style,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'facebook_url') String? facebookUrl,
    @JsonKey(name: 'instagram_url') String? instagramUrl,
    @JsonKey(name: 'line_url') String? lineUrl,
    @JsonKey(name: 'threads_url') String? threadsUrl,
    @Default(false) bool facebook,
    @Default(false) bool instagram,
    @Default(false) bool line,
    @Default(false) bool threads,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _CardModel;

  factory CardModel.fromJson(Map<String, dynamic> json) =>
      _$CardModelFromJson(json);
}

/// 名片建立/更新請求模型
@freezed
class CardRequest with _$CardRequest {
  const factory CardRequest({
    required String name,
    String? phone,
    String? email,
    String? company,
    String? position,
    String? address,
    @Default('modern') String style,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'facebook_url') String? facebookUrl,
    @JsonKey(name: 'instagram_url') String? instagramUrl,
    @JsonKey(name: 'line_url') String? lineUrl,
    @JsonKey(name: 'threads_url') String? threadsUrl,
    @Default(false) bool facebook,
    @Default(false) bool instagram,
    @Default(false) bool line,
    @Default(false) bool threads,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
  }) = _CardRequest;

  factory CardRequest.fromJson(Map<String, dynamic> json) =>
      _$CardRequestFromJson(json);
}

/// 名片詳細資料模型（包含額外資訊）
@freezed
class CardDetailModel with _$CardDetailModel {
  const factory CardDetailModel({
    required CardModel card,
    @Default(0) int viewCount,
    @Default(0) int shareCount,
    @Default(false) bool isFavorite,
    @JsonKey(name: 'group_info') GroupInfo? groupInfo,
    @JsonKey(name: 'social_links') @Default([]) List<SocialLink> socialLinks,
    @Default([]) List<String> tags,
  }) = _CardDetailModel;

  factory CardDetailModel.fromJson(Map<String, dynamic> json) =>
      _$CardDetailModelFromJson(json);
}

/// 群組資訊模型
@freezed
class GroupInfo with _$GroupInfo {
  const factory GroupInfo({
    required int id,
    required String name,
    String? description,
    @Default(0) int cardCount,
  }) = _GroupInfo;

  factory GroupInfo.fromJson(Map<String, dynamic> json) =>
      _$GroupInfoFromJson(json);
}

/// 社交媒體連結模型
@freezed
class SocialLink with _$SocialLink {
  const factory SocialLink({
    required String platform,
    required String url,
    String? username,
    @Default(true) bool isActive,
  }) = _SocialLink;

  factory SocialLink.fromJson(Map<String, dynamic> json) =>
      _$SocialLinkFromJson(json);
}

/// 名片搜尋請求模型
@freezed
class CardSearchRequest with _$CardSearchRequest {
  const factory CardSearchRequest({
    String? query,
    List<String>? tags,
    String? company,
    String? position,
    @Default(1) int page,
    @Default(20) int pageSize,
    @Default('name') String sortBy, // 'name', 'company', 'created_at'
    @Default('asc') String sortOrder, // 'asc', 'desc'
    @Default(false) bool publicOnly,
  }) = _CardSearchRequest;

  factory CardSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$CardSearchRequestFromJson(json);
}

/// 名片分享模型
@freezed
class CardShare with _$CardShare {
  const factory CardShare({
    required int id,
    @JsonKey(name: 'card_id') required int cardId,
    @JsonKey(name: 'shared_with_email') required String sharedWithEmail,
    @JsonKey(name: 'shared_at') required DateTime sharedAt,
    String? message,
    @Default(false) bool isAccepted,
    @JsonKey(name: 'accepted_at') DateTime? acceptedAt,
  }) = _CardShare;

  factory CardShare.fromJson(Map<String, dynamic> json) =>
      _$CardShareFromJson(json);
}

/// 名片統計模型
@freezed
class CardStats with _$CardStats {
  const factory CardStats({
    @JsonKey(name: 'card_id') required int cardId,
    @Default(0) int views,
    @Default(0) int shares,
    @Default(0) int saves,
    @Default(0) int clicks,
    @JsonKey(name: 'last_viewed') DateTime? lastViewed,
    @Default([]) List<ViewHistory> viewHistory,
  }) = _CardStats;

  factory CardStats.fromJson(Map<String, dynamic> json) =>
      _$CardStatsFromJson(json);
}

/// 瀏覽歷史模型
@freezed
class ViewHistory with _$ViewHistory {
  const factory ViewHistory({
    @JsonKey(name: 'viewed_at') required DateTime viewedAt,
    @JsonKey(name: 'viewer_ip') String? viewerIp,
    @JsonKey(name: 'viewer_location') String? viewerLocation,
    String? platform,
    String? browser,
  }) = _ViewHistory;

  factory ViewHistory.fromJson(Map<String, dynamic> json) =>
      _$ViewHistoryFromJson(json);
}

/// 名片樣式枚舉
enum CardStyle {
  classic('classic', '經典'),
  modern('modern', '現代'),
  elegant('elegant', '優雅'),
  minimal('minimal', '極簡'),
  creative('creative', '創意'),
  professional('professional', '專業');

  const CardStyle(this.value, this.displayName);
  final String value;
  final String displayName;

  static CardStyle fromString(String value) {
    return CardStyle.values.firstWhere(
      (style) => style.value == value,
      orElse: () => CardStyle.modern,
    );
  }
}

/// 名片模型擴展方法
extension CardModelExtension on CardModel {
  /// 獲取名片樣式枚舉
  CardStyle get cardStyle => CardStyle.fromString(style);

  /// 檢查是否有頭像
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// 檢查是否有完整的聯絡資訊
  bool get hasCompleteContactInfo {
    return phone != null && phone!.isNotEmpty ||
           email != null && email!.isNotEmpty;
  }

  /// 檢查是否有公司資訊
  bool get hasCompanyInfo {
    return company != null && company!.isNotEmpty ||
           position != null && position!.isNotEmpty;
  }

  /// 獲取社交媒體連結列表
  List<SocialLink> get socialMediaLinks {
    final links = <SocialLink>[];
    
    if (facebook && facebookUrl != null && facebookUrl!.isNotEmpty) {
      links.add(SocialLink(platform: 'facebook', url: facebookUrl!));
    }
    
    if (instagram && instagramUrl != null && instagramUrl!.isNotEmpty) {
      links.add(SocialLink(platform: 'instagram', url: instagramUrl!));
    }
    
    if (line && lineUrl != null && lineUrl!.isNotEmpty) {
      links.add(SocialLink(platform: 'line', url: lineUrl!));
    }
    
    if (threads && threadsUrl != null && threadsUrl!.isNotEmpty) {
      links.add(SocialLink(platform: 'threads', url: threadsUrl!));
    }
    
    return links;
  }

  /// 獲取啟用的社交媒體平台數量
  int get activeSocialPlatforms {
    int count = 0;
    if (facebook) count++;
    if (instagram) count++;
    if (line) count++;
    if (threads) count++;
    return count;
  }

  /// 檢查是否為新名片（建立後7天內）
  bool get isNewCard {
    if (createdAt == null) return true;
    final daysSinceCreated = DateTime.now().difference(createdAt!).inDays;
    return daysSinceCreated <= 7;
  }

  /// 獲取建立天數
  int get daysSinceCreated {
    if (createdAt == null) return 0;
    return DateTime.now().difference(createdAt!).inDays;
  }

  /// 檢查是否最近有更新（7天內）
  bool get hasRecentUpdate {
    if (updatedAt == null || createdAt == null) return false;
    return updatedAt!.isAfter(createdAt!.add(const Duration(days: 1)));
  }

  /// 獲取名片完整度百分比
  double get completenessPercentage {
    int totalFields = 8; // name, phone, email, company, position, address, avatar, social
    int filledFields = 1; // name is required
    
    if (phone != null && phone!.isNotEmpty) filledFields++;
    if (email != null && email!.isNotEmpty) filledFields++;
    if (company != null && company!.isNotEmpty) filledFields++;
    if (position != null && position!.isNotEmpty) filledFields++;
    if (address != null && address!.isNotEmpty) filledFields++;
    if (hasAvatar) filledFields++;
    if (activeSocialPlatforms > 0) filledFields++;
    
    return (filledFields / totalFields) * 100;
  }

  /// 檢查名片資料是否完整
  bool get isComplete => completenessPercentage >= 70.0;

  /// 轉換為 CardRequest
  CardRequest toRequest() {
    return CardRequest(
      name: name,
      phone: phone,
      email: email,
      company: company,
      position: position,
      address: address,
      style: style,
      avatarUrl: avatarUrl,
      facebookUrl: facebookUrl,
      instagramUrl: instagramUrl,
      lineUrl: lineUrl,
      threadsUrl: threadsUrl,
      facebook: facebook,
      instagram: instagram,
      line: line,
      threads: threads,
      isPublic: isPublic,
    );
  }

  /// 生成QR碼內容
  String generateQrContent() {
    return 'https://digitalcard.app/card/$id';
  }

  /// 生成vCard格式
  String generateVCard() {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    buffer.writeln('FN:$name');
    
    if (company != null && company!.isNotEmpty) {
      buffer.writeln('ORG:$company');
    }
    
    if (position != null && position!.isNotEmpty) {
      buffer.writeln('TITLE:$position');
    }
    
    if (phone != null && phone!.isNotEmpty) {
      buffer.writeln('TEL:$phone');
    }
    
    if (email != null && email!.isNotEmpty) {
      buffer.writeln('EMAIL:$email');
    }
    
    if (address != null && address!.isNotEmpty) {
      buffer.writeln('ADR:;;$address;;;;');
    }
    
    buffer.writeln('URL:${generateQrContent()}');
    buffer.writeln('END:VCARD');
    
    return buffer.toString();
  }

  /// 複製名片並更新特定欄位
  CardModel updateField(String field, dynamic value) {
    switch (field) {
      case 'name':
        return copyWith(name: value as String);
      case 'phone':
        return copyWith(phone: value as String?);
      case 'email':
        return copyWith(email: value as String?);
      case 'company':
        return copyWith(company: value as String?);
      case 'position':
        return copyWith(position: value as String?);
      case 'address':
        return copyWith(address: value as String?);
      case 'style':
        return copyWith(style: value as String);
      case 'isPublic':
        return copyWith(isPublic: value as bool);
      default:
        return this;
    }
  }

  /// 切換公開狀態
  CardModel togglePublic() {
    return copyWith(isPublic: !isPublic);
  }

  /// 更新社交媒體設定
  CardModel updateSocialMedia({
    bool? facebook,
    bool? instagram,
    bool? line,
    bool? threads,
    String? facebookUrl,
    String? instagramUrl,
    String? lineUrl,
    String? threadsUrl,
  }) {
    return copyWith(
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      line: line ?? this.line,
      threads: threads ?? this.threads,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      lineUrl: lineUrl ?? this.lineUrl,
      threadsUrl: threadsUrl ?? this.threadsUrl,
    );
  }
}

/// 名片搜尋請求擴展方法
extension CardSearchRequestExtension on CardSearchRequest {
  /// 檢查是否有搜尋條件
  bool get hasSearchCriteria {
    return (query != null && query!.isNotEmpty) ||
           (tags != null && tags!.isNotEmpty) ||
           (company != null && company!.isNotEmpty) ||
           (position != null && position!.isNotEmpty);
  }

  /// 獲取搜尋條件總數
  int get searchCriteriaCount {
    int count = 0;
    if (query != null && query!.isNotEmpty) count++;
    if (tags != null && tags!.isNotEmpty) count++;
    if (company != null && company!.isNotEmpty) count++;
    if (position != null && position!.isNotEmpty) count++;
    return count;
  }

  /// 轉換為查詢參數
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    if (query != null && query!.isNotEmpty) {
      params['query'] = query;
    }

    if (tags != null && tags!.isNotEmpty) {
      params['tags'] = tags!.join(',');
    }

    if (company != null && company!.isNotEmpty) {
      params['company'] = company;
    }

    if (position != null && position!.isNotEmpty) {
      params['position'] = position;
    }

    if (publicOnly) {
      params['publicOnly'] = publicOnly;
    }

    return params;
  }

  /// 重設搜尋條件
  CardSearchRequest reset() {
    return const CardSearchRequest();
  }

  /// 更新查詢字串
  CardSearchRequest updateQuery(String newQuery) {
    return copyWith(query: newQuery);
  }

  /// 更新分頁
  CardSearchRequest updatePage(int newPage) {
    return copyWith(page: newPage);
  }

  /// 更新排序
  CardSearchRequest updateSort(String newSortBy, String newSortOrder) {
    return copyWith(sortBy: newSortBy, sortOrder: newSortOrder);
  }
}

/// 名片統計擴展方法
extension CardStatsExtension on CardStats {
  /// 獲取平均每日瀏覽量
  double get averageViewsPerDay {
    if (viewHistory.isEmpty) return 0.0;
    
    final firstView = viewHistory.first.viewedAt;
    final daysSinceFirstView = DateTime.now().difference(firstView).inDays;
    
    if (daysSinceFirstView <= 0) return views.toDouble();
    return views / daysSinceFirstView;
  }

  /// 獲取最近7天的瀏覽量
  int get recentViews {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return viewHistory
        .where((view) => view.viewedAt.isAfter(sevenDaysAgo))
        .length;
  }

  /// 檢查是否為熱門名片（瀏覽量大於平均值）
  bool isPopular(double averageViews) {
    return views > averageViews;
  }

  /// 獲取互動率（分享數/瀏覽數）
  double get engagementRate {
    if (views == 0) return 0.0;
    return (shares + saves + clicks) / views;
  }

  /// 檢查是否有活動（最近30天內有瀏覽）
  bool get hasRecentActivity {
    if (lastViewed == null) return false;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return lastViewed!.isAfter(thirtyDaysAgo);
  }
}