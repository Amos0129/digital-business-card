// lib/core/theme/app_dimensions.dart
import 'package:flutter/material.dart';

/// 應用程式尺寸系統
/// 
/// 提供一致的間距、尺寸和佈局常數
/// 支援響應式設計和不同螢幕尺寸
class AppDimensions {
  // 防止實例化
  AppDimensions._();

  // ========== 基礎間距單位 ==========
  /// 基礎間距單位 (8dp)
  static const double baseUnit = 8.0;
  
  /// 半單位間距 (4dp)
  static const double halfUnit = baseUnit / 2;
  
  /// 雙單位間距 (16dp)
  static const double doubleUnit = baseUnit * 2;

  // ========== 間距系統 ==========
  /// 極小間距 (4dp)
  static const double spacingXs = 4.0;
  
  /// 小間距 (8dp)
  static const double spacingSm = 8.0;
  
  /// 中等間距 (16dp)
  static const double spacingMd = 16.0;
  
  /// 大間距 (24dp)
  static const double spacingLg = 24.0;
  
  /// 極大間距 (32dp)
  static const double spacingXl = 32.0;
  
  /// 超大間距 (48dp)
  static const double spacingXxl = 48.0;
  
  /// 巨大間距 (64dp)
  static const double spacingXxxl = 64.0;

  // ========== 內邊距系統 ==========
  /// 極小內邊距
  static const EdgeInsets paddingXs = EdgeInsets.all(spacingXs);
  
  /// 小內邊距
  static const EdgeInsets paddingSm = EdgeInsets.all(spacingSm);
  
  /// 中等內邊距
  static const EdgeInsets paddingMd = EdgeInsets.all(spacingMd);
  
  /// 大內邊距
  static const EdgeInsets paddingLg = EdgeInsets.all(spacingLg);
  
  /// 極大內邊距
  static const EdgeInsets paddingXl = EdgeInsets.all(spacingXl);

  // ========== 水平內邊距 ==========
  /// 水平小內邊距
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: spacingSm);
  
  /// 水平中等內邊距
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: spacingMd);
  
  /// 水平大內邊距
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: spacingLg);

  // ========== 垂直內邊距 ==========
  /// 垂直小內邊距
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: spacingSm);
  
  /// 垂直中等內邊距
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: spacingMd);
  
  /// 垂直大內邊距
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: spacingLg);

  // ========== 圓角系統 ==========
  /// 小圓角 (4dp)
  static const double radiusSm = 4.0;
  
  /// 中等圓角 (8dp)
  static const double radiusMd = 8.0;
  
  /// 大圓角 (12dp)
  static const double radiusLg = 12.0;
  
  /// 極大圓角 (16dp)
  static const double radiusXl = 16.0;
  
  /// 超大圓角 (24dp)
  static const double radiusXxl = 24.0;
  
  /// 圓形 (999dp)
  static const double radiusRound = 999.0;

  // ========== BorderRadius 系統 ==========
  /// 小圓角邊框
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  
  /// 中等圓角邊框
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  
  /// 大圓角邊框
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  
  /// 極大圓角邊框
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  
  /// 超大圓角邊框
  static const BorderRadius borderRadiusXxl = BorderRadius.all(Radius.circular(radiusXxl));
  
  /// 圓形邊框
  static const BorderRadius borderRadiusRound = BorderRadius.all(Radius.circular(radiusRound));

  // ========== 元件高度系統 ==========
  /// 小按鈕高度
  static const double buttonHeightSm = 36.0;
  
  /// 中等按鈕高度
  static const double buttonHeightMd = 48.0;
  
  /// 大按鈕高度
  static const double buttonHeightLg = 56.0;
  
  /// 輸入框高度
  static const double inputHeight = 56.0;
  
  /// 應用欄高度
  static const double appBarHeight = 56.0;
  
  /// 底部導航欄高度
  static const double bottomNavHeight = 80.0;
  
  /// 卡片最小高度
  static const double cardMinHeight = 120.0;
  
  /// 列表項目高度
  static const double listItemHeight = 72.0;

  // ========== 圖示系統 ==========
  /// 小圖示
  static const double iconSizeSm = 16.0;
  
  /// 中等圖示
  static const double iconSizeMd = 24.0;
  
  /// 大圖示
  static const double iconSizeLg = 32.0;
  
  /// 極大圖示
  static const double iconSizeXl = 48.0;
  
  /// 超大圖示
  static const double iconSizeXxl = 64.0;

  // ========== 頭像系統 ==========
  /// 小頭像
  static const double avatarSizeSm = 32.0;
  
  /// 中等頭像
  static const double avatarSizeMd = 48.0;
  
  /// 大頭像
  static const double avatarSizeLg = 64.0;
  
  /// 極大頭像
  static const double avatarSizeXl = 96.0;
  
  /// 超大頭像
  static const double avatarSizeXxl = 128.0;

  // ========== 陰影系統 ==========
  /// 小陰影
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
      color: Color(0x1A000000),
    ),
  ];
  
  /// 中等陰影
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: 0,
      color: Color(0x1A000000),
    ),
  ];
  
  /// 大陰影
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
      color: Color(0x1A000000),
    ),
  ];
  
  /// 極大陰影
  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
      color: Color(0x1A000000),
    ),
  ];

  // ========== 斷點系統 ==========
  /// 手機斷點
  static const double breakpointMobile = 480.0;
  
  /// 平板斷點
  static const double breakpointTablet = 768.0;
  
  /// 桌面斷點
  static const double breakpointDesktop = 1024.0;
  
  /// 大桌面斷點
  static const double breakpointLargeDesktop = 1440.0;

  // ========== 工具方法 ==========
  /// 獲取響應式間距
  static double getResponsiveSpacing(BuildContext context, {
    double mobile = spacingMd,
    double tablet = spacingLg,
    double desktop = spacingXl,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= breakpointDesktop) {
      return desktop;
    } else if (width >= breakpointTablet) {
      return tablet;
    } else {
      return mobile;
    }
  }
  
  /// 獲取響應式內邊距
  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets mobile = paddingMd,
    EdgeInsets tablet = paddingLg,
    EdgeInsets desktop = paddingXl,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= breakpointDesktop) {
      return desktop;
    } else if (width >= breakpointTablet) {
      return tablet;
    } else {
      return mobile;
    }
  }
  
  /// 判斷是否為手機螢幕
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointTablet;
  }
  
  /// 判斷是否為平板螢幕
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointTablet && width < breakpointDesktop;
  }
  
  /// 判斷是否為桌面螢幕
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }
}