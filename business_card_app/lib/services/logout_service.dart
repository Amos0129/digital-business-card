import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import '../providers/user_provider.dart';
import '../main.dart';

class LogoutService {
  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.setBool('just_logged_out', true);

    // ✅ 清除所有 Hive 快取資料
    await Hive.deleteBoxFromDisk('cardsBox'); // 個人名片快取
    await Hive.deleteBoxFromDisk('cardGroupBox'); // 群組與卡片快取
    await Hive.deleteBoxFromDisk('groupsBox'); // 群組快取

    // ✅ 清除使用者資料
    Provider.of<UserProvider>(context, listen: false).clear();

    // ✅ 導回登入畫面
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }
}
