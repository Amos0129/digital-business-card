// lib/core/storage/cache_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// 快取管理器
/// 
/// 提供本地快取功能
/// 支援資料過期、自動清理等功能
class CacheManager {
  // 單例模式
  static final CacheManager _instance = CacheManager._internal();
  static CacheManager get instance => _instance;
  CacheManager._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  /// 初始化快取管理器
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      
      // 清理過期的快取
      await _cleanExpiredCache();
      
      if (kDebugMode) {
        print('✅ CacheManager 初始化完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheManager 初始化失敗: $e');
      }
    }
  }

  /// 檢查是否已初始化
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('CacheManager 尚未初始化，請先調用 initialize()');
    }
  }

  /// 儲存字串到快取
  Future<bool> setString(
    String key,
    String value, {
    Duration? expiration,
  }) async {
    _ensureInitialized();
    
    try {
      final cacheData = CacheData(
        value: value,
        createdAt: DateTime.now(),
        expiresAt: expiration != null 
            ? DateTime.now().add(expiration)
            : null,
      );
      
      final jsonString = jsonEncode(cacheData.toJson());
      return await _prefs.setString(_getCacheKey(key), jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 快取儲存失敗 [$key]: $e');
      }
      return false;
    }
  }

  /// 從快取讀取字串
  Future<String?> getString(String key) async {
    _ensureInitialized();
    
    try {
      final jsonString = _prefs.getString(_getCacheKey(key));
      if (jsonString == null) return null;
      
      final cacheData = CacheData.fromJson(jsonDecode(jsonString));
      
      // 檢查是否過期
      if (cacheData.isExpired) {
        await remove(key);
        return null;
      }
      
      return cacheData.value;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 快取讀取失敗 [$key]: $e');
      }
      return null;
    }
  }

  /// 儲存物件到快取
  Future<bool> setObject<T>(
    String key,
    T object, {
    Duration? expiration,
  }) async {
    try {
      final jsonString = jsonEncode(object);
      return await setString(key, jsonString, expiration: expiration);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 物件快取失敗 [$key]: $e');
      }
      return false;
    }
  }

  /// 從快取讀取物件
  Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) return null;
      
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 物件快取讀取失敗 [$key]: $e');
      }
      return null;
    }
  }

  /// 儲存列表到快取
  Future<bool> setList<T>(
    String key,
    List<T> list, {
    Duration? expiration,
  }) async {
    try {
      final jsonString = jsonEncode(list);
      return await setString(key, jsonString, expiration: expiration);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 列表快取失敗 [$key]: $e');
      }
      return false;
    }
  }

  /// 從快取讀取列表
  Future<List<T>?> getList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) return null;
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .cast<Map<String, dynamic>>()
          .map(fromJson)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 列表快取讀取失敗 [$key]: $e');
      }
      return null;
    }
  }

  /// 檢查快取是否存在且未過期
  Future<bool> exists(String key) async {
    final value = await getString(key);
    return value != null;
  }

  /// 移除快取
  Future<bool> remove(String key) async {
    _ensureInitialized();
    return await _prefs.remove(_getCacheKey(key));
  }

  /// 清除所有快取
  Future<bool> clear() async {
    _ensureInitialized();
    
    try {
      final keys = _prefs.getKeys()
          .where((key) => key.startsWith('cache_'))
          .toList();
      
      for (final key in keys) {
        await _prefs.remove(key);
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 清除快取失敗: $e');
      }
      return false;
    }
  }

  /// 獲取快取大小
  Future<Map<String, dynamic>> getCacheInfo() async {
    _ensureInitialized();
    
    final keys = _prefs.getKeys()
        .where((key) => key.startsWith('cache_'))
        .toList();
    
    int totalSize = 0;
    int expiredCount = 0;
    
    for (final key in keys) {
      final value = _prefs.getString(key);
      if (value != null) {
        totalSize += value.length;
        
        try {
          final cacheData = CacheData.fromJson(jsonDecode(value));
          if (cacheData.isExpired) {
            expiredCount++;
          }
        } catch (e) {
          // 忽略解析錯誤
        }
      }
    }
    
    return {
      'totalKeys': keys.length,
      'expiredKeys': expiredCount,
      'totalSize': totalSize,
      'formattedSize': _formatBytes(totalSize),
    };
  }

  /// 清理過期的快取
  Future<void> _cleanExpiredCache() async {
    try {
      final keys = _prefs.getKeys()
          .where((key) => key.startsWith('cache_'))
          .toList();
      
      int cleanedCount = 0;
      
      for (final key in keys) {
        final value = _prefs.getString(key);
        if (value != null) {
          try {
            final cacheData = CacheData.fromJson(jsonDecode(value));
            if (cacheData.isExpired) {
              await _prefs.remove(key);
              cleanedCount++;
            }
          } catch (e) {
            // 移除無法解析的快取項目
            await _prefs.remove(key);
            cleanedCount++;
          }
        }
      }
      
      if (kDebugMode && cleanedCount > 0) {
        print('🧹 已清理 $cleanedCount 個過期快取項目');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 清理過期快取失敗: $e');
      }
    }
  }

  /// 生成快取鍵
  String _getCacheKey(String key) => 'cache_$key';

  /// 格式化位元組大小
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 預設快取方法
  /// 
  /// 快取使用者資料
  Future<bool> cacheUserData(Map<String, dynamic> userData) async {
    return await setObject(
      AppConstants.userDataKey,
      userData,
      expiration: const Duration(days: 7),
    );
  }

  /// 獲取快取的使用者資料
  Future<Map<String, dynamic>?> getCachedUserData() async {
    return await getObject(
      AppConstants.userDataKey,
      (json) => json,
    );
  }

  /// 快取搜尋歷史
  Future<bool> cacheSearchHistory(List<String> history) async {
    final limitedHistory = history.take(AppConstants.maxSearchHistoryCount).toList();
    return await setList(
      AppConstants.searchHistoryKey,
      limitedHistory,
      expiration: const Duration(days: 30),
    );
  }

  /// 獲取搜尋歷史
  Future<List<String>?> getSearchHistory() async {
    return await getList(
      AppConstants.searchHistoryKey,
      (json) => json.toString(),
    );
  }

  /// 快取最近瀏覽的名片
  Future<bool> cacheRecentCards(List<Map<String, dynamic>> cards) async {
    final limitedCards = cards.take(AppConstants.maxRecentCardsCount).toList();
    return await setList(
      AppConstants.recentCardsKey,
      limitedCards,
      expiration: const Duration(days: 7),
    );
  }

  /// 獲取最近瀏覽的名片
  Future<List<Map<String, dynamic>>?> getRecentCards() async {
    return await getList(
      AppConstants.recentCardsKey,
      (json) => json,
    );
  }
}

/// 快取資料模型
class CacheData {
  final String value;
  final DateTime createdAt;
  final DateTime? expiresAt;

  CacheData({
    required this.value,
    required this.createdAt,
    this.expiresAt,
  });

  /// 檢查是否過期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// 從 JSON 創建
  factory CacheData.fromJson(Map<String, dynamic> json) {
    return CacheData(
      value: json['value'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }
}