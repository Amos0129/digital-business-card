// lib/providers/card_provider.dart
import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../core/api.dart';
import '../core/constants.dart';

class CardProvider with ChangeNotifier {
  List<BusinessCard> _myCards = [];
  List<BusinessCard> _publicCards = [];
  bool _isLoading = false;
  
  List<BusinessCard> get myCards => _myCards;
  List<BusinessCard> get publicCards => _publicCards;
  bool get isLoading => _isLoading;
  
  // 載入我的名片
  Future<void> loadMyCards() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiClient.get(ApiEndpoints.myCards, needAuth: true);
      _myCards = (response as List)
          .map((json) => BusinessCard.fromJson(json))
          .toList();
    } catch (e) {
      print('載入名片錯誤: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 載入公開名片
  Future<void> loadPublicCards({String? query}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      Map<String, dynamic> params = {};
      if (query != null && query.isNotEmpty) {
        params['query'] = query;
      }
      
      final response = await ApiClient.getWithParams(
        ApiEndpoints.searchPublicCards, 
        params
      );
      
      _publicCards = (response as List)
          .map((json) => BusinessCard.fromJson(json))
          .toList();
    } catch (e) {
      print('載入公開名片錯誤: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 建立名片
  Future<bool> createCard(BusinessCard card) async {
    try {
      final response = await ApiClient.post(
        ApiEndpoints.createCard, 
        card.toJson(), 
        needAuth: true
      );
      
      final newCard = BusinessCard.fromJson(response);
      _myCards.add(newCard);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // 更新名片
  Future<bool> updateCard(BusinessCard card) async {
    try {
      final response = await ApiClient.put(
        ApiEndpoints.updateCard(card.id!), 
        card.toJson(), 
        needAuth: true
      );
      
      final updatedCard = BusinessCard.fromJson(response);
      final index = _myCards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _myCards[index] = updatedCard;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // 刪除名片
  Future<bool> deleteCard(int cardId) async {
    try {
      await ApiClient.delete(ApiEndpoints.deleteCard(cardId), needAuth: true);
      _myCards.removeWhere((card) => card.id == cardId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // 更新公開狀態
  Future<bool> updatePublicStatus(int cardId, bool isPublic) async {
    try {
      await ApiClient.putWithParams(
        ApiEndpoints.updateCardPublic(cardId), 
        {'value': isPublic.toString()}, 
        needAuth: true
      );
      
      final index = _myCards.indexWhere((c) => c.id == cardId);
      if (index != -1) {
        final updatedCard = BusinessCard(
          id: _myCards[index].id,
          name: _myCards[index].name,
          company: _myCards[index].company,
          phone: _myCards[index].phone,
          email: _myCards[index].email,
          address: _myCards[index].address,
          position: _myCards[index].position,
          style: _myCards[index].style,
          avatarUrl: _myCards[index].avatarUrl,
          facebookUrl: _myCards[index].facebookUrl,
          instagramUrl: _myCards[index].instagramUrl,
          lineUrl: _myCards[index].lineUrl,
          threadsUrl: _myCards[index].threadsUrl,
          facebook: _myCards[index].facebook,
          instagram: _myCards[index].instagram,
          line: _myCards[index].line,
          threads: _myCards[index].threads,
          isPublic: isPublic,
        );
        _myCards[index] = updatedCard;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}