import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  // iOS 系統顏色
  static const Color primaryColor = Color(0xFF007AFF); // iOS 藍色
  static const Color secondaryColor = Color(0xFF5856D6); // iOS 紫色
  static const Color backgroundColor = Color(0xFFF2F2F7); // iOS 淺灰背景
  static const Color cardColor = Colors.white;
  static const Color groupedBackgroundColor = Color(0xFFF2F2F7);
  static const Color secondaryBackgroundColor = Color(0xFFFFFFFF);
  
  // iOS 文字顏色
  static const Color textColor = Color(0xFF000000);
  static const Color secondaryTextColor = Color(0xFF8E8E93);
  static const Color tertiaryTextColor = Color(0xFFC7C7CC);
  static const Color linkColor = Color(0xFF007AFF);
  
  // iOS 系統顏色
  static const Color errorColor = Color(0xFFFF3B30); // iOS 紅色
  static const Color successColor = Color(0xFF34C759); // iOS 綠色
  static const Color warningColor = Color(0xFFFF9500); // iOS 橙色
  static const Color separatorColor = Color(0xFFC6C6C8);
  static const Color opaqueSeparatorColor = Color(0xFF3C3C43);
  
  // iOS 特殊顏色
  static const Color destructiveColor = Color(0xFFFF3B30);
  static const Color tintColor = Color(0xFF007AFF);
  
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: '.SF Pro Text', // iOS 系統字體
    
    // CupertinoTheme 設定
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          color: textColor,
        ),
      ),
    ),
    
    // AppBar 主題 - iOS 風格
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: '.SF Pro Text',
      ),
      iconTheme: IconThemeData(
        color: primaryColor,
        size: 22,
      ),
    ),
    
    // 按鈕主題 - iOS 風格
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF Pro Text',
        ),
        elevation: 0,
      ),
    ),
    
    // 文字按鈕主題
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          fontFamily: '.SF Pro Text',
        ),
      ),
    ),
    
    // 輸入框主題 - iOS 風格
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: separatorColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: separatorColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor),
      ),
      hintStyle: const TextStyle(
        color: secondaryTextColor,
        fontFamily: '.SF Pro Text',
      ),
    ),
    
    // 卡片主題 - iOS 風格
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    
    // 底部導航主題 - iOS 風格
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: secondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: '.SF Pro Text',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        fontFamily: '.SF Pro Text',
      ),
    ),
    
    // 列表磚主題
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: '.SF Pro Text',
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
        fontFamily: '.SF Pro Text',
      ),
    ),
    
    // 分隔線主題
    dividerTheme: const DividerThemeData(
      color: separatorColor,
      thickness: 0.5,
      space: 1,
    ),
    
    // Switch 主題
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.white;
        }
        return Colors.white;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return successColor;
        }
        return separatorColor;
      }),
    ),
    
    // Slider 主題
    sliderTheme: const SliderThemeData(
      activeTrackColor: primaryColor,
      inactiveTrackColor: separatorColor,
      thumbColor: Colors.white,
      overlayColor: Color(0x29007AFF),
    ),
  );
  
  // iOS 文字樣式
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: textColor,
    fontFamily: '.SF Pro Display',
  );
  
  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: textColor,
    fontFamily: '.SF Pro Display',
  );
  
  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: textColor,
    fontFamily: '.SF Pro Display',
  );
  
  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: textColor,
    fontFamily: '.SF Pro Text',
  );
  
  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: textColor,
    fontFamily: '.SF Pro Text',
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: textColor,
    fontFamily: '.SF Pro Text',
  );
  
  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textColor,
    fontFamily: '.SF Pro Text',
  );
  
  static const TextStyle subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textColor,
    fontFamily: '.SF Pro Text',
  );
  
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textColor,
    fontFamily: '.SF Pro Text',
  );
  
  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textColor,
    fontFamily: '.SF Pro Text',
  );
  
  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textColor,
    fontFamily: '.SF Pro Text',
  );
  
  // iOS 顏色工具方法
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // iOS 陰影
  static List<BoxShadow> get iosShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  // iOS 卡片陰影
  static List<BoxShadow> get iosCardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 1),
    ),
  ];
}

// iOS 風格常量
class IOSConstants {
  // 間距
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 32.0;
  
  // 圓角
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 14.0;
  static const double radiusXLarge = 20.0;
  
  // 高度
  static const double buttonHeight = 50.0;
  static const double inputHeight = 44.0;
  static const double cellHeight = 44.0;
  static const double tabBarHeight = 49.0;
  static const double navigationBarHeight = 44.0;
  
  // 動畫時間
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration quickAnimation = Duration(milliseconds: 150);
  
  // iOS 系統間距
  static const EdgeInsets systemPadding = EdgeInsets.all(16);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets cellPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
}