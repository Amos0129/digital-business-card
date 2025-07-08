import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const SocialIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(url))) {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF4A6CFF).withOpacity(0.1),
            child: FaIcon(icon, size: 14, color: const Color(0xFF4A6CFF)),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }
}