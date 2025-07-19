// lib/services/card_service.dart
import '../core/api_client.dart';
import '../models/card.dart';
import '../core/constants.dart';

class CardService {
  // 獲取我的名片
  static Future<List<BusinessCard>> getMyCards() async {
    try {
      final response = await ApiClient.get(ApiEndpoints.myCards, needAuth: true);
      return (response as List)
          .map((json) => BusinessCard.fromJson(json))
          .toList();
    } catch (e) {
      throw '獲取名片失敗: $e';
    }
  }

  // 獲取公開名片
  static Future<List<BusinessCard>> getPublicCards({String? query}) async {
    try {
      String endpoint = ApiEndpoints.searchPublicCards;
      
      if (query != null && query.isNotEmpty) {
        final response = await ApiClient.getWithParams(
          endpoint, 
          {'query': query}, 
          needAuth: false
        );
        return (response as List)
            .map((json) => BusinessCard.fromJson(json))
            .toList();
      } else {
        final response = await ApiClient.get(endpoint, needAuth: false);
        return (response as List)
            .map((json) => BusinessCard.fromJson(json))
            .toList();
      }
    } catch (e) {
      throw '獲取公開名片失敗: $e';
    }
  }

  // 創建名片
  static Future<BusinessCard> createCard(BusinessCard card) async {
    try {
      final response = await ApiClient.post(
        ApiEndpoints.createCard, 
        card.toJson(), 
        needAuth: true
      );
      return BusinessCard.fromJson(response);
    } catch (e) {
      throw '創建名片失敗: $e';
    }
  }

  // 更新名片
  static Future<BusinessCard> updateCard(int cardId, BusinessCard card) async {
    try {
      final response = await ApiClient.put(
        ApiEndpoints.updateCard(cardId), 
        card.toJson(), 
        needAuth: true
      );
      return BusinessCard.fromJson(response);
    } catch (e) {
      throw '更新名片失敗: $e';
    }
  }

  // 刪除名片
  static Future<void> deleteCard(int cardId) async {
    try {
      await ApiClient.delete(ApiEndpoints.deleteCard(cardId), needAuth: true);
    } catch (e) {
      throw '刪除名片失敗: $e';
    }
  }

  // 獲取單張名片詳情
  static Future<BusinessCard> getCardDetail(int cardId) async {
    try {
      final response = await ApiClient.get(
        ApiEndpoints.cardById(cardId), 
        needAuth: true
      );
      return BusinessCard.fromJson(response);
    } catch (e) {
      throw '獲取名片詳情失敗: $e';
    }
  }

  // 更新公開狀態
  static Future<void> updatePublicStatus(int cardId, bool isPublic) async {
    try {
      await ApiClient.putWithParams(
        ApiEndpoints.updateCardPublic(cardId), 
        {'value': isPublic.toString()}, 
        needAuth: true
      );
    } catch (e) {
      throw '更新公開狀態失敗: $e';
    }
  }

  // 上傳頭像
  static Future<String> uploadAvatar(int cardId, String imagePath) async {
    try {
      // 這裡需要實作檔案上傳邏輯
      // 暫時返回預設值
      throw '上傳頭像功能開發中';
    } catch (e) {
      throw '上傳頭像失敗: $e';
    }
  }

  // 清除頭像
  static Future<void> clearAvatar(int cardId) async {
    try {
      await ApiClient.delete(ApiEndpoints.clearAvatar(cardId), needAuth: true);
    } catch (e) {
      throw '清除頭像失敗: $e';
    }
  }
}