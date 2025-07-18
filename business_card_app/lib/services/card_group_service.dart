import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import '../models/group_model.dart';
import '../models/card_group_dto.dart';
import '../constants/api_routes.dart';
import '../services/api_client.dart';

class CardGroupService {
  final ApiClient api;

  static const _box = 'cardGroupBox';
  bool? lastFromCache;

  CardGroupService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<List<GroupModel>> getGroupsByUser() async {
    final url = ApiRoutes.getGroupsByUser();
    final response = await api.get(url, auth: true);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => GroupModel.fromJson(json)).toList();
    } else {
      throw Exception('讀取使用者群組失敗: ${response.body}');
    }
  }

  Future<CardGroupDto?> getGroupOfCardForUser(int cardId) async {
    final url = ApiRoutes.getGroupOfCard(cardId);
    final response = await api.get(url, auth: true);

    if (response.statusCode == 404 || response.body.trim().isEmpty) {
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception('無法查詢名片所屬群組: ${response.body}');
    }

    try {
      final json = jsonDecode(response.body);
      return CardGroupDto.fromJson(json);
    } catch (e) {
      throw Exception('⚠️ 解析群組資料失敗: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getCardsByGroup(int groupId) async {
    final key = 'group_$groupId';
    final box = await Hive.openBox(_box);

    final cached = box.get(key);
    if (cached != null && cached is List) {
      try {
        final list = List<Map<String, dynamic>>.from(cached);
        lastFromCache = true;
        return list;
      } catch (_) {
        // fallback to API below
      }
    }

    // API fallback
    final url = ApiRoutes.getCardsByGroup(groupId);
    final response = await api.get(url, auth: true);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      await box.put(key, data);
      lastFromCache = false;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('讀取群組卡片失敗: ${response.body}');
    }
  }

  Future<void> changeCardGroup(int cardId, int groupId) async {
    final url = ApiRoutes.changeCardGroup(cardId, groupId);
    final response = await api.put(url, null, auth: true);

    if (response.statusCode != 200) {
      throw Exception('❌ 無法變更群組: ${response.body}');
    }
    await _clearCache();
  }

  Future<void> addCardToGroup(int cardId, int groupId) async {
    final url = ApiRoutes.addCardToGroup(cardId, groupId);
    final response = await api.post(url, null, auth: true);

    if (response.statusCode != 200) {
      throw Exception('無法加入群組: ${response.body}');
    }
    await _clearCache();
  }

  Future<void> removeCardFromGroup(int cardId, int groupId) async {
    final url = ApiRoutes.removeCardFromGroup(cardId, groupId);
    final response = await api.delete(url, auth: true);

    if (response.statusCode != 200) {
      throw Exception('無法移除群組: ${response.body}');
    }
    await _clearCache();
  }

  Future<List<Map<String, dynamic>>> getCardsByUser() async {
    const key = 'userCardGroups';
    final box = await Hive.openBox(_box);

    final cached = box.get(key);
    if (cached != null && cached is List) {
      try {
        final list = List<Map<String, dynamic>>.from(cached);
        lastFromCache = true; // ✅ 來自快取
        return list;
      } catch (_) {}
    }

    // 👉 fallback: 走 API
    final url = ApiRoutes.getMyCardGroups();
    final response = await api.get(url, auth: true);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      await box.put(key, data); // ✅ 存入快取
      lastFromCache = false;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('讀取使用者卡片失敗: ${response.body}');
    }
  }

  Future<void> _clearCache() async {
    final box = await Hive.openBox(_box);
    await box.clear(); // 清除這個 box 裡所有快取資料
  }
}
