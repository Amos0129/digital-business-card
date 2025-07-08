import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/user_service.dart';
import '../providers/user_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final userService = UserService();
      final user = await userService.getMe();

      if (!mounted) return;

      if (user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
