// lib/core/utils/device_utils.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_dimensions.dart';

/// 設備工具類
/// 
/// 提供設備相關的工具方法
/// 包括設備資訊、螢幕資訊、平台檢測等
class DeviceUtils {
  // 防止實例化
  DeviceUtils._();

  /// 設備資訊快取
  static DeviceInfoPlugin? _deviceInfo;
  static PackageInfo? _packageInfo;

  /// 初始化設備資訊
  static Future<void> initialize() async {
    _deviceInfo = DeviceInfoPlugin();
    _packageInfo = await PackageInfo.fromPlatform();
  }

  // ========== 平台檢測 ==========
  
  /// 檢查是否為 Android 平台
  static bool get isAndroid => Platform.isAndroid;
  
  /// 檢查是否為 iOS 平台
  static bool get isIOS => Platform.isIOS;
  
  /// 檢查是否為移動平台
  static bool get isMobile => isAndroid || isIOS;
  
  /// 檢查是否為桌面平台
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  
  /// 檢查是否為網頁平台
  static bool get isWeb => false; // 這裡簡化處理，實際可用 kIsWeb

  // ========== 螢幕資訊 ==========
  
  /// 獲取螢幕尺寸
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
  
  /// 獲取螢幕寬度
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  /// 獲取螢幕高度
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  /// 獲取螢幕密度
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }
  
  /// 獲取狀態列高度
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
  
  /// 獲取底部安全區域高度
  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
  
  /// 檢查是否有瀏海屏或安全區域
  static bool hasNotch(BuildContext context) {
    return MediaQuery.of(context).padding.top > 24;
  }

  // ========== 設備類型判斷 ==========
  
  /// 檢查是否為手機
  static bool isPhone(BuildContext context) {
    final width = getScreenWidth(context);
    return width < AppDimensions.breakpointTablet;
  }
  
  /// 檢查是否為平板
  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= AppDimensions.breakpointTablet && 
           width < AppDimensions.breakpointDesktop;
  }
  
  /// 檢查是否為大螢幕設備
  static bool isLargeScreen(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= AppDimensions.breakpointDesktop;
  }
  
  /// 檢查螢幕方向
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  /// 檢查是否為橫屏
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // ========== 設備規格檢測 ==========
  
  /// 檢查是否為高端設備
  static Future<bool> isHighEndDevice() async {
    if (isAndroid) {
      final androidInfo = await _deviceInfo!.androidInfo;
      // 簡單判斷：Android 8.0+ 且 RAM > 4GB
      return androidInfo.version.sdkInt >= 26;
    } else if (isIOS) {
      final iosInfo = await _deviceInfo!.iosInfo;
      // 簡單判斷：iOS 12.0+
      final version = iosInfo.systemVersion.split('.').first;
      return int.tryParse(version) ?? 0 >= 12;
    }
    return false;
  }
  
  /// 獲取設備型號
  static Future<String> getDeviceModel() async {
    if (isAndroid) {
      final androidInfo = await _deviceInfo!.androidInfo;
      return '${androidInfo.manufacturer} ${androidInfo.model}';
    } else if (isIOS) {
      final iosInfo = await _deviceInfo!.iosInfo;
      return iosInfo.model;
    }
    return 'Unknown';
  }
  
  /// 獲取作業系統版本
  static Future<String> getOSVersion() async {
    if (isAndroid) {
      final androidInfo = await _deviceInfo!.androidInfo;
      return 'Android ${androidInfo.version.release}';
    } else if (isIOS) {
      final iosInfo = await _deviceInfo!.iosInfo;
      return 'iOS ${iosInfo.systemVersion}';
    }
    return 'Unknown';
  }

  // ========== 應用程式資訊 ==========
  
  /// 獲取應用程式版本
  static String getAppVersion() {
    return _packageInfo?.version ?? '1.0.0';
  }
  
  /// 獲取應用程式建置編號
  static String getBuildNumber() {
    return _packageInfo?.buildNumber ?? '1';
  }
  
  /// 獲取應用程式包名
  static String getPackageName() {
    return _packageInfo?.packageName ?? '';
  }
  
  /// 獲取應用程式名稱
  static String getAppName() {
    return _packageInfo?.appName ?? '';
  }

  // ========== 系統功能檢測 ==========
  
  /// 檢查是否支援生物識別
  static Future<bool> supportsBiometric() async {
    // 這裡可以整合 local_auth 套件來檢測
    // 暫時根據平台和版本簡單判斷
    if (isAndroid) {
      final androidInfo = await _deviceInfo!.androidInfo;
      return androidInfo.version.sdkInt >= 23; // Android 6.0+
    } else if (isIOS) {
      final iosInfo = await _deviceInfo!.iosInfo;
      final version = iosInfo.systemVersion.split('.').first;
      return int.tryParse(version) ?? 0 >= 8; // iOS 8.0+
    }
    return false;
  }
  
  /// 檢查是否支援相機
  static bool supportsCamera() {
    // 大部分移動設備都支援相機
    return isMobile;
  }
  
  /// 檢查是否支援震動
  static bool supportsHaptics() {
    return isMobile;
  }

  // ========== 網路資訊 ==========
  
  /// 獲取使用者代理字串
  static Future<String> getUserAgent() async {
    final deviceModel = await getDeviceModel();
    final osVersion = await getOSVersion();
    final appVersion = getAppVersion();
    
    return 'DigitalCard/$appVersion ($deviceModel; $osVersion)';
  }

  // ========== 效能工具 ==========
  
  /// 檢查是否應該啟用高品質動畫
  static Future<bool> shouldEnableHighQualityAnimations() async {
    return await isHighEndDevice();
  }
  
  /// 獲取建議的圖片品質
  static Future<int> getRecommendedImageQuality() async {
    final isHighEnd = await isHighEndDevice();
    return isHighEnd ? 90 : 70;
  }
  
  /// 獲取建議的快取大小
  static Future<int> getRecommendedCacheSize() async {
    final isHighEnd = await isHighEndDevice();
    return isHighEnd ? 100 : 50; // MB
  }

  // ========== 系統控制 ==========
  
  /// 震動
  static void vibrate() {
    if (supportsHaptics()) {
      HapticFeedback.lightImpact();
    }
  }
  
  /// 強烈震動
  static void vibrateHeavy() {
    if (supportsHaptics()) {
      HapticFeedback.heavyImpact();
    }
  }
  
  /// 選擇震動
  static void vibrateSelection() {
    if (supportsHaptics()) {
      HapticFeedback.selectionClick();
    }
  }
  
  /// 隱藏鍵盤
  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
  
  /// 設定狀態列樣式
  static void setStatusBarStyle({
    required bool isDark,
    Color? statusBarColor,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: statusBarColor ?? Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }
  
  /// 設定螢幕方向
  static void setOrientation(List<DeviceOrientation> orientations) {
    SystemChrome.setPreferredOrientations(orientations);
  }
  
  /// 設定為僅直向
  static void setPortraitOnly() {
    setOrientation([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  /// 設定為僅橫向
  static void setLandscapeOnly() {
    setOrientation([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
  
  /// 恢復所有方向
  static void setAllOrientations() {
    setOrientation(DeviceOrientation.values);
  }

  // ========== 偵錯工具 ==========
  
  /// 獲取設備詳細資訊
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceModel = await getDeviceModel();
    final osVersion = await getOSVersion();
    final isHighEnd = await isHighEndDevice();
    final supportsBio = await supportsBiometric();
    
    return {
      'platform': Platform.operatingSystem,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'appVersion': getAppVersion(),
      'buildNumber': getBuildNumber(),
      'packageName': getPackageName(),
      'isHighEndDevice': isHighEnd,
      'supportsBiometric': supportsBio,
      'supportsCamera': supportsCamera(),
      'supportsHaptics': supportsHaptics(),
    };
  }
  
  /// 列印設備資訊
  static Future<void> printDeviceInfo() async {
    final info = await getDeviceInfo();
    print('📱 設備資訊:');
    info.forEach((key, value) {
      print('  $key: $value');
    });
  }
}