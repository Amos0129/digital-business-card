// lib/services/card_service.dart
import '../core/api.dart';
import '../models/card.dart';

class CardService {
  // 獲取我的名片
  static Future<List<BusinessCard>> getMyCards() async {
    try {
      final response = await API.get('/cards/my');
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
      final endpoint = query != null && query.isNotEmpty
          ? '/cards/public/search?query=$query'
          : '/cards/public/search';
      
      final response = await API.get(endpoint);
      return (response as List)
          .map((json) => BusinessCard.fromJson(json))
          .toList();
    } catch (e) {
      throw '獲取公開名片失敗: $e';
    }
  }

  // 創建名片
  static Future<BusinessCard> createCard(BusinessCard card) async {
    try {
      final response = await API.post('/cards/my', card.toJson());
      return BusinessCard.fromJson(response);
    } catch (e) {
      throw '創建名片失敗: $e';
    }
  }

  // 更新名片
  static Future<BusinessCard> updateCard(int cardId, BusinessCard card) async {
    try {
      final response = await API.put('/cards/$cardId', card.toJson());
      return BusinessCard.fromJson(response);
    } catch (e) {
      throw '更新名片失敗: $e';
    }
  }

  // 刪除名片
  static Future<void> deleteCard(int cardId) async {
    try {
      await API.delete('/cards/$cardId');
    } catch (e) {
      throw '刪除名片失敗: $e';
    }
  }

  // 獲取單張名片詳情
  static Future<BusinessCard> getCardDetail(int cardId) async {
    try {
      final response = await API.get('/cards/$cardId');
      return BusinessCard.fromJson(response);
    } catch (e) {
      throw '獲取名片詳情失敗: $e';
    }
  }

  // 更新公開狀態
  static Future<void> updatePublicStatus(int cardId, bool isPublic) async {
    try {
      await API.put('/cards/$cardId/public?value=$isPublic', {});
    } catch (e) {
      throw '更新公開狀態失敗: $e';
    }
  }
}