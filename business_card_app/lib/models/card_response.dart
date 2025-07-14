import '../models/unified_card.dart';

class CardResponse {
  final int id;
  final String name;
  final String company;
  final String phone;
  final String email;
  final String address;
  final String style;
  final bool facebook;
  final bool instagram;
  final bool line;
  final bool threads;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? lineUrl;
  final String? threadsUrl;
  final int? groupId;
  final String? groupName;
  final String? avatarUrl;
  final bool isPublic;

  CardResponse({
    required this.id,
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.address,
    required this.style,
    required this.facebook,
    required this.instagram,
    required this.line,
    required this.threads,
    required this.isPublic,
    this.facebookUrl,
    this.instagramUrl,
    this.lineUrl,
    this.threadsUrl,
    this.groupId,
    this.groupName,
    this.avatarUrl,
  });

  factory CardResponse.fromJson(Map<String, dynamic> json) {
    return CardResponse(
      id: json['id'],
      name: json['name'] ?? '',
      company: json['company'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      style: json['style'] ?? 'default',
      facebook: json['facebook'] ?? false,
      instagram: json['instagram'] ?? false,
      line: json['line'] ?? false,
      threads: json['threads'] ?? false,
      facebookUrl: json['facebookUrl'],
      instagramUrl: json['instagramUrl'],
      lineUrl: json['lineUrl'],
      threadsUrl: json['threadsUrl'],
      groupId: json['groupId'],
      groupName: json['groupName'],
      avatarUrl: json['avatarUrl'],
      isPublic: json['isPublic'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'phone': phone,
      'email': email,
      'address': address,
      'style': style,
      'facebook': facebook,
      'instagram': instagram,
      'line': line,
      'threads': threads,
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'lineUrl': lineUrl,
      'threadsUrl': threadsUrl,
      'groupId': groupId,
      'groupName': groupName,
      'avatarUrl': avatarUrl,
      'isPublic': isPublic,
    };
  }

  /// ✅ 加上這段：轉成 UnifiedCard
  UnifiedCard toUnifiedCard() {
    return UnifiedCard(
      cardId: id,
      id: id.toString(),
      name: name,
      company: company,
      phone: phone,
      email: email,
      address: address,
      style: style,
      hasFb: facebook,
      hasIg: instagram,
      hasLine: line,
      hasThreads: threads,
      fbUrl: facebookUrl,
      igUrl: instagramUrl,
      lineUrl: lineUrl,
      threadsUrl: threadsUrl,
      groupId: groupId,
      group: groupName,
      avatarUrl: fullAvatarUrl,
      isPublic: isPublic,
    );
  }

  String? get fullAvatarUrl {
    if (avatarUrl == null || avatarUrl!.isEmpty) return null;
    const baseUrl = 'http://192.168.205.54:5566'; // ⬅️ 換成你的實際 API host
    return '$baseUrl$avatarUrl';
  }
}
