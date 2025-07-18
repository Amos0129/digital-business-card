// lib/services/group_service.dart
import '../models/group.dart';
import '../models/card.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class GroupService {
  // 取得使用者的群組
  Future<List<CardGroup>> getGroupsByUser() async {
    final response = await ApiClient.get(ApiEndpoints.groupsByUser, needAuth: true);
    
    if (response is List) {
      return response.map((item) => CardGroup.fromJson(item)).toList();
    }
    return [];
  }

  // 取得帶群組資訊的名片
  Future<List<CardWithGroup>> getCardsWithGroups() async {
    final response = await ApiClient.get(ApiEndpoints.cardGroupsByUser, needAuth: true);
    
    if (response is List) {
      return response.map((item) => CardWithGroup.fromJson(item)).toList();
    }
    return [];
  }

  // 建立群組
  Future<CardGroup> createGroup(String groupName) async {
    final data = GroupRequest(name: groupName).toJson();
    final response = await ApiClient.post(
      ApiEndpoints.createGroup, 
      data, 
      needAuth: true,
    );
    return CardGroup.fromJson(response);
  }

  // 重新命名群組
  Future<CardGroup> renameGroup(int groupId, String newName) async {
    final data = {'name': newName};
    final response = await ApiClient.put(
      ApiEndpoints.renameGroup(groupId), 
      data, 
      needAuth: true,
    );
    return CardGroup.fromJson(response);
  }

  // 刪除群組
  Future<void> deleteGroup(int groupId) async {
    await ApiClient.delete(
      ApiEndpoints.deleteGroup(groupId), 
      needAuth: true,
    );
  }

  // 取得群組中的名片
  Future<List<BusinessCard>> getCardsInGroup(int groupId) async {
    final response = await ApiClient.get(
      ApiEndpoints.cardsByGroup(groupId), 
      needAuth: true,
    );
    
    if (response is List) {
      return response.map((item) => BusinessCard.fromJson(item)).toList();
    }
    return [];
  }

  // 將名片加入群組
  Future<void> addCardToGroup(int cardId, int groupId) async {
    final data = GroupOperationRequest(
      cardId: cardId,
      groupId: groupId,
    ).toJson();
    
    await ApiClient.post(
      ApiEndpoints.addCardToGroup, 
      data, 
      needAuth: true,
    );
  }

  // 將名片從群組移除
  Future<void> removeCardFromGroup(int cardId, int groupId) async {
    final data = GroupOperationRequest(
      cardId: cardId,
      groupId: groupId,
    ).toJson();
    
    await ApiClient.post(
      ApiEndpoints.removeCardFromGroup, 
      data, 
      needAuth: true,
    );
  }

  // 變更名片的群組
  Future<void> changeCardGroup(int cardId, int newGroupId) async {
    final data = {
      'cardId': cardId,
      'groupId': newGroupId,
    };
    
    await ApiClient.post(
      ApiEndpoints.changeCardGroup, 
      data, 
      needAuth: true,
    );
  }

  // 將名片加入預設群組
  Future<void> addCardToDefaultGroup(int cardId) async {
    final data = {'cardId': cardId};
    await ApiClient.post(
      ApiEndpoints.addToDefaultGroup, 
      data, 
      needAuth: true,
    );
  }

  // 取得名片所屬的群組資訊
  Future<CardGroupInfo?> getCardGroupInfo(int cardId) async {
    try {
      final params = {'cardId': cardId};
      final response = await ApiClient.getWithParams(
        ApiEndpoints.userGroupOfCard, 
        params, 
        needAuth: true,
      );
      return CardGroupInfo.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 取得預設群組
  Future<CardGroup> getDefaultGroup() async {
    final response = await ApiClient.get(
      ApiEndpoints.defaultGroup, 
      needAuth: true,
    );
    return CardGroup.fromJson(response);
  }

  // 根據ID取得群組
  Future<CardGroup> getGroupById(int groupId) async {
    final groups = await getGroupsByUser();
    return groups.firstWhere((group) => group.id == groupId);
  }
}