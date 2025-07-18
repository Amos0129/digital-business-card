class CardGroup {
  final int id;
  final String name;
  final DateTime? createdAt;
  final int? cardCount;

  CardGroup({
    required this.id,
    required this.name,
    this.createdAt,
    this.cardCount,
  });

  factory CardGroup.fromJson(Map<String, dynamic> json) {
    return CardGroup(
      id: json['id'],
      name: json['name'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      cardCount: json['cardCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
      'cardCount': cardCount,
    };
  }

  CardGroup copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    int? cardCount,
  }) {
    return CardGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      cardCount: cardCount ?? this.cardCount,
    );
  }

  @override
  String toString() {
    return 'CardGroup(id: $id, name: $name, cardCount: $cardCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// 群組請求DTO
class GroupRequest {
  final String name;

  GroupRequest({required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

// 名片群組關聯模型
class CardGroupRelation {
  final int id;
  final int cardId;
  final int groupId;
  final int userId;

  CardGroupRelation({
    required this.id,
    required this.cardId,
    required this.groupId,
    required this.userId,
  });

  factory CardGroupRelation.fromJson(Map<String, dynamic> json) {
    return CardGroupRelation(
      id: json['id'],
      cardId: json['cardId'],
      groupId: json['groupId'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'groupId': groupId,
      'userId': userId,
    };
  }
}

// 名片群組資訊DTO
class CardGroupInfo {
  final int groupId;
  final String groupName;

  CardGroupInfo({
    required this.groupId,
    required this.groupName,
  });

  factory CardGroupInfo.fromJson(Map<String, dynamic> json) {
    return CardGroupInfo(
      groupId: json['groupId'],
      groupName: json['groupName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
    };
  }
}

// 群組操作請求DTO
class GroupOperationRequest {
  final int cardId;
  final int groupId;

  GroupOperationRequest({
    required this.cardId,
    required this.groupId,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'groupId': groupId,
    };
  }
}

// 預設群組類型
enum DefaultGroupType {
  all('全部'),
  clients('客戶'),
  friends('朋友'),
  family('家人');

  const DefaultGroupType(this.displayName);
  final String displayName;
}

// 群組統計資訊
class GroupStats {
  final int totalGroups;
  final int totalCards;
  final int cardsWithoutGroup;
  final Map<String, int> groupCardCounts;

  GroupStats({
    required this.totalGroups,
    required this.totalCards,
    required this.cardsWithoutGroup,
    required this.groupCardCounts,
  });

  factory GroupStats.fromJson(Map<String, dynamic> json) {
    return GroupStats(
      totalGroups: json['totalGroups'] ?? 0,
      totalCards: json['totalCards'] ?? 0,
      cardsWithoutGroup: json['cardsWithoutGroup'] ?? 0,
      groupCardCounts: Map<String, int>.from(json['groupCardCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGroups': totalGroups,
      'totalCards': totalCards,
      'cardsWithoutGroup': cardsWithoutGroup,
      'groupCardCounts': groupCardCounts,
    };
  }
}