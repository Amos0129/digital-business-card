// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_dimensions.dart';

/// 應用程式主題系統
/// 
/// 整合色彩、字體、尺寸等設計系統
/// 提供亮色和深色主題配置
class AppTheme {
  // 防止實例化
  AppTheme._();

  // ========== 亮色主題 ==========
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // 色彩方案
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.tertiary,
        onTertiary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onBackground,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.neutralVariant,
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        error: AppColors.error,
        onError: AppColors.onError,
        outline: AppColors.neutralVariant,
        shadow: Colors.black,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: Colors.white,
        inversePrimary: AppColors.primaryLight,
      ),
      
      // 字體主題
      textTheme: _lightTextTheme,
      
      // 應用欄主題
      appBarTheme: _lightAppBarTheme,
      
      // 卡片主題
      cardTheme: _cardTheme,
      
      // 按鈕主題
      elevatedButtonTheme: _elevatedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      
      // 輸入框主題
      inputDecorationTheme: _lightInputDecorationTheme,
      
      // 底部導航主題
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      
      // 浮動操作按鈕主題
      floatingActionButtonTheme: _floatingActionButtonTheme,
      
      // 對話框主題
      dialogTheme: _dialogTheme,
      
      // 分隔線主題
      dividerTheme: _dividerTheme,
      
      // 列表磚主題
      listTileTheme: _listTileTheme,
      
      // 開關主題
      switchTheme: _switchTheme,
      
      // 複選框主題
      checkboxTheme: _checkboxTheme,
      
      // 進度指示器主題
      progressIndicatorTheme: _progressIndicatorTheme,
      
      // 工具提示主題
      tooltipTheme: _tooltipTheme,
      
      // 底部表單主題
      bottomSheetTheme: _bottomSheetTheme,
      
      // 系統UI覆蓋樣式
      extensions: [
        _lightSystemUiOverlayStyle,
      ],
    );
  }

  // ========== 深色主題 ==========
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // 色彩方案
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDarkTheme,
        onPrimary: AppColors.primaryDark,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.primaryDarkTheme,
        secondary: AppColors.secondaryDarkTheme,
        onSecondary: AppColors.secondaryDark,
        secondaryContainer: AppColors.secondaryDark,
        onSecondaryContainer: AppColors.secondaryDarkTheme,
        tertiary: AppColors.tertiaryDarkTheme,
        onTertiary: AppColors.tertiaryDark,
        surface: AppColors.surfaceDarkTheme,
        onSurface: Colors.white,
        surfaceVariant: AppColors.surfaceVariantDarkTheme,
        onSurfaceVariant: AppColors.secondaryDarkTheme,
        background: AppColors.backgroundDarkTheme,
        onBackground: Colors.white,
        error: AppColors.errorDarkTheme,
        onError: AppColors.errorDark,
        outline: AppColors.neutralVariant,
        shadow: Colors.black,
        inverseSurface: Colors.white,
        onInverseSurface: AppColors.backgroundDarkTheme,
        inversePrimary: AppColors.primary,
      ),
      
      // 字體主題
      textTheme: _darkTextTheme,
      
      // 應用欄主題
      appBarTheme: _darkAppBarTheme,
      
      // 其他主題組件與亮色主題相同
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _darkInputDecorationTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      dialogTheme: _dialogTheme,
      dividerTheme: _dividerTheme,
      listTileTheme: _listTileTheme,
      switchTheme: _switchTheme,
      checkboxTheme: _checkboxTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
      tooltipTheme: _tooltipTheme,
      bottomSheetTheme: _bottomSheetTheme,
      
      extensions: [
        _darkSystemUiOverlayStyle,
      ],
    );
  }

  // ========== 字體主題 ==========
  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: AppTypography.displayLarge,
    displayMedium: AppTypography.displayMedium,
    displaySmall: AppTypography.displaySmall,
    headlineLarge: AppTypography.headlineLarge,
    headlineMedium: AppTypography.headlineMedium,
    headlineSmall: AppTypography.headlineSmall,
    titleLarge: AppTypography.titleLarge,
    titleMedium: AppTypography.titleMedium,
    titleSmall: AppTypography.titleSmall,
    labelLarge: AppTypography.labelLarge,
    labelMedium: AppTypography.labelMedium,
    labelSmall: AppTypography.labelSmall,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
  );

  static TextTheme get _darkTextTheme {
    return _lightTextTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
      decorationColor: Colors.white,
    );
  }

  // ========== 應用欄主題 ==========
  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.onBackground,
    titleTextStyle: AppTypography.titleLarge,
    toolbarHeight: AppDimensions.appBarHeight,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );

  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: AppColors.surfaceDarkTheme,
    foregroundColor: Colors.white,
    titleTextStyle: AppTypography.titleLarge,
    toolbarHeight: AppDimensions.appBarHeight,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );

  // ========== 卡片主題 ==========
  static const CardTheme _cardTheme = CardTheme(
    elevation: 2,
    margin: AppDimensions.paddingSm,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusLg,
    ),
  );

  // ========== 按鈕主題 ==========
  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 2,
      minimumSize: const Size(0, AppDimensions.buttonHeightMd),
      padding: AppDimensions.paddingHorizontalLg,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusLg,
      ),
      textStyle: AppTypography.labelLarge,
    ),
  );

  static final FilledButtonThemeData _filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, AppDimensions.buttonHeightMd),
      padding: AppDimensions.paddingHorizontalLg,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusLg,
      ),
      textStyle: AppTypography.labelLarge,
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, AppDimensions.buttonHeightMd),
      padding: AppDimensions.paddingHorizontalLg,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusLg,
      ),
      side: const BorderSide(color: AppColors.primary),
      textStyle: AppTypography.labelLarge,
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      minimumSize: const Size(0, AppDimensions.buttonHeightMd),
      padding: AppDimensions.paddingHorizontalMd,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusLg,
      ),
      textStyle: AppTypography.labelLarge,
    ),
  );

  // ========== 輸入框主題 ==========
  static const InputDecorationTheme _lightInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    contentPadding: AppDimensions.paddingMd,
    border: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusLg,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusLg,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusLg,
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusLg,
      borderSide: BorderSide(color: AppColors.error, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusLg,
      borderSide: BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: AppTypography.bodyMedium,
    hintStyle: AppTypography.hint,
    errorStyle: AppTypography.error,
  );

  static const InputDecorationTheme _darkInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariantDarkTheme,
    contentPadding: AppDimensions.paddingMd,
    border: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusLg,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusLg,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusLg,
      borderSide: BorderSide(color: AppColors.primaryDarkTheme, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusLg,
      borderSide: BorderSide(color: AppColors.errorDarkTheme, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusLg,
      borderSide: BorderSide(color: AppColors.errorDarkTheme, width: 2),
    ),
    labelStyle: AppTypography.bodyMedium,
    hintStyle: AppTypography.hint,
    errorStyle: AppTypography.error,
  );

  // ========== 其他組件主題 ==========
  static const BottomNavigationBarThemeData _bottomNavigationBarTheme = BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.neutralVariant,
    selectedLabelStyle: AppTypography.labelSmall,
    unselectedLabelStyle: AppTypography.labelSmall,
  );

  static const FloatingActionButtonThemeData _floatingActionButtonTheme = FloatingActionButtonThemeData(
    elevation: 6,
    highlightElevation: 12,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusXl,
    ),
  );

  static const DialogTheme _dialogTheme = DialogTheme(
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusXl,
    ),
    titleTextStyle: AppTypography.headlineSmall,
    contentTextStyle: AppTypography.bodyMedium,
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    thickness: 1,
    space: 1,
    color: AppColors.neutralVariant,
  );

  static const ListTileThemeData _listTileTheme = ListTileThemeData(
    contentPadding: AppDimensions.paddingHorizontalMd,
    titleTextStyle: AppTypography.bodyLarge,
    subtitleTextStyle: AppTypography.bodyMedium,
    minVerticalPadding: AppDimensions.spacingSm,
  );

  static final SwitchThemeData _switchTheme = SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return AppColors.neutralVariant;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryLight;
      }
      return AppColors.surfaceVariant;
    }),
  );

  static final CheckboxThemeData _checkboxTheme = CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    checkColor: MaterialStateProperty.all(Colors.white),
    shape: const RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusSm,
    ),
  );

  static const ProgressIndicatorThemeData _progressIndicatorTheme = ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.surfaceVariant,
    circularTrackColor: AppColors.surfaceVariant,
  );

  static const TooltipThemeData _tooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.inverseSurface,
      borderRadius: AppDimensions.borderRadiusSm,
    ),
    textStyle: AppTypography.bodySmall,
    padding: AppDimensions.paddingSm,
  );

  static const BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusXl),
      ),
    ),
  );

  // ========== 系統UI覆蓋樣式 ==========
  static const SystemUiOverlayTheme _lightSystemUiOverlayStyle = SystemUiOverlayTheme(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  static const SystemUiOverlayTheme _darkSystemUiOverlayStyle = SystemUiOverlayTheme(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surfaceDarkTheme,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

/// 系統UI覆蓋樣式主題擴展
class SystemUiOverlayTheme extends ThemeExtension<SystemUiOverlayTheme> {
  final SystemUiOverlayStyle overlayStyle;

  const SystemUiOverlayTheme(this.overlayStyle);

  @override
  SystemUiOverlayTheme copyWith({SystemUiOverlayStyle? overlayStyle}) {
    return SystemUiOverlayTheme(overlayStyle ?? this.overlayStyle);
  }

  @override
  SystemUiOverlayTheme lerp(ThemeExtension<SystemUiOverlayTheme>? other, double t) {
    if (other is! SystemUiOverlayTheme) {
      return this;
    }
    return SystemUiOverlayTheme(overlayStyle);
  }
}