import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialButtons extends StatelessWidget {
  final bool hasFb;
  final bool hasIg;
  final bool hasLine;
  final bool hasThreads;

  const SocialButtons({
    super.key,
    this.hasFb = false,
    this.hasIg = false,
    this.hasLine = false,
    this.hasThreads = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    if (hasFb) {
      buttons.add(_SocialButton(
        icon: FontAwesomeIcons.facebookF,
        label: 'Facebook',
        color: Color(0xFF1877F2),
        onPressed: () {
          // TODO: 開啟 Facebook 頁面
        },
      ));
    }
    if (hasIg) {
      buttons.add(_SocialButton(
        icon: FontAwesomeIcons.instagram,
        label: 'Instagram',
        color: Color(0xFFE4405F),
        onPressed: () {
          // TODO: 開啟 Instagram
        },
      ));
    }
    if (hasLine) {
      buttons.add(_SocialButton(
        icon: FontAwesomeIcons.line,
        label: 'LINE',
        color: Color(0xFF00C300),
        onPressed: () {
          // TODO: 開啟 LINE
        },
      ));
    }
    if (hasThreads) {
      buttons.add(_SocialButton(
        icon: FontAwesomeIcons.threads,
        label: 'Threads',
        color: Colors.black87,
        onPressed: () {
          // TODO: 開啟 Threads
        },
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons,
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: color,
            padding: const EdgeInsets.all(14),
            elevation: 3,
          ),
          onPressed: onPressed,
          child: FaIcon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}