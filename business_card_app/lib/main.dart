import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/card_provider.dart';
import 'providers/group_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/cards/cards_screen.dart';
import 'screens/cards/edit_card_screen.dart';
import 'screens/cards/card_detail_screen.dart';
import 'screens/groups/groups_screen.dart';
import 'screens/groups/group_detail_screen.dart';
import 'screens/home/profile_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/scanner/qr_scanner_screen.dart';
import 'models/card.dart';
import 'core/theme.dart';
import 'core/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: MaterialApp(
        title: 'Digital Business Card',
        theme: AppTheme.lightTheme,
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          AppRoutes.login: (context) => LoginScreen(),
          AppRoutes.register: (context) => RegisterScreen(),
          AppRoutes.forgotPassword: (context) => ForgotPasswordScreen(),
          AppRoutes.home: (context) => HomeScreen(),
          AppRoutes.cards: (context) => CardsScreen(),
          AppRoutes.groups: (context) => GroupsScreen(),
          AppRoutes.profile: (context) => ProfileScreen(),
          AppRoutes.search: (context) => SearchScreen(),
          AppRoutes.qrScanner: (context) => QRScannerScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.editCard:
              final card = settings.arguments as BusinessCard?;
              return MaterialPageRoute(
                builder: (context) => EditCardScreen(card: card),
              );
            case AppRoutes.cardDetail:
              final cardId = settings.arguments as int;
              return MaterialPageRoute(
                builder: (context) => CardDetailScreen(cardId: cardId),
              );
            case AppRoutes.groupDetail:
              final groupId = settings.arguments as int;
              return MaterialPageRoute(
                builder: (context) => GroupDetailScreen(groupId: groupId),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}