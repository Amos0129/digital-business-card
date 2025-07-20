// lib/core/storage/user_preferences.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// 使用者偏好設定管理器
/// 
/// 管理應用程式的使用者偏好設定
/// 包括主題、語言、顯示模式等設定
class UserPreferences {
  // 單例模式
  static final UserPreferences _instance = UserPreferences._internal();
  static UserPreferences get instance => _instance;
  UserPreferences._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  /// 初始化偏好設定管理器
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      
      if (kDebugMode) {
        print('✅ UserPreferences 初始化完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ UserPreferences 初始化失敗: $e');
      }
    }
  }

  /// 檢查是否已初始化
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('UserPreferences 尚未初始化，請先調用 initialize()');
    }
  }

  // ========== 主題相關設定 ==========
  
  /// 獲取主題模式
  ThemeMode getThemeMode() {
    _ensureInitialized();
    final themeString = _prefs.getString(AppConstants.themeModeKey) ?? 'system';
    
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// 設定主題模式
  Future<bool> setThemeMode(ThemeMode themeMode) async {
    _ensureInitialized();
    String themeString;
    
    switch (themeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    
    return await _prefs.setString(AppConstants.themeModeKey, themeString);
  }

  /// 檢查是否為深色主題
  bool isDarkMode() {
    final themeMode = getThemeMode();
    if (themeMode == ThemeMode.dark) return true;
    if (themeMode == ThemeMode.light) return false;
    
    // 系統主題時根據平台亮度判斷
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  // ========== 語言相關設定 ==========
  
  /// 獲取語言設定
  String getLanguage() {
    _ensureInitialized();
    return _prefs.getString(AppConstants.languageKey) ?? 'zh';
  }

  /// 設定語言
  Future<bool> setLanguage(String languageCode) async {
    _ensureInitialized();
    return await _prefs.setString(AppConstants.languageKey, languageCode);
  }

  /// 檢查是否為中文
  bool isChineseLanguage() {
    return getLanguage() == 'zh';
  }

  // ========== 首次啟動相關 ==========
  
  /// 檢查是否為首次啟動
  bool isFirstLaunch() {
    _ensureInitialized();
    return !(_prefs.getBool(AppConstants.firstLaunchKey) ?? false);
  }

  /// 設定已完成首次啟動
  Future<bool> setFirstLaunchCompleted() async {
    _ensureInitialized();
    return await _prefs.setBool(AppConstants.firstLaunchKey, true);
  }

  // ========== 安全相關設定 ==========
  
  /// 檢查是否啟用生物識別
  bool isBiometricEnabled() {
    _ensureInitialized();
    return _prefs.getBool(AppConstants.biometricEnabledKey) ?? false;
  }

  /// 設定生物識別啟用狀態
  Future<bool> setBiometricEnabled(bool enabled) async {
    _ensureInitialized();
    return await _prefs.setBool(AppConstants.biometricEnabledKey, enabled);
  }

  // ========== 通知相關設定 ==========
  
  /// 檢查是否啟用推播通知
  bool isNotificationsEnabled() {
    _ensureInitialized();
    return _prefs.getBool(AppConstants.notificationsEnabledKey) ?? true;
  }

  /// 設定推播通知啟用狀態
  Future<bool> setNotificationsEnabled(bool enabled) async {
    _ensureInitialized();
    return await _prefs.setBool(AppConstants.notificationsEnabledKey, enabled);
  }

  // ========== 顯示相關設定 ==========
  
  /// 獲取名片顯示模式
  String getCardDisplayMode() {
    _ensureInitialized();
    return _prefs.getString('card_display_mode') ?? 'grid';
  }

  /// 設定名片顯示模式
  Future<bool> setCardDisplayMode(String mode) async {
    _ensureInitialized();
    return await _prefs.setString('card_display_mode', mode);
  }

  /// 檢查是否為網格顯示模式
  bool isGridDisplayMode() {
    return getCardDisplayMode() == 'grid';
  }

  /// 獲取預設排序方式
  String getDefaultSort() {
    _ensureInitialized();
    return _prefs.getString('default_sort') ?? 'name';
  }

  /// 設定預設排序方式
  Future<bool> setDefaultSort(String sortBy) async {
    _ensureInitialized();
    return await _prefs.setString('default_sort', sortBy);
  }

  // ========== 音效和震動設定 ==========
  
  /// 檢查是否啟用音效
  bool isSoundEnabled() {
    _ensureInitialized();
    return _prefs.getBool('sound_enabled') ?? false;
  }

  /// 設定音效啟用狀態
  Future<bool> setSoundEnabled(bool enabled) async {
    _ensureInitialized();
    return await _prefs.setBool('sound_enabled', enabled);
  }

  /// 檢查是否啟用震動
  bool isHapticsEnabled() {
    _ensureInitialized();
    return _prefs.getBool('haptics_enabled') ?? true;
  }

  /// 設定震動啟用狀態
  Future<bool> setHapticsEnabled(bool enabled) async {
    _ensureInitialized();
    return await _prefs.setBool('haptics_enabled', enabled);
  }

  // ========== 教學和幫助設定 ==========
  
  /// 檢查是否顯示教學
  bool shouldShowTutorials() {
    _ensureInitialized();
    return _prefs.getBool('show_tutorials') ?? true;
  }

  /// 設定是否顯示教學
  Future<bool> setShowTutorials(bool show) async {
    _ensureInitialized();
    return await _prefs.setBool('show_tutorials', show);
  }

  /// 檢查特定教學是否已完成
  bool isTutorialCompleted(String tutorialId) {
    _ensureInitialized();
    return _prefs.getBool('tutorial_$tutorialId') ?? false;
  }

  /// 設定教學完成狀態
  Future<bool> setTutorialCompleted(String tutorialId, bool completed) async {
    _ensureInitialized();
    return await _prefs.setBool('tutorial_$tutorialId', completed);
  }

  // ========== 快取和效能設定 ==========
  
  /// 獲取頁面大小設定
  int getPageSize() {
    _ensureInitialized();
    return _prefs.getInt('page_size') ?? AppConstants.pageSize;
  }

  /// 設定頁面大小
  Future<bool> setPageSize(int size) async {
    _ensureInitialized();
    return await _prefs.setInt('page_size', size);
  }

  /// 獲取快取過期天數
  int getCacheExpirationDays() {
    _ensureInitialized();
    return _prefs.getInt('cache_expiration_days') ?? 30;
  }

  /// 設定快取過期天數
  Future<bool> setCacheExpirationDays(int days) async {
    _ensureInitialized();
    return await _prefs.setInt('cache_expiration_days', days);
  }

  // ========== 隱私設定 ==========
  
  /// 檢查是否啟用分析追蹤
  bool isAnalyticsEnabled() {
    _ensureInitialized();
    return _prefs.getBool('analytics_enabled') ?? false;
  }

  /// 設定分析追蹤啟用狀態
  Future<bool> setAnalyticsEnabled(bool enabled) async {
    _ensureInitialized();
    return await _prefs.setBool('analytics_enabled', enabled);
  }

  /// 檢查是否啟用自動備份
  bool isAutoBackupEnabled() {
    _ensureInitialized();
    return _prefs.getBool('auto_backup_enabled') ?? true;
  }

  /// 設定自動備份啟用狀態
  Future<bool> setAutoBackupEnabled(bool enabled) async {
    _ensureInitialized();
    return await _prefs.setBool('auto_backup_enabled', enabled);
  }

  // ========== 搜尋和歷史設定 ==========
  
  /// 獲取搜尋歷史
  List<String> getSearchHistory() {
    _ensureInitialized();
    final historyJson = _prefs.getStringList('search_history') ?? [];
    return historyJson.take(AppConstants.maxSearchHistoryCount).toList();
  }

  /// 添加搜尋歷史
  Future<bool> addSearchHistory(String query) async {
    _ensureInitialized();
    
    final history = getSearchHistory();
    
    // 移除重複項目
    history.remove(query);
    
    // 添加到開頭
    history.insert(0, query);
    
    // 限制數量
    final limitedHistory = history.take(AppConstants.maxSearchHistoryCount).toList();
    
    return await _prefs.setStringList('search_history', limitedHistory);
  }

  /// 清除搜尋歷史
  Future<bool> clearSearchHistory() async {
    _ensureInitialized();
    return await _prefs.remove('search_history');
  }

  // ========== 複合設定方法 ==========
  
  /// 獲取所有設定
  Map<String, dynamic> getAllSettings() {
    _ensureInitialized();
    
    return {
      'themeMode': getThemeMode().name,
      'language': getLanguage(),
      'biometricEnabled': isBiometricEnabled(),
      'notificationsEnabled': isNotificationsEnabled(),
      'cardDisplayMode': getCardDisplayMode(),
      'defaultSort': getDefaultSort(),
      'soundEnabled': isSoundEnabled(),
      'hapticsEnabled': isHapticsEnabled(),
      'showTutorials': shouldShowTutorials(),
      'pageSize': getPageSize(),
      'cacheExpirationDays': getCacheExpirationDays(),
      'analyticsEnabled': isAnalyticsEnabled(),
      'autoBackupEnabled': isAutoBackupEnabled(),
    };
  }

  /// 匯出設定到 JSON
  String exportSettings() {
    return jsonEncode(getAllSettings());
  }

  /// 從 JSON 匯入設定
  Future<bool> importSettings(String jsonString) async {
    try {
      final settings = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // 逐一設定各項設定
      if (settings.containsKey('themeMode')) {
        final themeModeString = settings['themeMode'] as String;
        ThemeMode themeMode;
        switch (themeModeString) {
          case 'light':
            themeMode = ThemeMode.light;
            break;
          case 'dark':
            themeMode = ThemeMode.dark;
            break;
          default:
            themeMode = ThemeMode.system;
        }
        await setThemeMode(themeMode);
      }
      
      if (settings.containsKey('language')) {
        await setLanguage(settings['language']);
      }
      
      if (settings.containsKey('biometricEnabled')) {
        await setBiometricEnabled(settings['biometricEnabled']);
      }
      
      if (settings.containsKey('notificationsEnabled')) {
        await setNotificationsEnabled(settings['notificationsEnabled']);
      }
      
      // ... 其他設定
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 匯入設定失敗: $e');
      }
      return false;
    }
  }

  /// 重設所有設定為預設值
  Future<bool> resetToDefaults() async {
    _ensureInitialized();
    
    try {
      // 保留首次啟動標記
      final isFirstLaunchCompleted = !isFirstLaunch();
      
      // 清除所有設定
      await _prefs.clear();
      
      // 恢復首次啟動標記
      if (isFirstLaunchCompleted) {
        await setFirstLaunchCompleted();
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 重設設定失敗: $e');
      }
      return false;
    }
  }