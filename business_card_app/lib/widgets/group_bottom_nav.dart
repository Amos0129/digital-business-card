import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import '../services/scan_service.dart';

class CardGroupBottomNav extends StatelessWidget {
  const CardGroupBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNav(
      currentIndex: 1,
      onTap: (index) async {
        if (index == 1) return;
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
          case 2:
            await ScanService.scanAndNavigate(context);
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/settings');
            break;
        }
      },
    );
  }
}
