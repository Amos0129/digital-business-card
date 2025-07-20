// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// 應用程式色彩系統
/// 
/// 基於 Material Design 3 動態色彩系統
/// 支援亮色和深色主題
class AppColors {
  // 防止實例化
  AppColors._();

  // ========== 主色調 ==========
  /// 主色調 - 品牌色
  static const Color primary = Color(0xFF6750A4);
  static const Color primaryLight = Color(0xFF9A82DB);
  static const Color primaryDark = Color(0xFF4F378B);
  
  /// 次要色調 - 輔助色
  static const Color secondary = Color(0xFF625B71);
  static const Color secondaryLight = Color(0xFF958DA5);
  static const Color secondaryDark = Color(0xFF463D53);
  
  /// 第三色調 - 強調色
  static const Color tertiary = Color(0xFF7D5260);
  static const Color tertiaryLight = Color(0xFFB58392);
  static const Color tertiaryDark = Color(0xFF633B48);

  // ========== 中性色調 ==========
  /// 中性色調
  static const Color neutral = Color(0xFF1D1B20);
  static const Color neutralVariant = Color(0xFF49454F);
  
  /// 表面色調
  static const Color surface = Color(0xFFFEF7FF);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color inverseSurface = Color(0xFF322F35);
  
  /// 背景色調
  static const Color background = Color(0xFFFEF7FF);
  static const Color onBackground = Color(0xFF1D1B20);

  // ========== 功能色調 ==========
  /// 錯誤色調
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorLight = Color(0xFFFF5449);
  static const Color errorDark = Color(0xFF93000A);
  static const Color onError = Color(0xFFFFFFFF);
  
  /// 成功色調
  static const Color success = Color(0xFF146C2E);
  static const Color successLight = Color(0xFF4F9F62);
  static const Color successDark = Color(0xFF0D5C1C);
  static const Color onSuccess = Color(0xFFFFFFFF);
  
  /// 警告色調
  static const Color warning = Color(0xFFE65100);
  static const Color warningLight = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFBF360C);
  static const Color onWarning = Color(0xFFFFFFFF);
  
  /// 資訊色調
  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFF42A5F5);
  static const Color infoDark = Color(0xFF0D47A1);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ========== 深色主題色調 ==========
  /// 深色主題主色調
  static const Color primaryDarkTheme = Color(0xFFD0BCFF);
  static const Color secondaryDarkTheme = Color(0xFFCCC2DC);
  static const Color tertiaryDarkTheme = Color(0xFFEFB8C8);
  
  /// 深色主題表面色調
  static const Color surfaceDarkTheme = Color(0xFF141218);
  static const Color surfaceVariantDarkTheme = Color(0xFF49454F);
  static const Color backgroundDarkTheme = Color(0xFF141218);
  
  /// 深色主題錯誤色調
  static const Color errorDarkTheme = Color(0xFFFFB4AB);

  // ========== 透明度變體 ==========
  /// 主色調透明度變體
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  static Color secondaryWithOpacity(double opacity) => secondary.withOpacity(opacity);
  static Color tertiaryWithOpacity(double opacity) => tertiary.withOpacity(opacity);
  
  /// 功能色調透明度變體
  static Color errorWithOpacity(double opacity) => error.withOpacity(opacity);
  static Color successWithOpacity(double opacity) => success.withOpacity(opacity);
  static Color warningWithOpacity(double opacity) => warning.withOpacity(opacity);
  static Color infoWithOpacity(double opacity) => info.withOpacity(opacity);

  // ========== 漸層色彩 ==========
  /// 主色調漸層
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      primaryLight,
    ],
  );
  
  /// 次要色調漸層
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      secondary,
      secondaryLight,
    ],
  );
  
  /// 彩虹漸層
  static const LinearGradient rainbowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF667eea),
      Color(0xFF764ba2),
      Color(0xFFf093fb),
      Color(0xFFf5576c),
    ],
  );
  
  /// 日落漸層
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFff9a9e),
      Color(0xFFfecfef),
      Color(0xFFfecfef),
    ],
  );

  // ========== 卡片樣式色彩 ==========
  /// 名片樣式色彩映射
  static const Map<String, Color> cardStyleColors = {
    'classic': primary,
    'modern': Color(0xFF2196F3),
    'elegant': Color(0xFF9C27B0),
    'minimal': Color(0xFF607D8B),
    'creative': Color(0xFFFF5722),
    'professional': Color(0xFF795548),
  };
  
  /// 獲取名片樣式色彩
  static Color getCardStyleColor(String style) {
    return cardStyleColors[style] ?? primary;
  }

  // ========== 社交媒體色彩 ==========
  /// 社交媒體品牌色彩
  static const Map<String, Color> socialMediaColors = {
    'facebook': Color(0xFF1877F2),
    'instagram': Color(0xFFE4405F),
    'twitter': Color(0xFF1DA1F2),
    'linkedin': Color(0xFF0A66C2),
    'line': Color(0xFF00C300),
    'wechat': Color(0xFF07C160),
    'telegram': Color(0xFF0088CC),
    'whatsapp': Color(0xFF25D366),
  };
  
  /// 獲取社交媒體色彩
  static Color getSocialMediaColor(String platform) {
    return socialMediaColors[platform.toLowerCase()] ?? neutral;
  }

  // ========== 狀態色彩 ==========
  /// 線上狀態色彩
  static const Color online = success;
  static const Color offline = neutral;
  static const Color busy = warning;
  static const Color away = Color(0xFFFF9800);
  
  /// 優先級色彩
  static const Color highPriority = error;
  static const Color mediumPriority = warning;
  static const Color lowPriority = info;

  // ========== 工具方法 ==========
  /// 計算對比色
  static Color getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  /// 生成色調變體
  static Color generateShade(Color color, double factor) {
    return Color.fromRGBO(
      (color.red * factor).round().clamp(0, 255),
      (color.green * factor).round().clamp(0, 255),
      (color.blue * factor).round().clamp(0, 255),
      color.opacity,
    );
  }
  
  /// 混合兩種色彩
  static Color blendColors(Color color1, Color color2, double ratio) {
    return Color.fromRGBO(
      (color1.red + (color2.red - color1.red) * ratio).round(),
      (color1.green + (color2.green - color1.green) * ratio).round(),
      (color1.blue + (color2.blue - color1.blue) * ratio).round(),
      (color1.opacity + (color2.opacity - color1.opacity) * ratio),
    );
  }
}