import 'package:flutter/foundation.dart';
import '../models/group.dart';
import '../models/card.dart';
import '../services/group_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupService _groupService = GroupService();
  
  List<CardGroup> _groups = [];
  List<CardWithGroup> _cardsWithGroups = [];
  CardGroup? _selectedGroup;
  bool _isLoading = false;
  String? _errorMessage;
  Map<int, List<BusinessCard>> _groupCardsCache = {};

  // Getters
  List<CardGroup> get groups => _groups;
  List<CardWithGroup> get cardsWithGroups => _cardsWithGroups;
  CardGroup? get selectedGroup => _selectedGroup;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // 是否有群組
  bool get hasGroups => _groups.isNotEmpty;
  
  // 取得群組數量
  int get groupsCount => _groups.length;

  // 載入使用者的群組
  Future<void> loadGroups() async {
    _setLoading(true);
    _clearError();

    try {
      final groups = await _groupService.getGroupsByUser();
      _groups = groups;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // 載入帶群組資訊的名片
  Future<void> loadCardsWithGroups() async {
    _setLoading(true);
    _clearError();

    try {
      final cardsWithGroups = await _groupService.getCardsWithGroups();
      _cardsWithGroups = cardsWithGroups;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // 建立群組
  Future<bool> createGroup(String groupName) async {
    _setLoading(true);
    _clearError();

    try {
      final newGroup = await _groupService.createGroup(groupName);
      _groups.add(newGroup);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 重新命名群組
  Future<bool> renameGroup(int groupId, String newName) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedGroup = await _groupService.renameGroup(groupId, newName);
      
      // 更新本地清單中的群組
      final index = _groups.indexWhere((group) => group.id == groupId);
      if (index != -1) {
        _groups[index] = updatedGroup;
      }
      
      // 如果是選中的群組，也要更新
      if (_selectedGroup?.id == groupId) {
        _selectedGroup = updatedGroup;
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 刪除群組
  Future<bool> deleteGroup(int groupId) async {
    _setLoading(true);
    _clearError();

    try {
      await _groupService.deleteGroup(groupId);
      
      // 從本地清單中移除
      _groups.removeWhere((group) => group.id == groupId);
      
      // 如果是選中的群組，清除選中狀態
      if (_selectedGroup?.id == groupId) {
        _selectedGroup = null;
      }
      
      // 清除該群組的名片快取
      _groupCardsCache.remove(groupId);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 取得群組中的名片
  Future<List<BusinessCard>> getCardsInGroup(int groupId) async {
    // 先檢查快取
    if (_groupCardsCache.containsKey(groupId)) {
      return _groupCardsCache[groupId]!;
    }

    _setLoading(true);
    _clearError();

    try {
      final cards = await _groupService.getCardsInGroup(groupId);
      
      // 快取結果
      _groupCardsCache[groupId] = cards;
      
      _setLoading(false);
      return cards;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  // 將名片加入群組
  Future<bool> addCardToGroup(int cardId, int groupId) async {
    _setLoading(true);
    _clearError();

    try {
      await _groupService.addCardToGroup(cardId, groupId);
      
      // 清除相關快取
      _groupCardsCache.remove(groupId);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 將名片從群組移除
  Future<bool> removeCardFromGroup(int cardId, int groupId) async {
    _setLoading(true);
    _clearError();

    try {
      await _groupService.removeCardFromGroup(cardId, groupId);
      
      // 清除相關快取
      _groupCardsCache.remove(groupId);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 變更名片的群組
  Future<bool> changeCardGroup(int cardId, int newGroupId) async {
    _setLoading(true);
    _clearError();

    try {
      await _groupService.changeCardGroup(cardId, newGroupId);
      
      // 清除所有群組的快取
      _groupCardsCache.clear();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 將名片加入預設群組
  Future<bool> addCardToDefaultGroup(int cardId) async {
    _setLoading(true);
    _clearError();

    try {
      await _groupService.addCardToDefaultGroup(cardId);
      
      // 清除快取
      _groupCardsCache.clear();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 取得名片所屬的群組
  Future<CardGroupInfo?> getCardGroupInfo(int cardId) async {
    try {
      final groupInfo = await _groupService.getCardGroupInfo(cardId);
      return groupInfo;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // 取得預設群組
  Future<CardGroup?> getDefaultGroup() async {
    try {
      final defaultGroup = await _groupService.getDefaultGroup();
      return defaultGroup;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // 設定選中的群組
  void setSelectedGroup(CardGroup? group) {
    _selectedGroup = group;
    notifyListeners();
  }

  // 清除選中的群組
  void clearSelectedGroup() {
    _selectedGroup = null;
    notifyListeners();
  }

  // 根據ID取得群組
  CardGroup? getGroupById(int groupId) {
    try {
      return _groups.firstWhere((group) => group.id == groupId);
    } catch (e) {
      return null;
    }
  }

  // 根據名稱取得群組
  CardGroup? getGroupByName(String name) {
    try {
      return _groups.firstWhere((group) => group.name == name);
    } catch (e) {
      return null;
    }
  }

  // 檢查群組名稱是否已存在
  bool isGroupNameExists(String name) {
    return _groups.any((group) => group.name.toLowerCase() == name.toLowerCase());
  }

  // 取得群組中的名片數量
  int getCardCountInGroup(int groupId) {
    if (_groupCardsCache.containsKey(groupId)) {
      return _groupCardsCache[groupId]!.length;
    }
    
    final group = getGroupById(groupId);
    return group?.cardCount ?? 0;
  }

  // 清除群組名片快取
  void clearGroupCardsCache() {
    _groupCardsCache.clear();
    notifyListeners();
  }

  // 清除特定群組的名片快取
  void clearGroupCardsCache(int groupId) {
    _groupCardsCache.remove(groupId);
    notifyListeners();
  }

  // 重新整理群組
  Future<void> refreshGroups() async {
    await loadGroups();
  }

  // 重新整理名片與群組資訊
  Future<void> refreshCardsWithGroups() async {
    await loadCardsWithGroups();
  }

  // 私有方法：設定載入狀態
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 私有方法：設定錯誤訊息
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // 私有方法：清除錯誤訊息
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 清除錯誤訊息（供UI使用）
  void clearError() {
    _clearError();
  }
}