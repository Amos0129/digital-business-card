import 'package:flutter/material.dart';

class CardPreview extends StatelessWidget {
  final Map<String, dynamic> style;
  final String name;
  final String company;
  final String phone;
  final String email;
  final String address;

  const CardPreview({
    super.key,
    required this.style,
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style['bg'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: style['text']),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (company.isNotEmpty) Text(company),
            if (phone.isNotEmpty)
              Row(children: [const Icon(Icons.phone, size: 16), const SizedBox(width: 8), Text(phone)]),
            if (email.isNotEmpty)
              Row(children: [const Icon(Icons.email, size: 16), const SizedBox(width: 8), Text(email)]),
            if (address.isNotEmpty)
              Row(children: [const Icon(Icons.location_on, size: 16), const SizedBox(width: 8), Text(address)]),
          ],
        ),
      ),
    );
  }
}
