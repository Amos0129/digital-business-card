import 'package:flutter/material.dart';
import '../../core/theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem>? customItems;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.customItems,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
  }) : super(key: key);

  static final List<BottomNavItem> _defaultItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: '首頁',
    ),
    BottomNavItem(
      icon: Icons.business_center_outlined,
      activeIcon: Icons.business_center,
      label: '名片',
    ),
    BottomNavItem(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder,
      label: '群組',
    ),
    BottomNavItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: '搜尋',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '個人',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = customItems ?? _defaultItems;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              
              return Expanded(
                child: _NavBarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                  selectedColor: selectedItemColor ?? AppTheme.primaryColor,
                  unselectedColor: unselectedItemColor ?? AppTheme.hintColor,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const _NavBarItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: isSelected
                  ? BoxDecoration(
                      color: selectedColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Widget? badge;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
  });
}

class BadgedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Map<int, int>? badgeCounts;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const BadgedBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.badgeCounts,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: '首頁',
      ),
      BottomNavItem(
        icon: Icons.business_center_outlined,
        activeIcon: Icons.business_center,
        label: '名片',
        badge: _buildBadge(1),
      ),
      BottomNavItem(
        icon: Icons.folder_outlined,
        activeIcon: Icons.folder,
        label: '群組',
        badge: _buildBadge(2),
      ),
      BottomNavItem(
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        label: '搜尋',
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: '個人',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              
              return Expanded(
                child: _BadgedNavBarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                  selectedColor: selectedItemColor ?? AppTheme.primaryColor,
                  unselectedColor: unselectedItemColor ?? AppTheme.hintColor,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget? _buildBadge(int index) {
    final count = badgeCounts?[index];
    if (count == null || count <= 0) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _BadgedNavBarItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const _BadgedNavBarItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: selectedColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        )
                      : null,
                  child: Icon(
                    isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                    color: isSelected ? selectedColor : unselectedColor,
                    size: 24,
                  ),
                ),
                if (item.badge != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: item.badge!,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem>? customItems;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final EdgeInsetsGeometry? margin;

  const FloatingBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.customItems,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BottomNavBar(
        currentIndex: currentIndex,
        onTap: onTap,
        customItems: customItems,
        backgroundColor: Colors.transparent,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
      ),
    );
  }
}

// 使用範例：

// 1. 基本底部導航
// BottomNavBar(
//   currentIndex: _currentIndex,
//   onTap: (index) => setState(() => _currentIndex = index),
// )

// 2. 自訂樣式底部導航
// BottomNavBar(
//   currentIndex: _currentIndex,
//   onTap: _onTabChanged,
//   backgroundColor: Colors.black,
//   selectedItemColor: Colors.blue,
//   unselectedItemColor: Colors.grey,
// )

// 3. 帶徽章的底部導航
// BadgedBottomNavBar(
//   currentIndex: _currentIndex,
//   onTap: _onTabChanged,
//   badgeCounts: {1: 5, 2: 2}, // 名片有5個通知，群組有2個通知
// )

// 4. 浮動式底部導航
// FloatingBottomNavBar(
//   currentIndex: _currentIndex,
//   onTap: _onTabChanged,
//   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
// )

// 5. 自訂項目
// final customItems = [
//   BottomNavItem(icon: Icons.dashboard, label: '儀表板'),
//   BottomNavItem(icon: Icons.analytics, label: '分析'),
//   BottomNavItem(icon: Icons.settings, label: '設定'),
// ];
// BottomNavBar(
//   currentIndex: _currentIndex,
//   onTap: _onTabChanged,
//   customItems: customItems,
// )