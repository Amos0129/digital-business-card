import 'package:uuid/uuid.dart';
import 'group_model.dart';

class UnifiedCard {
  static const int defaultGroupId = -1;
  static const String defaultGroupName = '全部';

  final int? cardId;
  final int? groupId;
  final String id; // UUID
  final String name;
  final String? avatarUrl;
  final String? company;
  final String? phone;
  final String? email;
  final String? address;
  final String? initialRemark;
  final String? group;
  final String? style;
  final bool isScanned;
  final bool isPaperBased;
  final DateTime createdAt;

  // 社群媒體
  final bool hasFb;
  final bool hasIg;
  final bool hasLine;
  final bool hasThreads;
  final String? fbUrl;
  final String? igUrl;
  final String? lineUrl;
  final String? threadsUrl;

  UnifiedCard({
    this.cardId,
    this.groupId,
    String? id,
    required this.name,
    this.avatarUrl,
    this.company,
    this.phone,
    this.email,
    this.address,
    this.initialRemark,
    this.group,
    this.style,
    this.isScanned = false,
    this.isPaperBased = false,
    DateTime? createdAt,
    this.hasFb = false,
    this.hasIg = false,
    this.hasLine = false,
    this.hasThreads = false,
    this.fbUrl,
    this.igUrl,
    this.lineUrl,
    this.threadsUrl,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// ✅ 安全轉換 getter
  String get safeName => name.trim();
  String get safeCompany => company ?? '';
  String get safePhone => phone ?? '';
  String get safeEmail => email ?? '';
  String get safeAddress => address ?? '';
  String get safeRemark => initialRemark ?? '';

  /// ✅ 全文索引搜尋欄位
  String get fullText =>
      '$safeName $safeCompany $safePhone $safeEmail $safeAddress'.toLowerCase();

  /// ✅ 判斷是否為預設群組（全部）
  bool get isInDefaultGroup => groupId == defaultGroupId;

  /// ✅ 解析卡片 JSON（不含群組名稱）
  factory UnifiedCard.fromCardDetailJson(Map<String, dynamic> json) {
    return UnifiedCard(
      cardId: json['id'],
      groupId: json['groupId'],
      id: json['id'].toString(),
      name: json['name'] ?? '',
      company: json['company'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      hasFb: json['facebook'] is bool ? json['facebook'] : false,
      hasIg: json['instagram'] is bool ? json['instagram'] : false,
      hasLine: json['line'] is bool ? json['line'] : false,
      hasThreads: json['threads'] is bool ? json['threads'] : false,
      fbUrl: json['facebookUrl'],
      igUrl: json['instagramUrl'],
      lineUrl: json['lineUrl'],
      threadsUrl: json['threadsUrl'],
      avatarUrl:
          json['avatarUrl'] != null && json['avatarUrl'].toString().isNotEmpty
          ? 'http://192.168.205.54:5566${json['avatarUrl']}'
          : null,

      style: json['style'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  /// ✅ 加入 group name fallback 版本
  factory UnifiedCard.fromCardDetailJsonWithGroups(
    Map<String, dynamic> json,
    List<GroupModel> groups,
  ) {
    final groupId = json['groupId'];
    final groupName = groupId == null
        ? '未分類'
        : groups
              .firstWhere(
                (g) => g.id == groupId,
                orElse: () => GroupModel(id: groupId, name: '未知群組'),
              )
              .name;

    final parsed = UnifiedCard.fromCardDetailJson(json);

    return parsed.copyWith(
      group: groupName,
      groupId: groupId,
      style: json['style'],
    );
  }

  /// ✅ 用於掃描後加入預設群組用
  factory UnifiedCard.defaultGroup({
    required int cardId,
    required String name,
    String? phone,
    String? email,
    String? company,
    String? address,
  }) {
    return UnifiedCard(
      cardId: cardId,
      id: cardId.toString(),
      name: name,
      phone: phone,
      email: email,
      company: company,
      address: address,
      groupId: defaultGroupId,
      group: defaultGroupName,
      isScanned: true,
    );
  }

  /// ✅ copyWith 支援部分覆寫
  UnifiedCard copyWith({
    int? cardId,
    int? groupId,
    String? id,
    String? name,
    String? avatarUrl,
    String? company,
    String? phone,
    String? email,
    String? address,
    String? initialRemark,
    String? group,
    String? style,
    bool? isScanned,
    bool? isPaperBased,
    DateTime? createdAt,
    bool? hasFb,
    bool? hasIg,
    bool? hasLine,
    bool? hasThreads,
    String? fbUrl,
    String? igUrl,
    String? lineUrl,
    String? threadsUrl,
  }) {
    return UnifiedCard(
      cardId: cardId ?? this.cardId,
      groupId: groupId ?? this.groupId,
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      initialRemark: initialRemark ?? this.initialRemark,
      group: group ?? this.group,
      style: style ?? this.style,
      isScanned: isScanned ?? this.isScanned,
      isPaperBased: isPaperBased ?? this.isPaperBased,
      createdAt: createdAt ?? this.createdAt,
      hasFb: hasFb ?? this.hasFb,
      hasIg: hasIg ?? this.hasIg,
      hasLine: hasLine ?? this.hasLine,
      hasThreads: hasThreads ?? this.hasThreads,
      fbUrl: fbUrl ?? this.fbUrl,
      igUrl: igUrl ?? this.igUrl,
      lineUrl: lineUrl ?? this.lineUrl,
      threadsUrl: threadsUrl ?? this.threadsUrl,
    );
  }
}
