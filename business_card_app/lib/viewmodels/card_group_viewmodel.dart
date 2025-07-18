import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/unified_card.dart';
import '../services/group_service.dart';
import '../services/card_group_service.dart';
import '../services/card_service.dart';
import '../enums/view_mode.dart';
import '../models/card_response.dart';
import 'package:hive/hive.dart';

class CardGroupViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  final GroupService _groupService = GroupService();
  final CardGroupService _cardGroupService = CardGroupService();
  final CardService _cardService = CardService();

  List<GroupModel> _groups = [];
  List<UnifiedCard> _cards = [];
  Set<String> _selectedCardIds = {};
  bool _isSelectionMode = false;
  String _selectedGroup = '全部';
  ViewMode _viewMode = ViewMode.card;

  bool includePublicCards = false;

  void setIncludePublic(bool value) {
    includePublicCards = value;
    loadCards(); // 當切換搜尋範圍時自動重新載入
    notifyListeners();
  }

  List<GroupModel> get groups => _groups;
  List<UnifiedCard> get cards => _cards;
  Set<String> get selectedCardIds => _selectedCardIds;
  bool get isSelectionMode => _isSelectionMode;
  String get selectedGroup => _selectedGroup;
  ViewMode get viewMode => _viewMode;

  List<UnifiedCard> get filteredCards {
    final keyword = searchController.text.toLowerCase();
    final seenIds = <String>{};

    return _cards.where((card) {
      final matchKeyword =
          card.name.toLowerCase().contains(keyword) ||
          (card.company ?? '').toLowerCase().contains(keyword);
      final matchGroup = _selectedGroup == '全部' || card.group == _selectedGroup;
      final isUnique = seenIds.add(card.id);

      return matchKeyword && matchGroup && isUnique;
    }).toList();
  }

  Future<void> loadGroups() async {
    final groupList = await _groupService.getGroupsByUser();

    _groups = [GroupModel(id: -1, name: '全部'), ...groupList];

    if (!_groups.any((g) => g.name == _selectedGroup)) {
      _selectedGroup = '全部';
    }

    notifyListeners();
  }

  Future<void> loadCards() async {
    _cards = []; // 清空
    final seenCardIds = <int>{};

    try {
      if (_selectedGroup == '全部') {
        List<Map<String, dynamic>> rawCards = [];
        final box = await Hive.openBox('cardGroupBox');

        try {
          rawCards = await _cardGroupService.getCardsByUser();
        } catch (e) {
          debugPrint('⚠️ 無法從 API 取得卡片，改用本地快取：$e');
          final cached = box.get('userCardGroups');
          if (cached != null && cached is List) {
            try {
              rawCards = List<Map<String, dynamic>>.from(cached);
              debugPrint('✅ 成功使用快取資料');
            } catch (e) {
              debugPrint('❌ 快取格式錯誤：$e');
            }
          }
        }

        for (var json in rawCards) {
          final cardId = json['id'] as int;
          if (!seenCardIds.add(cardId)) continue;

          // ✅ 只有在快取資料沒有 group 時才重新抓
          if (!json.containsKey('groupId') || !json.containsKey('groupName')) {
            try {
              final group = await _cardGroupService.getGroupOfCardForUser(
                cardId,
              );
              json['groupId'] = group?.groupId;
              json['groupName'] = group?.groupName ?? '未分類';
            } catch (_) {
              json['groupId'] = null;
              json['groupName'] = '未分類';
            }
          }

          final cardResponse = CardResponse.fromJson(json);
          final unifiedCard = cardResponse.toUnifiedCard();

          _cards.add(unifiedCard);
        }

        // ✅ 公開名片還是用原本 API 搜尋方式（可以選擇不處理離線）
        if (includePublicCards) {
          try {
            final publicCards = await _cardService.searchPublicCards(
              query: searchController.text.trim(),
            );

            for (var json in publicCards) {
              final cardId = json['id'] as int;
              if (!seenCardIds.add(cardId)) continue;

              json['groupId'] = null;
              json['groupName'] = '公開名片';

              final cardResponse = CardResponse.fromJson(json);
              final unifiedCard = cardResponse.toUnifiedCard().copyWith(
                isScanned: true,
                group: '公開名片',
              );

              _cards.add(unifiedCard);
            }
          } catch (e) {
            debugPrint('⚠️ 公開名片讀取失敗（可忽略）：$e');
          }
        }
        await box.put('userCardGroups', rawCards);
      }
    } catch (e) {
      debugPrint('❌ 載入卡片失敗（可能是斷網）：$e');
      // 這裡建議你保留之前讀過的快取資料，不清空 _cards，或者提示「目前為離線狀態」。
    }

    notifyListeners();
  }

  Future<void> deleteGroup(GroupModel group) async {
    await _groupService.deleteGroup(group.id);
    await loadGroups();
    notifyListeners();
  }

  void selectGroup(String groupName) {
    _selectedGroup = groupName;
    notifyListeners();
  }

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) _selectedCardIds.clear();
    notifyListeners();
  }

  void toggleCardSelection(String cardId) {
    if (_selectedCardIds.contains(cardId)) {
      _selectedCardIds.remove(cardId);
    } else {
      _selectedCardIds.add(cardId);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedCardIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  Future<void> deleteSelectedCards() async {
    final toDelete = _cards
        .where((c) => _selectedCardIds.contains(c.id))
        .toList();

    for (final card in toDelete) {
      if (card.cardId != null && card.groupId != null) {
        await _cardGroupService.removeCardFromGroup(
          card.cardId!,
          card.groupId!,
        );
      }
    }

    await loadCards();
    _selectedCardIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  Future<void> assignGroupToSelectedByGroup(GroupModel group) async {
    if (group.name == '全部') {
      throw Exception('「全部」是系統虛擬群組，無法分配卡片');
    }

    for (final id in _selectedCardIds) {
      final index = _cards.indexWhere((c) => c.id == id);
      if (index == -1 || _cards[index].cardId == null) continue;

      final cardIdInt = _cards[index].cardId!;

      try {
        // 🟡 對於公開名片（不是自己的卡），你必須先加進群組
        await _cardGroupService.addCardToGroup(cardIdInt, group.id);
      } catch (e) {
        print('🟡 卡片可能已經存在於該群組: $e');
      }

      try {
        // ✅ 對於自己的卡，允許變更歸屬群組
        await _cardGroupService.changeCardGroup(cardIdInt, group.id);
      } catch (e) {
        print('❌ 變更群組失敗: $e');
      }

      // 更新前端資料
      _cards[index] = _cards[index].copyWith(
        group: group.name,
        groupId: group.id,
      );
    }

    await loadCards();
    clearSelection();
    notifyListeners();
  }

  Future<void> assignGroupToCard(String cardId, String groupName) async {
    final group = _groups.firstWhere((g) => g.name == groupName);
    final index = _cards.indexWhere((c) => c.id == cardId);

    if (index != -1 && _cards[index].cardId != null) {
      final cardIdInt = _cards[index].cardId!;

      try {
        // 先建立對應，確保你有權限 change
        await _cardGroupService.addCardToGroup(cardIdInt, group.id);
      } catch (e) {
        print('卡片可能已經加入過群組: $e');
      }

      // 再執行變更群組
      await _cardGroupService.changeCardGroup(cardIdInt, group.id);

      // 更新本地卡片狀態
      _cards[index] = _cards[index].copyWith(
        group: group.name,
        groupId: group.id,
      );

      notifyListeners();
    }
  }

  Future<void> deleteCard(String cardId) async {
    final card = _cards.firstWhere((c) => c.id == cardId);
    if (card.cardId != null && card.groupId != null) {
      await _cardGroupService.removeCardFromGroup(card.cardId!, card.groupId!);
    }
    _cards.removeWhere((c) => c.id == cardId);
    notifyListeners();
  }

  void restoreCard(UnifiedCard card) {
    _cards.add(card);
    notifyListeners();
  }

  void addCard(UnifiedCard card) {
    _cards.add(card);
    notifyListeners();
  }

  void reorderCards(int oldIndex, int newIndex) {
    final filtered = filteredCards;
    if (newIndex > oldIndex) newIndex--;
    final movedCard = filtered[oldIndex];

    _cards.removeWhere((c) => c.id == movedCard.id);

    final insertIndex = (newIndex < filtered.length)
        ? _cards.indexWhere((c) => c.id == filtered[newIndex].id)
        : _cards.length;

    _cards.insert(insertIndex, movedCard);
    notifyListeners();
  }

  void toggleViewMode() {
    _viewMode = _viewMode == ViewMode.card ? ViewMode.list : ViewMode.card;
    notifyListeners();
  }

  Map<GroupModel, List<UnifiedCard>> get groupedCards {
    final groupMap = {for (var g in _groups.where((g) => g.id != -1)) g.id: g};

    final result = <GroupModel, List<UnifiedCard>>{};

    for (final card in _cards) {
      final group =
          groupMap[card.groupId] ?? GroupModel(id: -999, name: '未知群組');
      result.putIfAbsent(group, () => []).add(card);
    }

    return result;
  }
}
