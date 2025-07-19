// lib/app.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';

class DigitalCardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Digital Business Card',
      theme: CupertinoThemeData(
        primaryColor: AppTheme.primaryColor,
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        textTheme: CupertinoTextThemeData(
          textStyle: AppTheme.body,
          navTitleTextStyle: AppTheme.headline,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return SplashScreen();
          }
          
          return authProvider.isLoggedIn 
              ? MainScreen() 
              : LoginScreen();
        },
      ),
    );
  }
}