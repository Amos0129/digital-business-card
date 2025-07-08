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
  final int? groupId;
  final String? groupName;

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
    this.groupId,
    this.groupName,
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
      groupId: json['groupId'],
      groupName: json['groupName'],
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
      'groupId': groupId,
      'groupName': groupName,
    };
  }
}
