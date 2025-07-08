import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF4A6CFF),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
      unselectedLabelStyle: GoogleFonts.notoSans(),
      iconSize: 24,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '個人名片',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: '名片群組',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: '掃描名片',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '帳戶/設定',
        ),
      ],
    );
  }
}