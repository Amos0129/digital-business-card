// lib/providers/group_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];
  bool _isLoading = false;
  
  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  
  // 載入群組
  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiClient.get(ApiEndpoints.groupsByUser, needAuth: true);
      _groups = (response as List)
          .map((json) => Group.fromJson(json))
          .toList();
    } catch (e) {
      print('載入群組錯誤: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 建立群組
  Future<bool> createGroup(String name) async {
    try {
      final response = await ApiClient.post(
        ApiEndpoints.createGroup, 
        {'name': name}, 
        needAuth: true
      );
      
      final newGroup = Group.fromJson(response);
      _groups.add(newGroup);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // 重命名群組
  Future<bool> renameGroup(int groupId, String newName) async {
    try {
      final response = await ApiClient.put(
        ApiEndpoints.renameGroup(groupId), 
        {'name': newName}, 
        needAuth: true
      );
      
      final updatedGroup = Group.fromJson(response);
      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        _groups[index] = updatedGroup;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // 刪除群組
  Future<bool> deleteGroup(int groupId) async {
    try {
      await ApiClient.delete(ApiEndpoints.deleteGroup(groupId), needAuth: true);
      _groups.removeWhere((group) => group.id == groupId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}