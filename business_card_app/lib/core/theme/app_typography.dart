// lib/core/theme/app_typography.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 應用程式字體系統
/// 
/// 基於 Material Design 3 字體規範
/// 提供一致的字體樣式和層次結構
class AppTypography {
  // 防止實例化
  AppTypography._();

  // ========== 字體家族 ==========
  /// 主要字體 - 適用於大部分文字
  static const String primaryFontFamily = 'Inter';
  
  /// 次要字體 - 適用於標題和強調文字
  static const String secondaryFontFamily = 'Poppins';
  
  /// 等寬字體 - 適用於代碼和數字
  static const String monospaceFontFamily = 'SF Mono';

  // ========== 顯示級別字體 (Display) ==========
  /// 顯示大號 - 用於最重要的文字
  static const TextStyle displayLarge = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.25,
    color: AppColors.onBackground,
  );
  
  /// 顯示中號
  static const TextStyle displayMedium = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.16,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );
  
  /// 顯示小號
  static const TextStyle displaySmall = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.22,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  // ========== 標題級別字體 (Headline) ==========
  /// 標題大號 - 用於重要標題
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );
  
  /// 標題中號
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );
  
  /// 標題小號
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  // ========== 主標題級別字體 (Title) ==========
  /// 主標題大號 - 用於卡片標題
  static const TextStyle titleLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );
  
  /// 主標題中號
  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.onBackground,
  );
  
  /// 主標題小號
  static const TextStyle titleSmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
    color: AppColors.onBackground,
  );

  // ========== 標籤級別字體 (Label) ==========
  /// 標籤大號 - 用於按鈕文字
  static const TextStyle labelLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
    color: AppColors.primary,
  );
  
  /// 標籤中號
  static const TextStyle labelMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.5,
    color: AppColors.primary,
  );
  
  /// 標籤小號
  static const TextStyle labelSmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0.5,
    color: AppColors.primary,
  );

  // ========== 正文級別字體 (Body) ==========
  /// 正文大號 - 用於主要內容
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.onBackground,
  );
  
  /// 正文中號
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
    color: AppColors.onBackground,
  );
  
  /// 正文小號
  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
    color: AppColors.onBackground,
  );

  // ========== 特殊用途字體樣式 ==========
  /// 按鈕文字
  static const TextStyle button = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
    color: AppColors.onPrimary,
  );
  
  /// 表單輸入框文字
  static const TextStyle input = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.onSurface,
  );
  
  /// 錯誤文字
  static const TextStyle error = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
    color: AppColors.error,
  );
  
  /// 提示文字
  static const TextStyle hint = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
    color: AppColors.onSurfaceVariant,
  );
  
  /// 說明文字
  static const TextStyle caption = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
    color: AppColors.onSurfaceVariant,
  );

  // ========== 數字和等寬字體 ==========
  /// 等寬正文
  static const TextStyle monoBody = TextStyle(
    fontFamily: monospaceFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
    color: AppColors.onBackground,
  );
  
  /// 等寬標題
  static const TextStyle monoTitle = TextStyle(
    fontFamily: monospaceFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.onBackground,
  );

  // ========== 工具方法 ==========
  /// 創建帶顏色的文字樣式
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// 創建帶權重的文字樣式
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// 創建帶大小的文字樣式
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  /// 創建帶行高的文字樣式
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }
  
  /// 創建帶字母間距的文字樣式
  static TextStyle withLetterSpacing(TextStyle style, double spacing) {
    return style.copyWith(letterSpacing: spacing);
  }
  
  /// 創建帶裝飾的文字樣式
  static TextStyle withDecoration(TextStyle style, TextDecoration decoration) {
    return style.copyWith(decoration: decoration);
  }
}