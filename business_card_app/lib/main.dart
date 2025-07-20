// lib/main.dart - 修正版本
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/card_provider.dart';
import 'providers/group_provider.dart';
import 'app.dart'; // 使用 app.dart 中的 DigitalCardApp

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
      child: DigitalCardApp(), // 使用 DigitalCardApp 而不是重複的路由設定
    );
  }
}