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
      routes: {
        '/login': (_) => LoginPage(),
        '/profile': (_) => const HomePage(),
        '/groups': (_) => ChangeNotifierProvider(
          create: (_) => GroupManagerViewModel()..loadGroups(),
          child: const CardGroupPage(),
        ),
        '/settings': (_) => const AccountPage(),
        '/editAccount': (_) => const EditAccountPage(),
        '/cardDetail': (context) {
          final card =
              ModalRoute.of(context)!.settings.arguments as UnifiedCard;
          return CardDetailPage(card: card);
        },
      },
    );
  }
}
