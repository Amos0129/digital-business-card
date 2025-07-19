// lib/screens/main_screen.dart
import 'package:flutter/cupertino.dart';
import 'cards/my_cards_screen.dart';
import 'cards/public_cards_screen.dart';
import 'groups/groups_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(
          top: BorderSide(color: CupertinoColors.separator, width: 0.5),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_2),
            activeIcon: Icon(CupertinoIcons.person_2_fill),
            label: '我的名片',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            activeIcon: Icon(CupertinoIcons.search_circle_fill),
            label: '探索',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.folder),
            activeIcon: Icon(CupertinoIcons.folder_fill),
            label: '群組',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings_solid),
            label: '設定',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => MyCardsScreen(),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => PublicCardsScreen(),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => const GroupsScreen(),
            );
          case 3:
            return CupertinoTabView(
              builder: (context) => const ProfileScreen(),
            );
          default:
            return const SizedBox();
        }
      },
    );
  }
}