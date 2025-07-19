import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme.dart';
import '../../widgets/common/ios_buttons.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem>? customItems;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;
  final bool showLabels;
  final IOSTabBarStyle style;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.customItems,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.showLabels = true,
    this.style = IOSTabBarStyle.standard,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

enum IOSTabBarStyle {
  standard,    // 標準 iOS Tab Bar
  floating,    // 浮動樣式
  minimal,     // 簡約樣式
}

class _BottomNavBarState extends State<BottomNavBar> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;

  static final List<BottomNavItem> _defaultItems = [
    BottomNavItem(
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: '首頁',
    ),
    BottomNavItem(
      icon: CupertinoIcons.creditcard,
      activeIcon: CupertinoIcons.creditcard_fill,
      label: '名片',
    ),
    BottomNavItem(
      icon: CupertinoIcons.folder,
      activeIcon: CupertinoIcons.folder_fill,
      label: '群組',
    ),
    BottomNavItem(
      icon: CupertinoIcons.search,
      activeIcon: CupertinoIcons.search,
      label: '搜尋',
    ),
    BottomNavItem(
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
      label: '個人',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final items = widget.customItems ?? _defaultItems;
    
    _animationControllers = List.generate(
      items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    
    _scaleAnimations = _animationControllers
        .map((controller) => Tween<double>(begin: 1.0, end: 1.2)
            .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)))
        .toList();
    
    _fadeAnimations = _animationControllers
        .map((controller) => Tween<double>(begin: 0.6, end: 1.0)
            .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)))
        .toList();
    
    // 設置初始選中狀態
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 處理選中狀態變化
    if (oldWidget.currentIndex != widget.currentIndex) {
      if (oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case IOSTabBarStyle.standard:
        return _buildStandardTabBar();
      case IOSTabBarStyle.floating:
        return _buildFloatingTabBar();
      case IOSTabBarStyle.minimal:
        return _buildMinimalTabBar();
    }
  }

  Widget _buildStandardTabBar() {
    final items = widget.customItems ?? _defaultItems;
    
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppTheme.backgroundColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.separatorColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 83, // iOS 標準 Tab Bar 高度
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = widget.currentIndex == index;
              
              return Expanded(
                child: _IOSTabBarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => _handleTap(index),
                  selectedColor: widget.selectedItemColor ?? AppTheme.primaryColor,
                  unselectedColor: widget.unselectedItemColor ?? AppTheme.secondaryTextColor,
                  scaleAnimation: _scaleAnimations[index],
                  fadeAnimation: _fadeAnimations[index],
                  showLabel: widget.showLabels,
                  style: IOSTabItemStyle.standard,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingTabBar() {
    final items = widget.customItems ?? _defaultItems;
    
    return Positioned(
      left: 20,
      right: 20,
      bottom: 34,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = widget.currentIndex == index;
            
            return Expanded(
              child: _IOSTabBarItem(
                item: item,
                isSelected: isSelected,
                onTap: () => _handleTap(index),
                selectedColor: widget.selectedItemColor ?? AppTheme.primaryColor,
                unselectedColor: widget.unselectedItemColor ?? AppTheme.secondaryTextColor,
                scaleAnimation: _scaleAnimations[index],
                fadeAnimation: _fadeAnimations[index],
                showLabel: widget.showLabels,
                style: IOSTabItemStyle.floating,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMinimalTabBar() {
    final items = widget.customItems ?? _defaultItems;
    
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = widget.currentIndex == index;
              
              return _IOSTabBarItem(
                item: item,
                isSelected: isSelected,
                onTap: () => _handleTap(index),
                selectedColor: widget.selectedItemColor ?? AppTheme.primaryColor,
                unselectedColor: widget.unselectedItemColor ?? AppTheme.secondaryTextColor,
                scaleAnimation: _scaleAnimations[index],
                fadeAnimation: _fadeAnimations[index],
                showLabel: false,
                style: IOSTabItemStyle.minimal,
              );
            }),
          ),
        ),
      ),
    );
  }

  void _handleTap(int index) {
    if (index != widget.currentIndex) {
      widget.onTap(index);
    }
  }
}

