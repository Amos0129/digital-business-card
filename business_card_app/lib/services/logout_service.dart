import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_provider.dart';
import '../main.dart';

class LogoutService {
  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.setBool('just_logged_out', true);

    // 使用傳進來的 context，較安全
    Provider.of<UserProvider>(context, listen: false).clear();

    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }
}
