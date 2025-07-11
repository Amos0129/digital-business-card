import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/edit_account_page.dart';
import '../screens/login_page.dart';
import '../screens/home_page.dart';
import '../screens/card_group_page.dart';
import '../screens/card_detail_page.dart';
import '../screens/account_page.dart';

import 'constants/app_theme.dart';

import 'models/unified_card.dart';

import 'viewmodels/app_settings.dart';
import 'viewmodels/group_manager_viewmodel.dart';

import '../providers/user_provider.dart';
import '../screens/splash_page.dart';
import '../screens/reset_password_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('languageCode') ?? 'zh';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppSettings(languageCode: langCode),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      locale: settings.locale,
      supportedLocales: const [Locale('zh', 'TW'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashPage(),
      onGenerateRoute: (RouteSettings settings) {
        final uri = Uri.parse(settings.name ?? '');
        //print('Routing to: ${settings.name}');
        //print('Path: ${uri.path}');
        //print('Query parameters: ${uri.queryParameters}');

        if (uri.path == '/login') {
          return MaterialPageRoute(builder: (_) => LoginPage());
        }

        if (uri.path == '/profile') {
          return MaterialPageRoute(builder: (_) => const HomePage());
        }

        if (uri.path == '/groups') {
          return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => GroupManagerViewModel()..loadGroups(),
              child: const CardGroupPage(),
            ),
          );
        }

        if (uri.path == '/settings') {
          return MaterialPageRoute(builder: (_) => const AccountPage());
        }

        if (uri.path == '/editAccount') {
          return MaterialPageRoute(builder: (_) => const EditAccountPage());
        }

        if (uri.path == '/cardDetail') {
          final card = settings.arguments as UnifiedCard;
          return MaterialPageRoute(builder: (_) => CardDetailPage(card: card));
        }

        // 新增：處理重設密碼頁路由，並帶 token 參數
        if (uri.path == '/reset-password') {
          final token = uri.queryParameters['token'];
          if (token != null) {
            return MaterialPageRoute(
              builder: (_) => ResetPasswordPage(token: token),
            );
          }
          // token 不存在就導到登入或錯誤頁
          return MaterialPageRoute(builder: (_) => LoginPage());
        }

        // 預設導到登入頁
        return MaterialPageRoute(builder: (_) => LoginPage());
      },
    );
  }
}
