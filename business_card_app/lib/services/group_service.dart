import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

import '../models/group_model.dart';
import '../constants/api_routes.dart';
import '../services/api_client.dart';

class GroupService {
  final ApiClient api;
  static const _box = 'groupsBox';
  bool? lastFromCache;

  GroupService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<GroupModel> createGroup(String name) async {
    final uri = ApiRoutes.createGroup(name);
    final response = await api.post(uri, null, auth: true);

    if (response.statusCode != 200) {
      throw Exception('新增群組失敗: ${response.body}');
    }

    await _clearCache();

    final jsonData = jsonDecode(response.body);
    return GroupModel.fromJson(jsonData);
  }

  Future<GroupModel> getOrCreateUncategorizedGroup() async {
    final uri = ApiRoutes.getUncategorizedGroup();
    final response = await api.get(uri, auth: true);

    if (response.statusCode != 200) {
      throw Exception('取得預設群組失敗: ${response.body}');
    }

    final jsonData = jsonDecode(response.body);
    return GroupModel.fromJson(jsonData);
  }

  Future<List<GroupModel>> getGroupsByUser() async {
    const key = 'userGroups';
    final box = await Hive.openBox(_box);

    final cached = box.get(key);
    if (cached != null && cached is List) {
      try {
        final list = List<Map<String, dynamic>>.from(cached);
        lastFromCache = true; // ✅ 來自快取
        return list.map((e) => GroupModel.fromJson(e)).toList();
      } catch (_) {}
    }

    // 👉 fallback: 走 API
    final uri = ApiRoutes.getGroupsByUser();
    final response = await api.get(uri, auth: true);

    if (response.statusCode != 200) {
      throw Exception('讀取群組失敗: ${response.body}');
    }

    final List<dynamic> jsonList = jsonDecode(response.body);
    await box.put(key, jsonList); // ✅ 存快取
    lastFromCache = false;
    return jsonList.map((json) => GroupModel.fromJson(json)).toList();
  }

  Future<void> renameGroup(int groupId, String newName) async {
    final uri = ApiRoutes.renameGroup(groupId, newName);
    final response = await api.put(uri, null, auth: true);

    if (response.statusCode != 200) {
      throw Exception('修改群組失敗: ${response.body}');
    }
    await _clearCache();
  }

  Future<void> deleteGroup(int groupId) async {
    final uri = ApiRoutes.deleteGroup(groupId);
    final response = await api.delete(uri, auth: true);

    if (response.statusCode != 200) {
      throw Exception('刪除群組失敗: ${response.body}');
    }
    await _clearCache();
  }

  Future<void> _clearCache() async {
    final box = await Hive.openBox(_box);
    await box.clear();
  }
}
