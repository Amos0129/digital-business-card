// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/home/main_navigation.dart';
import '../presentation/screens/cards/card_form_screen.dart';
import '../presentation/screens/cards/card_detail_screen.dart';
import '../presentation/screens/cards/card_preview_screen.dart';
import '../presentation/screens/cards/public_cards_screen.dart';
import '../presentation/screens/groups/groups_screen.dart';
import '../presentation/screens/groups/group_form_screen.dart';
import '../presentation/screens/groups/group_detail_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/profile/edit_profile_screen.dart';
import '../presentation/screens/profile/settings_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/search/search_results_screen.dart';
import '../presentation/screens/scanner/qr_scanner_screen.dart';
import 'route_animations.dart';

/// 應用程式路由管理
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      // 啟動畫面
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 認證相關路由
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => RouteAnimations.fadeTransition(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => RouteAnimations.slideTransition(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        pageBuilder: (context, state) => RouteAnimations.slideTransition(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),

      // 主導航
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainNavigation(),
        routes: [
          // 名片相關路由
          GoRoute(
            path: 'card/create',
            name: 'card_create',
            pageBuilder: (context, state) => RouteAnimations.slideUpTransition(
              key: state.pageKey,
              child: const CardFormScreen(),
            ),
          ),
          GoRoute(
            path: 'card/:cardId/edit',
            name: 'card_edit',
            pageBuilder: (context, state) {
              final cardId = int.parse(state.pathParameters['cardId']!);
              return RouteAnimations.slideUpTransition(
                key: state.pageKey,
                child: CardFormScreen(cardId: cardId),
              );
            },
          ),
          GoRoute(
            path: 'card/:cardId/detail',
            name: 'card_detail',
            pageBuilder: (context, state) {
              final cardId = int.parse(state.pathParameters['cardId']!);
              return RouteAnimations.fadeTransition(
                key: state.pageKey,
                child: CardDetailScreen(cardId: cardId),
              );
            },
          ),
          GoRoute(
            path: 'card/:cardId/preview',
            name: 'card_preview',
            pageBuilder: (context, state) {
              final cardId = int.parse(state.pathParameters['cardId']!);
              return RouteAnimations.scaleTransition(
                key: state.pageKey,
                child: CardPreviewScreen(cardId: cardId),
              );
            },
          ),
          
          // 公開名片
          GoRoute(
            path: 'public-cards',
            name: 'public_cards',
            pageBuilder: (context, state) => RouteAnimations.slideTransition(
              key: state.pageKey,
              child: const PublicCardsScreen(),
            ),
          ),

          // 群組相關路由
          GoRoute(
            path: 'groups',
            name: 'groups',
            pageBuilder: (context, state) => RouteAnimations.fadeTransition(
              key: state.pageKey,
              child: const GroupsScreen(),
            ),
          ),
          GoRoute(
            path: 'group/create',
            name: 'group_create',
            pageBuilder: (context, state) => RouteAnimations.slideUpTransition(
              key: state.pageKey,
              child: const GroupFormScreen(),
            ),
          ),
          GoRoute(
            path: 'group/:groupId/edit',
            name: 'group_edit',
            pageBuilder: (context, state) {
              final groupId = int.parse(state.pathParameters['groupId']!);
              return RouteAnimations.slideUpTransition(
                key: state.pageKey,
                child: GroupFormScreen(groupId: groupId),
              );
            },
          ),
          GoRoute(
            path: 'group/:groupId/detail',
            name: 'group_detail',
            pageBuilder: (context, state) {
              final groupId = int.parse(state.pathParameters['groupId']!);
              return RouteAnimations.fadeTransition(
                key: state.pageKey,
                child: GroupDetailScreen(groupId: groupId),
              );
            },
          ),

          // 個人檔案相關路由
          GoRoute(
            path: 'profile',
            name: 'profile',
            pageBuilder: (context, state) => RouteAnimations.fadeTransition(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
          GoRoute(
            path: 'profile/edit',
            name: 'profile_edit',
            pageBuilder: (context, state) => RouteAnimations.slideUpTransition(
              key: state.pageKey,
              child: const EditProfileScreen(),
            ),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            pageBuilder: (context, state) => RouteAnimations.slideTransition(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),

          // 搜尋相關路由
          GoRoute(
            path: 'search',
            name: 'search',
            pageBuilder: (context, state) => RouteAnimations.fadeTransition(
              key: state.pageKey,
              child: const SearchScreen(),
            ),
          ),
          GoRoute(
            path: 'search/results',
            name: 'search_results',
            pageBuilder: (context, state) {
              final query = state.uri.queryParameters['query'] ?? '';
              return RouteAnimations.slideTransition(
                key: state.pageKey,
                child: SearchResultsScreen(query: query),
              );
            },
          ),

          // QR 掃描器
          GoRoute(
            path: 'scanner',
            name: 'qr_scanner',
            pageBuilder: (context, state) => RouteAnimations.scaleTransition(
              key: state.pageKey,
              child: const QrScannerScreen(),
            ),
          ),
        ],
      ),
    ],

    // 錯誤處理
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '頁面不存在',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('回到首頁'),
            ),
          ],
        ),
      ),
    ),

    // 重新導向處理
    redirect: (context, state) {
      // 這裡可以添加身份驗證檢查邏輯
      return null; // 不重新導向
    },
  );

  static GoRouter get router => _router;
}