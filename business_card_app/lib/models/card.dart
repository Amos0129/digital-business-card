class BusinessCard {
  final int id;
  final String name;
  final String? company;
  final String? phone;
  final String? email;
  final String? address;
  final String? position;
  final String? style;
  final String? avatarUrl;
  final bool? facebook;
  final bool? instagram;
  final bool? line;
  final bool? threads;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? lineUrl;
  final String? threadsUrl;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BusinessCard({
    required this.id,
    required this.name,
    this.company,
    this.phone,
    this.email,
    this.address,
    this.position,
    this.style,
    this.avatarUrl,
    this.facebook,
    this.instagram,
    this.line,
    this.threads,
    this.facebookUrl,
    this.instagramUrl,
    this.lineUrl,
    this.threadsUrl,
    this.isPublic = false,
    this.createdAt,
    this.updatedAt,
  });

  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      id: json['id'],
      name: json['name'] ?? '',
      company: json['company'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      position: json['position'],
      style: json['style'] ?? 'default',
      avatarUrl: json['avatarUrl'],
      facebook: json['facebook'],
      instagram: json['instagram'],
      line: json['line'],
      threads: json['threads'],
      facebookUrl: json['facebookUrl'],
      instagramUrl: json['instagramUrl'],
      lineUrl: json['lineUrl'],
      threadsUrl: json['threadsUrl'],
      isPublic: json['isPublic'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
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
      'position': position,
      'style': style,
      'avatarUrl': avatarUrl,
      'facebook': facebook,
      'instagram': instagram,
      'line': line,
      'threads': threads,
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'lineUrl': lineUrl,
      'threadsUrl': threadsUrl,
      'isPublic': isPublic,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  BusinessCard copyWith({
    int? id,
    String? name,
    String? company,
    String? phone,
    String? email,
    String? address,
    String? position,
    String? style,
    String? avatarUrl,
    bool? facebook,
    bool? instagram,
    bool? line,
    bool? threads,
    String? facebookUrl,
    String? instagramUrl,
    String? lineUrl,
    String? threadsUrl,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessCard(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      position: position ?? this.position,
      style: style ?? this.style,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      line: line ?? this.line,
      threads: threads ?? this.threads,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      lineUrl: lineUrl ?? this.lineUrl,
      threadsUrl: threadsUrl ?? this.threadsUrl,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 檢查是否有社交媒體連結
  bool get hasSocialMedia => 
      (facebook == true && facebookUrl?.isNotEmpty == true) ||
      (instagram == true && instagramUrl?.isNotEmpty == true) ||
      (line == true && lineUrl?.isNotEmpty == true) ||
      (threads == true && threadsUrl?.isNotEmpty == true);

  // 取得所有社交媒體連結
  List<SocialMedia> get socialMediaList {
    final List<SocialMedia> socials = [];
    
    if (facebook == true && facebookUrl?.isNotEmpty == true) {
      socials.add(SocialMedia(platform: 'facebook', url: facebookUrl!));
    }
    if (instagram == true && instagramUrl?.isNotEmpty == true) {
      socials.add(SocialMedia(platform: 'instagram', url: instagramUrl!));
    }
    if (line == true && lineUrl?.isNotEmpty == true) {
      socials.add(SocialMedia(platform: 'line', url: lineUrl!));
    }
    if (threads == true && threadsUrl?.isNotEmpty == true) {
      socials.add(SocialMedia(platform: 'threads', url: threadsUrl!));
    }
    
    return socials;
  }

  @override
  String toString() {
    return 'BusinessCard(id: $id, name: $name, company: $company)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// 社交媒體模型
class SocialMedia {
  final String platform;
  final String url;

  SocialMedia({
    required this.platform,
    required this.url,
  });
}

// 名片請求DTO
class CardRequest {
  final String name;
  final String? company;
  final String? phone;
  final String? email;
  final String? address;
  final String? position;
  final String? style;
  final bool? facebook;
  final bool? instagram;
  final bool? line;
  final bool? threads;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? lineUrl;
  final String? threadsUrl;
  final bool isPublic;

  CardRequest({
    required this.name,
    this.company,
    this.phone,
    this.email,
    this.address,
    this.position,
    this.style,
    this.facebook,
    this.instagram,
    this.line,
    this.threads,
    this.facebookUrl,
    this.instagramUrl,
    this.lineUrl,
    this.threadsUrl,
    this.isPublic = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company': company,
      'phone': phone,
      'email': email,
      'address': address,
      'position': position,
      'style': style,
      'facebook': facebook,
      'instagram': instagram,
      'line': line,
      'threads': threads,
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'lineUrl': lineUrl,
      'threadsUrl': threadsUrl,
      'isPublic': isPublic,
    };
  }
}

// 名片與群組的關聯模型
class CardWithGroup extends BusinessCard {
  final int? groupId;
  final String? groupName;

  CardWithGroup({
    required super.id,
    required super.name,
    super.company,
    super.phone,
    super.email,
    super.address,
    super.position,
    super.style,
    super.avatarUrl,
    super.facebook,
    super.instagram,
    super.line,
    super.threads,
    super.facebookUrl,
    super.instagramUrl,
    super.lineUrl,
    super.threadsUrl,
    super.isPublic,
    super.createdAt,
    super.updatedAt,
    this.groupId,
    this.groupName,
  });

  factory CardWithGroup.fromJson(Map<String, dynamic> json) {
    return CardWithGroup(
      id: json['id'],
      name: json['name'] ?? '',
      company: json['company'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      position: json['position'],
      style: json['style'] ?? 'default',
      avatarUrl: json['avatarUrl'],
      facebook: json['facebook'],
      instagram: json['instagram'],
      line: json['line'],
      threads: json['threads'],
      facebookUrl: json['facebookUrl'],
      instagramUrl: json['instagramUrl'],
      lineUrl: json['lineUrl'],
      threadsUrl: json['threadsUrl'],
      isPublic: json['isPublic'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
      groupId: json['groupId'],
      groupName: json['groupName'],
    );
  }
}