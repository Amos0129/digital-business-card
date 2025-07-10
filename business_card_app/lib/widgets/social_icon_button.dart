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
        final uri = Uri.tryParse(url);
        if (uri == null || (!uri.hasScheme || !uri.hasAuthority)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('無效的 $label 連結')));
          return;
        }

        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('無法開啟 $label')));
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
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
