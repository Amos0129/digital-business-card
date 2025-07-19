// lib/models/group.dart
import 'card.dart';

// 基本群組模型
class CardGroup {
  final int id;
  final String name;
  final DateTime createdAt;
  final int? userId;

  CardGroup({
    required this.id,
    required this.name,
    required this.createdAt,
    this.userId,
  });

  factory CardGroup.fromJson(Map<String, dynamic> json) {
    return CardGroup(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }
}

// 帶有名片的群組
class CardWithGroup {
  final BusinessCard card;
  final CardGroup? group;

  CardWithGroup({
    required this.card,
    this.group,
  });

  factory CardWithGroup.fromJson(Map<String, dynamic> json) {
    return CardWithGroup(
      card: BusinessCard.fromJson(json),
      group: json['groupId'] != null
          ? CardGroup(
              id: json['groupId'],
              name: json['groupName'],
              createdAt: DateTime.now(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...card.toJson(),
      'groupId': group?.id,
      'groupName': group?.name,
    };
  }
}

// 群組資訊
class CardGroupInfo {
  final int? groupId;
  final String? groupName;

  CardGroupInfo({
    this.groupId,
    this.groupName,
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

  bool get hasGroup => groupId != null && groupName != null;
}