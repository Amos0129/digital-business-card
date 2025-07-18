import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../services/card_service.dart';

class CardProvider extends ChangeNotifier {
  final CardService _cardService = CardService();
  
  List<BusinessCard> _myCards = [];
  List<BusinessCard> _publicCards = [];
  BusinessCard? _selectedCard;
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<BusinessCard> get myCards => _myCards;
  List<BusinessCard> get cards => _myCards; // 為了兼容 home_screen.dart 和 cards_screen.dart
  List<BusinessCard> get publicCards => _publicCards;
  BusinessCard? get selectedCard => _selectedCard;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  
  // 是否有我的名片
  bool get hasMyCards => _myCards.isNotEmpty;
  
  // 取得我的名片數量
  int get myCardsCount => _myCards.length;

  // 載入我的名片
  Future<void> loadMyCards() async {
    _setLoading(true);
    _clearError();

    try {
      final cards = await _cardService.getMyCards();
      _myCards = cards;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // 搜尋公開名片
  Future<List<BusinessCard>> searchPublicCards(String query) async {
    _searchQuery = query;
    _setSearching(true);
    _clearError();

    try {
      final cards = await _cardService.searchPublicCards(query);
      _publicCards = cards;
      _setSearching(false);
      return cards;
    } catch (e) {
      _setError(e.toString());
      _setSearching(false);
      return [];
    }
  }

  // 取得單一名片詳情
  Future<BusinessCard?> getCardById(int cardId) async {
    try {
      final card = await _cardService.getCardById(cardId);
      return card;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // 建立名片
  Future<BusinessCard> createCard(Map<String, dynamic> cardData) async {
    _setLoading(true);
    _clearError();

    try {
      final cardRequest = CardRequest(
        name: cardData['name'],
        company: cardData['company'],
        position: cardData['position'],
        phone: cardData['phone'],
        email: cardData['email'],
        address: cardData['address'],
        style: cardData['style'],
        isPublic: cardData['isPublic'] ?? false,
        facebook: cardData['facebook'],
        instagram: cardData['instagram'],
        line: cardData['line'],
        threads: cardData['threads'],
        facebookUrl: cardData['facebookUrl'],
        instagramUrl: cardData['instagramUrl'],
        lineUrl: cardData['lineUrl'],
        threadsUrl: cardData['threadsUrl'],
      );
      
      final newCard = await _cardService.createCard(cardRequest);
      _myCards.add(newCard);
      _setLoading(false);
      return newCard;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // 更新名片
  Future<BusinessCard> updateCard(int cardId, Map<String, dynamic> cardData) async {
    _setLoading(true);
    _clearError();

    try {
      final cardRequest = CardRequest(
        name: cardData['name'],
        company: cardData['company'],
        position: cardData['position'],
        phone: cardData['phone'],
        email: cardData['email'],
        address: cardData['address'],
        style: cardData['style'],
        isPublic: cardData['isPublic'] ?? false,
        facebook: cardData['facebook'],
        instagram: cardData['instagram'],
        line: cardData['line'],
        threads: cardData['threads'],
        facebookUrl: cardData['facebookUrl'],
        instagramUrl: cardData['instagramUrl'],
        lineUrl: cardData['lineUrl'],
        threadsUrl: cardData['threadsUrl'],
      );
      
      final updatedCard = await _cardService.updateCard(cardId, cardRequest);
      
      // 更新本地清單中的名片
      final index = _myCards.indexWhere((card) => card.id == cardId);
      if (index != -1) {
        _myCards[index] = updatedCard;
      }
      
      // 如果是選中的名片，也要更新
      if (_selectedCard?.id == cardId) {
        _selectedCard = updatedCard;
      }
      
      _setLoading(false);
      return updatedCard;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // 刪除名片
  Future<void> deleteCard(int cardId) async {
    _setLoading(true);
    _clearError();

    try {
      await _cardService.deleteCard(cardId);
      
      // 從本地清單中移除
      _myCards.removeWhere((card) => card.id == cardId);
      
      // 如果是選中的名片，清除選中狀態
      if (_selectedCard?.id == cardId) {
        _selectedCard = null;
      }
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // 上傳頭像
  Future<bool> uploadAvatar(int cardId, File imageFile) async {
    _setLoading(true);
    _clearError();

    try {
      final avatarUrl = await _cardService.uploadAvatar(cardId, imageFile);
      
      // 更新本地清單中的名片
      final index = _myCards.indexWhere((card) => card.id == cardId);
      if (index != -1) {
        _myCards[index] = _myCards[index].copyWith(avatarUrl: avatarUrl);
      }
      
      // 如果是選中的名片，也要更新
      if (_selectedCard?.id == cardId) {
        _selectedCard = _selectedCard!.copyWith(avatarUrl: avatarUrl);
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 清除頭像
  Future<bool> clearAvatar(int cardId) async {
    _setLoading(true);
    _clearError();

    try {
      await _cardService.clearAvatar(cardId);
      
      // 更新本地清單中的名片
      final index = _myCards.indexWhere((card) => card.id == cardId);
      if (index != -1) {
        _myCards[index] = _myCards[index].copyWith(avatarUrl: null);
      }
      
      // 如果是選中的名片，也要更新
      if (_selectedCard?.id == cardId) {
        _selectedCard = _selectedCard!.copyWith(avatarUrl: null);
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 更新名片公開狀態
  Future<bool> updatePublicStatus(int cardId, bool isPublic) async {
    _setLoading(true);
    _clearError();

    try {
      await _cardService.updatePublicStatus(cardId, isPublic);
      
      // 更新本地清單中的名片
      final index = _myCards.indexWhere((card) => card.id == cardId);
      if (index != -1) {
        _myCards[index] = _myCards[index].copyWith(isPublic: isPublic);
      }
      
      // 如果是選中的名片，也要更新
      if (_selectedCard?.id == cardId) {
        _selectedCard = _selectedCard!.copyWith(isPublic: isPublic);
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 根據群組取得名片
  Future<List<BusinessCard>> getCardsByGroup(int groupId) async {
    try {
      return await _cardService.getCardsByGroup(groupId);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // 將名片加入群組
  Future<void> addCardToGroup(int cardId, int groupId) async {
    try {
      await _cardService.addCardToGroup(cardId, groupId);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // 將名片從群組移除
  Future<void> removeCardFromGroup(int cardId, int groupId) async {
    try {
      await _cardService.removeCardFromGroup(cardId, groupId);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // 設定選中的名片
  void setSelectedCard(BusinessCard? card) {
    _selectedCard = card;
    notifyListeners();
  }

  // 清除選中的名片
  void clearSelectedCard() {
    _selectedCard = null;
    notifyListeners();
  }

  // 根據ID取得我的名片
  BusinessCard? getMyCardById(int cardId) {
    try {
      return _myCards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  // 根據樣式篩選名片
  List<BusinessCard> getCardsByStyle(String style) {
    return _myCards.where((card) => card.style == style).toList();
  }

  // 根據公開狀態篩選名片
  List<BusinessCard> getCardsByPublicStatus(bool isPublic) {
    return _myCards.where((card) => card.isPublic == isPublic).toList();
  }

  // 取得有社交媒體連結的名片
  List<BusinessCard> getCardsWithSocialMedia() {
    return _myCards.where((card) => card.hasSocialMedia).toList();
  }

  // 清除搜尋結果
  void clearSearchResults() {
    _publicCards.clear();
    _searchQuery = '';
    notifyListeners();
  }

  // 重新整理我的名片
  Future<void> refreshMyCards() async {
    await loadMyCards();
  }

  // 私有方法：設定載入狀態
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 私有方法：設定搜尋狀態
  void _setSearching(bool searching) {
    _isSearching = searching;
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