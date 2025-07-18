// lib/services/card_service.dart
import 'dart:io';
import '../models/card.dart';
import '../models/api_response.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class CardService {
  // 取得我的名片
  Future<List<BusinessCard>> getMyCards() async {
    final response = await ApiClient.get(ApiEndpoints.myCards, needAuth: true);
    
    if (response is List) {
      return response.map((item) => BusinessCard.fromJson(item)).toList();
    }
    return [];
  }

  // 搜尋公開名片
  Future<List<BusinessCard>> searchPublicCards(String query) async {
    final params = {'query': query};
    final response = await ApiClient.getWithParams(
      ApiEndpoints.searchPublicCards, 
      params,
    );
    
    if (response is List) {
      return response.map((item) => BusinessCard.fromJson(item)).toList();
    }
    return [];
  }

  // 取得單一名片
  Future<BusinessCard> getCardById(int cardId) async {
    final response = await ApiClient.get(
      ApiEndpoints.cardById(cardId), 
      needAuth: true,
    );
    return BusinessCard.fromJson(response);
  }

  // 建立名片
  Future<BusinessCard> createCard(CardRequest cardRequest) async {
    final response = await ApiClient.post(
      ApiEndpoints.createCard, 
      cardRequest.toJson(), 
      needAuth: true,
    );
    return BusinessCard.fromJson(response);
  }

  // 更新名片
  Future<BusinessCard> updateCard(int cardId, CardRequest cardRequest) async {
    final response = await ApiClient.put(
      ApiEndpoints.updateCard(cardId), 
      cardRequest.toJson(), 
      needAuth: true,
    );
    return BusinessCard.fromJson(response);
  }

  // 刪除名片
  Future<void> deleteCard(int cardId) async {
    await ApiClient.delete(
      ApiEndpoints.deleteCard(cardId), 
      needAuth: true,
    );
  }

  // 上傳頭像
  Future<String> uploadAvatar(int cardId, File imageFile) async {
    final response = await ApiClient.uploadFile(
      ApiEndpoints.uploadAvatar(cardId), 
      imageFile, 
      needAuth: true,
    );
    
    final uploadResult = UploadResult.fromJson(response);
    return uploadResult.url;
  }

  // 清除頭像
  Future<void> clearAvatar(int cardId) async {
    await ApiClient.delete(
      ApiEndpoints.clearAvatar(cardId), 
      needAuth: true,
    );
  }

  // 更新公開狀態
  Future<void> updatePublicStatus(int cardId, bool isPublic) async {
    final data = {'isPublic': isPublic};
    await ApiClient.put(
      ApiEndpoints.updateCardPublic(cardId), 
      data, 
      needAuth: true,
    );
  }

  // 根據群組取得名片
  Future<List<BusinessCard>> getCardsByGroup(int groupId) async {
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
    final data = {
      'cardId': cardId,
      'groupId': groupId,
    };
    await ApiClient.post(
      ApiEndpoints.addCardToGroup, 
      data, 
      needAuth: true,
    );
  }

  // 將名片從群組移除
  Future<void> removeCardFromGroup(int cardId, int groupId) async {
    final data = {
      'cardId': cardId,
      'groupId': groupId,
    };
    await ApiClient.post(
      ApiEndpoints.removeCardFromGroup, 
      data, 
      needAuth: true,
    );
  }
}