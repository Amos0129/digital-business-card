// lib/models/card.dart
class BusinessCard {
  final int? id;
  final String name;
  final String? company;
  final String? phone;
  final String? email;
  final String? address;
  final String? position;
  final String? style;
  final String? avatarUrl;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? lineUrl;
  final String? threadsUrl;
  final bool? facebook;
  final bool? instagram;
  final bool? line;
  final bool? threads;
  final bool? isPublic;

  BusinessCard({
    this.id,
    required this.name,
    this.company,
    this.phone,
    this.email,
    this.address,
    this.position,
    this.style,
    this.avatarUrl,
    this.facebookUrl,
    this.instagramUrl,
    this.lineUrl,
    this.threadsUrl,
    this.facebook,
    this.instagram,
    this.line,
    this.threads,
    this.isPublic,
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
      style: json['style'],
      avatarUrl: json['avatarUrl'],
      facebookUrl: json['facebookUrl'],
      instagramUrl: json['instagramUrl'],
      lineUrl: json['lineUrl'],
      threadsUrl: json['threadsUrl'],
      facebook: json['facebook'],
      instagram: json['instagram'],
      line: json['line'],
      threads: json['threads'],
      isPublic: json['isPublic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company': company,
      'phone': phone,
      'email': email,
      'address': address,
      'position': position,
      'style': style,
      'avatarUrl': avatarUrl,
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'lineUrl': lineUrl,
      'threadsUrl': threadsUrl,
      'facebook': facebook,
      'instagram': instagram,
      'line': line,
      'threads': threads,
      'isPublic': isPublic,
    };
  }
}