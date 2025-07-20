// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app.dart';
import 'core/services/navigation_service.dart';
import 'core/storage/secure_storage.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/card_provider.dart';
import 'presentation/providers/group_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/search_provider.dart';

/// 應用程式入口點
/// 
/// 負責：
/// - 初始化核心服務
/// - 配置狀態管理提供者
/// - 設定系統UI樣式
/// - 啟動應用程式
void main() async {
  // 確保 Flutter 綁定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化核心服務
  await _initializeServices();
  
  // 設定系統UI樣式
  _configureSystemUI();
  
  // 啟動應用程式
  runApp(
    MultiProvider(
      providers: _createProviders(),
      child: const DigitalCardApp(),
    ),
  );
}

/// 初始化核心服務
Future<void> _initializeServices() async {
  try {
    // 初始化安全儲存
    await SecureStorage.instance.initialize();
    
    // 初始化導航服務
    NavigationService.instance.initialize();
    
    print('✅ 核心服務初始化完成');
  } catch (e) {
    print('❌ 核心服務初始化失敗: $e');
  }
}

/// 配置系統UI樣式
void _configureSystemUI() {
  // 設定狀態列樣式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 設定支援的螢幕方向
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// 創建狀態管理提供者
List<ChangeNotifierProvider> _createProviders() {
  return [
    // 主題提供者
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
    ),
    
    // 認證提供者
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
    ),
    
    // 名片提供者
    ChangeNotifierProvider(
      create: (_) => CardProvider(),
    ),
    
    // 群組提供者
    ChangeNotifierProvider(
      create: (_) => GroupProvider(),
    ),
    
    // 搜尋提供者
    ChangeNotifierProvider(
      create: (_) => SearchProvider(),
    ),
  ];
}