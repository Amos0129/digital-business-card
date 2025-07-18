import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/user.dart';
import '../models/card.dart';
import '../models/group.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // JWT Token 相關
  Future<void> saveToken(String token) async {
    await _prefs!.setString(AppConstants.keyJwtToken, token);
  }

  Future<String?> getToken() async {
    return _prefs!.getString(AppConstants.keyJwtToken);
  }

  Future<void> clearToken() async {
    await _prefs!.remove(AppConstants.keyJwtToken);
  }

  Future<bool> hasToken() async {
    return _prefs!.containsKey(AppConstants.keyJwtToken);
  }

  // 使用者資料相關
  Future<void> saveUser(User user) async {
    final userJson = json.encode(user.toJson());
    await _prefs!.setString(AppConstants.keyUserData, userJson);
  }

  Future<User?> getUser() async {
    final userJson = _prefs!.getString(AppConstants.keyUserData);
    if (userJson != null) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearUser() async {
    await _prefs!.remove(AppConstants.keyUserData);
  }

  // 記住我功能
  Future<void> setRememberMe(bool remember) async {
    await _prefs!.setBool(AppConstants.keyRememberMe, remember);
  }

  Future<bool> getRememberMe() async {
    return _prefs!.getBool(AppConstants.keyRememberMe) ?? false;
  }

  // 快取名片資料
  Future<void> cacheCards(List<BusinessCard> cards) async {
    final cardsJson = json.encode(cards.map((card) => card.toJson()).toList());
    await _prefs!.setString('cached_cards', cardsJson);
    await _prefs!.setInt('cards_cache_time', DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<BusinessCard>?> getCachedCards() async {
    final cardsJson = _prefs!.getString('cached_cards');
    final cacheTime = _prefs!.getInt('cards_cache_time');
    
    if (cardsJson != null && cacheTime != null) {
      // 檢查快取是否過期（例如：1小時）
      final now = DateTime.now().millisecondsSinceEpoch;
      const cacheExpiry = 60 * 60 * 1000; // 1小時
      
      if (now - cacheTime < cacheExpiry) {
        try {
          final cardsList = json.decode(cardsJson) as List;
          return cardsList.map((json) => BusinessCard.fromJson(json)).toList();
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  Future<void> clearCachedCards() async {
    await _prefs!.remove('cached_cards');
    await _prefs!.remove('cards_cache_time');
  }

  // 快取群組資料
  Future<void> cacheGroups(List<CardGroup> groups) async {
    final groupsJson = json.encode(groups.map((group) => group.toJson()).toList());
    await _prefs!.setString('cached_groups', groupsJson);
    await _prefs!.setInt('groups_cache_time', DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<CardGroup>?> getCachedGroups() async {
    final groupsJson = _prefs!.getString('cached_groups');
    final cacheTime = _prefs!.getInt('groups_cache_time');
    
    if (groupsJson != null && cacheTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      const cacheExpiry = 60 * 60 * 1000; // 1小時
      
      if (now - cacheTime < cacheExpiry) {
        try {
          final groupsList = json.decode(groupsJson) as List;
          return groupsList.map((json) => CardGroup.fromJson(json)).toList();
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  Future<void> clearCachedGroups() async {
    await _prefs!.remove('cached_groups');
    await _prefs!.remove('groups_cache_time');
  }

  // 應用設定
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    final settingsJson = json.encode(settings);
    await _prefs!.setString('app_settings', settingsJson);
  }

  Future<Map<String, dynamic>?> getAppSettings() async {
    final settingsJson = _prefs!.getString('app_settings');
    if (settingsJson != null) {
      try {
        return json.decode(settingsJson) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // 主題設定
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs!.setString('theme_mode', themeMode);
  }

  Future<String?> getThemeMode() async {
    return _prefs!.getString('theme_mode');
  }

  // 語言設定
  Future<void> saveLanguage(String languageCode) async {
    await _prefs!.setString('language', languageCode);
  }

  Future<String?> getLanguage() async {
    return _prefs!.getString('language');
  }

  // 搜尋歷史
  Future<void> addSearchHistory(String query) async {
    final history = await getSearchHistory();
    history.remove(query); // 移除重複項目
    history.insert(0, query); // 加到最前面
    
    // 限制歷史記錄數量
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
    
    await _prefs!.setStringList('search_history', history);
  }

  Future<List<String>> getSearchHistory() async {
    return _prefs!.getStringList('search_history') ?? [];
  }

  Future<void> clearSearchHistory() async {
    await _prefs!.remove('search_history');
  }

  // 最近瀏覽的名片
  Future<void> addRecentCard(int cardId) async {
    final recent = await getRecentCards();
    recent.remove(cardId); // 移除重複項目
    recent.insert(0, cardId); // 加到最前面
    
    // 限制數量
    if (recent.length > 10) {
      recent.removeRange(10, recent.length);
    }
    
    await _prefs!.setStringList('recent_cards', 
        recent.map((id) => id.toString()).toList());
  }

  Future<List<int>> getRecentCards() async {
    final recentStrings = _prefs!.getStringList('recent_cards') ?? [];
    return recentStrings.map((str) => int.parse(str)).toList();
  }

  Future<void> clearRecentCards() async {
    await _prefs!.remove('recent_cards');
  }

  // 離線資料同步標記
  Future<void> markForSync(String syncType, Map<String, dynamic> data) async {
    final syncQueue = await getSyncQueue();
    syncQueue.add({
      'type': syncType,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    final queueJson = json.encode(syncQueue);
    await _prefs!.setString('sync_queue', queueJson);
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final queueJson = _prefs!.getString('sync_queue');
    if (queueJson != null) {
      try {
        final queueList = json.decode(queueJson) as List;
        return queueList.cast<Map<String, dynamic>>();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  Future<void> clearSyncQueue() async {
    await _prefs!.remove('sync_queue');
  }

  // 清除所有資料
  Future<void> clearAll() async {
    await _prefs!.clear();
  }

  // 清除快取資料
  Future<void> clearAllCache() async {
    await clearCachedCards();
    await clearCachedGroups();
    await clearSearchHistory();
    await clearRecentCards();
    await clearSyncQueue();
  }
}