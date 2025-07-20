// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/services/navigation_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/main_navigation.dart';
import 'routes/app_router.dart';
import 'l10n/app_localizations.dart';

/// 數位名片應用程式主體
/// 
/// 負責：
/// - 配置應用程式主題
/// - 管理路由和導航
/// - 處理國際化
/// - 監聽認證狀態變化
class DigitalCardApp extends StatelessWidget {
  const DigitalCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        return MaterialApp(
          // 應用程式基本配置
          title: 'Digital Business Card',
          debugShowCheckedModeBanner: false,
          
          // 主題配置
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          
          // 國際化配置
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // 英文
            Locale('zh', ''), // 中文
          ],
          
          // 導航配置
          navigatorKey: NavigationService.instance.navigatorKey,
          onGenerateRoute: AppRouter.generateRoute,
          
          // 根據認證狀態決定初始頁面
          home: _buildInitialScreen(authProvider),
          
          // 全域建構器
          builder: (context, child) {
            return _AppWrapper(child: child);
          },
        );
      },
    );
  }

  /// 根據認證狀態構建初始畫面
  Widget _buildInitialScreen(AuthProvider authProvider) {
    if (authProvider.isLoading) {
      return const SplashScreen();
    }
    
    if (authProvider.isAuthenticated) {
      return const MainNavigation();
    }
    
    return const LoginScreen();
  }
}

/// 應用程式包裝器
/// 
/// 提供全域功能：
/// - 錯誤邊界處理
/// - 全域手勢處理
/// - 鍵盤管理
class _AppWrapper extends StatelessWidget {
  final Widget? child;
  
  const _AppWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 點擊空白處收起鍵盤
      onTap: () => _hideKeyboard(context),
      child: MediaQuery(
        // 禁用系統字體縮放
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.noScaling,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
  
  /// 隱藏鍵盤
  void _hideKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
  }
}