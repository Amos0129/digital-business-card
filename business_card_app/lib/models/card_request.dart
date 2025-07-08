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
  };
}