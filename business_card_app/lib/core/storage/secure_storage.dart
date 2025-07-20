// lib/core/storage/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// 安全儲存服務
/// 
/// 提供安全的本地資料儲存功能
/// 用於儲存敏感資訊如 JWT Token
class SecureStorage {
  // 單例模式
  static final SecureStorage _instance = SecureStorage._internal();
  static SecureStorage get instance => _instance;
  SecureStorage._internal();

  /// FlutterSecureStorage 實例
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// 初始化
  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('✅ SecureStorage 初始化完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SecureStorage 初始化失敗: $e');
      }
    }
  }

  /// 儲存資料
  Future<void> store(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 儲存失敗 [$key]: $e');
      }
      rethrow;
    }
  }

  /// 讀取資料
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 讀取失敗 [$key]: $e');
      }
      return null;
    }
  }

  /// 刪除資料
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 刪除失敗 [$key]: $e');
      }
    }
  }

  /// 清除所有資料
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 清除所有資料失敗: $e');
      }
    }
  }

  /// 檢查資料是否存在
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 檢查鍵值失敗 [$key]: $e');
      }
      return false;
    }
  }

  /// 獲取所有鍵值
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 讀取所有資料失敗: $e');
      }
      return {};
    }
  }
}