class CardRequest {
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
  final String? avatarUrl;
  final bool isPublic;

  CardRequest({
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
    required this.isPublic, // 默認為不公開名片
    this.facebookUrl,
    this.instagramUrl,
    this.lineUrl,
    this.threadsUrl,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
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
    'avatarUrl': avatarUrl,
    'isPublic': isPublic,
  };
}
