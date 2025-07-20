// lib/presentation/providers/card_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/models/card_model.dart';
import '../../core/network/response_handler.dart';

/// 名片狀態提供者
/// 
/// 管理名片相關的狀態和操作
class CardProvider extends ChangeNotifier {
  final CardRepository _cardRepository;

  CardProvider({required CardRepository cardRepository})
      : _cardRepository = cardRepository;

  // 狀態變數
  List<CardModel> _myCards = [];
  List<CardModel> _publicCards = [];
  List<CardModel> _searchResults = [];
  CardModel? _selectedCard;
  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  String? _errorMessage;

  // Getters
  List<CardModel> get myCards => List.unmodifiable(_myCards);
  List<CardModel> get publicCards => List.unmodifiable(_publicCards);
  List<CardModel> get searchResults => List.unmodifiable(_searchResults);
  CardModel? get selectedCard => _selectedCard;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// 載入我的名片列表
  Future<void> loadMyCards() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _cardRepository.getMyCards();
      
      result.when(
        success: (cards) {
          _myCards = cards;
          _setLoading(false);
          notifyListeners();
        },
        failure: (error) {
          _setError(error.message);
        },
      );
    } catch (e) {
      _setError('載入名片失敗: ${e.toString()}');
    }
  }

  /// 建立名片
  Future<bool> createCard(CardRequest request) async {
    _isCreating = true;
    _clearError();
    notifyListeners();

    try {
      final result = await _cardRepository.createCard(request);

      return result.when(
        success: (card) {
          _myCards.add(card);
          _isCreating = false;
          notifyListeners();
          return true;
        },
        failure: (error) {
          _setError(error.message);
          _isCreating = false;
          notifyListeners();
          return false;
        },
      );
    } catch (e) {
      _setError('建立名片失敗: ${e.toString()}');
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  /// 更新名片
  Future<bool> updateCard(int cardId, CardRequest request) async {
    _isUpdating = true;
    _clearError();
    notifyListeners();

    try {
      final result = await _cardRepository.updateCard(cardId, request);

      return result.when(
        success: (updatedCard) {
          final index = _myCards.indexWhere((card) => card.id == cardId);
          if (index != -1) {
            _myCards[index] = updatedCard;
          }
          
          if (_selectedCard?.id == cardId) {
            _selectedCard = updatedCard;
          }
          
          _isUpdating = false;
          notifyListeners();
          return true;
        },
        failure: (error) {
          _setError(error.message);
          _isUpdating = false;
          notifyListeners();
          return false;
        },
      );
    } catch (e) {
      _setError('更新名片失敗: ${e.toString()}');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  /// 刪除名片
  Future<bool> deleteCard(int cardId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _cardRepository.deleteCard(cardId);

      return result.when(
        success: (_) {
          _myCards.removeWhere((card) => card.id == cardId);
          if (_selectedCard?.id == cardId) {
            _selectedCard = null;
          }
          _setLoading(false);
          notifyListeners();
          return true;
        },
        failure: (error) {
          _setError(error.message);
          return false;
        },
      );
    } catch (e) {
      _setError('刪除名片失敗: ${e.toString()}');
      return false;
    }
  }

  /// 載入名片詳情
  Future<void> loadCardDetail(int cardId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _cardRepository.getCardById(cardId);
      
      result.when(
        success: (card) {
          _selectedCard = card;
          _setLoading(false);
          notifyListeners();
        },
        failure: (error) {
          _setError(error.message);
        },
      );
    } catch (e) {
      _setError('載入名片詳情失敗: ${e.toString()}');
    }
  }

  /// 搜尋公開名片
  Future<void> searchPublicCards(String? query) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _cardRepository.searchPublicCards(query);
      
      result.when(
        success: (cards) {
          _publicCards = cards;
          _searchResults = cards;
          _setLoading(false);
          notifyListeners();
        },
        failure: (error) {
          _setError(error.message);
        },
      );
    } catch (e) {
      _setError('搜尋名片失敗: ${e.toString()}');
    }
  }

  /// 更新名片公開狀態
  Future<bool> updateCardPublicStatus(int cardId, bool isPublic) async {
    _clearError();

    try {
      final result = await _cardRepository.updateCardPublicStatus(cardId, isPublic);

      return result.when(
        success: (_) {
          final index = _myCards.indexWhere((card) => card.id == cardId);
          if (index != -1) {
            _myCards[index] = _myCards[index].copyWith(isPublic: isPublic);
          }
          
          if (_selectedCard?.id == cardId) {
            _selectedCard = _selectedCard!.copyWith(isPublic: isPublic);
          }
          
          notifyListeners();
          return true;
        },
        failure: (error) {
          _setError(error.message);
          return false;
        },
      );
    } catch (e) {
      _setError('更新公開狀態失敗: ${e.toString()}');
      return false;
    }
  }

  /// 上傳名片頭像
  Future<bool> uploadAvatar(int cardId, File file) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _cardRepository.uploadCardAvatar(cardId, file);

      return result.when(
        success: (avatarUrl) {
          final index = _myCards.indexWhere((card) => card.id == cardId);
          if (index != -1) {
            _myCards[index] = _myCards[index].copyWith(avatarUrl: avatarUrl);
          }
          
          if (_selectedCard?.id == cardId) {
            _selectedCard = _selectedCard!.copyWith(avatarUrl: avatarUrl);
          }
          
          _setLoading(false);
          notifyListeners();
          return true;
        },
        failure: (error) {
          _setError(error.message);
          return false;
        },
      );
    } catch (e) {
      _setError('上傳頭像失敗: ${e.toString()}');
      return false;
    }
  }

  /// 清除名片頭像
  Future<bool> clearAvatar(int cardId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _cardRepository.clearCardAvatar(cardId);

      return result.when(
        success: (_) {
          final index = _myCards.indexWhere((card) => card.id == cardId);
          if (index != -1) {
            _myCards[index] = _myCards[index].copyWith(avatarUrl: null);
          }
          
          if (_selectedCard?.id == cardId) {
            _selectedCard = _selectedCard!.copyWith(avatarUrl: null);
          }
          
          _setLoading(false);
          notifyListeners();
          return true;
        },
        failure: (error) {
          _setError(error.message);
          return false;
        },
      );
    } catch (e) {
      _setError('清除頭像失敗: ${e.toString()}');
      return false;
    }
  }

  /// 設定選中的名片
  void setSelectedCard(CardModel? card) {
    _selectedCard = card;
    notifyListeners();
  }

  /// 清除搜尋結果
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  /// 清除錯誤訊息
  void clearError() {
    _clearError();
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    _isCreating = false;
    _isUpdating = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}