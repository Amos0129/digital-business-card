// lib/models/user.dart
class User {
  final int id;
  final String email;
  final String name;
  final String? token;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
    };
  }
}

class Group {
  final int id;
  final String name;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}