enum IOSTabItemStyle {
  standard,
  floating,
  minimal,
}

class _IOSTabBarItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  final bool showLabel;
  final IOSTabItemStyle style;

  const _IOSTabBarItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.scaleAnimation,
    required this.fadeAnimation,
    required this.showLabel,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconContainer(),
              if (showLabel && style != IOSTabItemStyle.minimal) ...[
                const SizedBox(height: 2),
                _buildLabel(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildIconContainer() {
    Widget iconWidget = Stack(
      clipBehavior: Clip.none,
      children: [
        Transform.scale(
          scale: scaleAnimation.value,
          child: AnimatedBuilder(
            animation: fadeAnimation,
            builder: (context, child) {
              return Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                size: _getIconSize(),
                color: Color.lerp(
                  unselectedColor,
                  selectedColor,
                  fadeAnimation.value,
                ),
              );
            },
          ),
        ),
        if (item.badge != null)
          Positioned(
            right: -6,
            top: -6,
            child: item.badge!,
          ),
      ],
    );

    if (style == IOSTabItemStyle.floating && isSelected) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selectedColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  Widget _buildLabel() {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Text(
          item.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: Color.lerp(
              unselectedColor,
              selectedColor,
              fadeAnimation.value,
            ),
            fontFamily: '.SF Pro Text',
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  double _getIconSize() {
    switch (style) {
      case IOSTabItemStyle.standard:
        return 24;
      case IOSTabItemStyle.floating:
        return 22;
      case IOSTabItemStyle.minimal:
        return 26;
    }
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

// 徽章組件
class IOSBadge extends StatelessWidget {
  final String? text;
  final Color? color;
  final double? size;
  final bool showDot;

  const IOSBadge({
    Key? key,
    this.text,
    this.color,
    this.size,
    this.showDot = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showDot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color ?? AppTheme.errorColor,
          shape: BoxShape.circle,
        ),
      );
    }

    if (text == null || text!.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? AppTheme.errorColor,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        text!.length > 2 ? '99+' : text!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF Pro Text',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// 帶徽章的底部導航欄
class BadgedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Map<int, String>? badgeTexts;
  final Map<int, bool>? badgeDots;
  final IOSTabBarStyle style;

  const BadgedBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.badgeTexts,
    this.badgeDots,
    this.style = IOSTabBarStyle.standard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      BottomNavItem(
        icon: CupertinoIcons.house,
        activeIcon: CupertinoIcons.house_fill,
        label: '首頁',
      ),
      BottomNavItem(
        icon: CupertinoIcons.creditcard,
        activeIcon: CupertinoIcons.creditcard_fill,
        label: '名片',
        badge: _buildBadge(1),
      ),
      BottomNavItem(
        icon: CupertinoIcons.folder,
        activeIcon: CupertinoIcons.folder_fill,
        label: '群組',
        badge: _buildBadge(2),
      ),
      BottomNavItem(
        icon: CupertinoIcons.search,
        activeIcon: CupertinoIcons.search,
        label: '搜尋',
      ),
      BottomNavItem(
        icon: CupertinoIcons.person,
        activeIcon: CupertinoIcons.person_fill,
        label: '個人',
        badge: _buildBadge(4),
      ),
    ];

    return BottomNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      customItems: items,
      style: style,
    );
  }

  Widget? _buildBadge(int index) {
    final hasDot = badgeDots?[index] == true;
    final text = badgeTexts?[index];
    
    if (hasDot) {
      return const IOSBadge(showDot: true);
    }
    
    if (text?.isNotEmpty == true) {
      return IOSBadge(text: text);
    }
    
    return null;
  }
}

// CupertinoTabScaffold 風格的包裝器
class IOSTabScaffold extends StatelessWidget {
  final List<Widget> children;
  final List<BottomNavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final IOSTabBarStyle tabBarStyle;

  const IOSTabScaffold({
    Key? key,
    required this.children,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.tabBarStyle = IOSTabBarStyle.standard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: children,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: onTap,
        customItems: items,
        style: tabBarStyle,
      ),
    );
  }
}