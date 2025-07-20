// lib/data/repositories/card_repository.dart
import 'dart:io';
import '../../core/network/response_handler.dart';
import '../../core/storage/cache_manager.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/card_remote_datasource.dart';
import '../models/card_model.dart';

/// 名片資料倉庫
/// 
/// 負責處理名片相關的資料操作
/// 整合遠端資料源和本地快取
abstract class CardRepository {
  /// 獲取我的名片列表
  Future<ApiResult<List<CardModel>>> getMyCards();
  
  /// 建立名片
  Future<ApiResult<CardModel>> createCard(CardRequest request);
  
  /// 更新名片
  Future<ApiResult<CardModel>> updateCard(int cardId, CardRequest request);
  
  /// 刪除名片
  Future<ApiResult<void>> deleteCard(int cardId);
  
  /// 獲取名片詳情
  Future<ApiResult<CardModel>> getCardById(int cardId);
  
  /// 搜尋公開名片
  Future<ApiResult<List<CardModel>>> searchPublicCards(String? query);
  
  /// 更新名片公開狀態
  Future<ApiResult<void>> updateCardPublicStatus(int cardId, bool isPublic);
  
  /// 上傳名片頭像
  Future<ApiResult<String>> uploadCardAvatar(int cardId, File file);
  
  /// 清除名片頭像
  Future<ApiResult<void>> clearCardAvatar(int cardId);
}

/// 名片資料倉庫實作
class CardRepositoryImpl implements CardRepository {
  final CardRemoteDataSource _remoteDataSource;
  final CacheManager _cacheManager;

  CardRepositoryImpl({
    required CardRemoteDataSource remoteDataSource,
    required CacheManager cacheManager,
  })  : _remoteDataSource = remoteDataSource,
        _cacheManager = cacheManager;

  @override
  Future<ApiResult<List<CardModel>>> getMyCards() async {
    // 先嘗試從快取獲取
    final cachedCards = await _cacheManager.getCachedData<List<CardModel>>(
      AppConstants.myCardsKey,
      (json) => (json as List).map((item) => CardModel.fromJson(item)).toList(),
    );
    
    if (cachedCards != null) {
      // 背景更新
      _refreshMyCards();
      return ApiResult.success(cachedCards);
    }
    
    return await _refreshMyCards();
  }

  @override
  Future<ApiResult<CardModel>> createCard(CardRequest request) async {
    final result = await _remoteDataSource.createMyCard(request);
    
    return result.when(
      success: (card) async {
        // 更新快取
        await _invalidateMyCardsCache();
        return ApiResult.success(card);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<CardModel>> updateCard(int cardId, CardRequest request) async {
    final result = await _remoteDataSource.updateCard(cardId, request);
    
    return result.when(
      success: (card) async {
        // 更新快取
        await _invalidateMyCardsCache();
        await _cacheManager.remove('card_$cardId');
        return ApiResult.success(card);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<void>> deleteCard(int cardId) async {
    final result = await _remoteDataSource.deleteCard(cardId);
    
    return result.when(
      success: (_) async {
        // 清除相關快取
        await _invalidateMyCardsCache();
        await _cacheManager.remove('card_$cardId');
        return ApiResult.success(null);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<CardModel>> getCardById(int cardId) async {
    // 先嘗試從快取獲取
    final cachedCard = await _cacheManager.getCachedData<CardModel>(
      'card_$cardId',
      (json) => CardModel.fromJson(json),
    );
    
    if (cachedCard != null) {
      return ApiResult.success(cachedCard);
    }
    
    final result = await _remoteDataSource.getCardById(cardId);
    
    return result.when(
      success: (card) async {
        // 快取名片資料
        await _cacheManager.cacheData('card_$cardId', card.toJson());
        return ApiResult.success(card);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<List<CardModel>>> searchPublicCards(String? query) async {
    return await _remoteDataSource.searchPublicCards(query);
  }

  @override
  Future<ApiResult<void>> updateCardPublicStatus(int cardId, bool isPublic) async {
    final result = await _remoteDataSource.updateCardPublicStatus(cardId, isPublic);
    
    return result.when(
      success: (_) async {
        // 更新快取
        await _invalidateMyCardsCache();
        await _cacheManager.remove('card_$cardId');
        return ApiResult.success(null);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<String>> uploadCardAvatar(int cardId, File file) async {
    final result = await _remoteDataSource.uploadCardAvatar(cardId, file);
    
    return result.when(
      success: (avatarUrl) async {
        // 清除相關快取
        await _invalidateMyCardsCache();
        await _cacheManager.remove('card_$cardId');
        return ApiResult.success(avatarUrl);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<void>> clearCardAvatar(int cardId) async {
    final result = await _remoteDataSource.clearCardAvatar(cardId);
    
    return result.when(
      success: (_) async {
        // 清除相關快取
        await _invalidateMyCardsCache();
        await _cacheManager.remove('card_$cardId');
        return ApiResult.success(null);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  /// 刷新我的名片快取
  Future<ApiResult<List<CardModel>>> _refreshMyCards() async {
    final result = await _remoteDataSource.getMyCards();
    
    return result.when(
      success: (cards) async {
        // 快取名片列表
        final cardsJson = cards.map((card) => card.toJson()).toList();
        await _cacheManager.cacheData(AppConstants.myCardsKey, cardsJson);
        return ApiResult.success(cards);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  /// 清除我的名片快取
  Future<void> _invalidateMyCardsCache() async {
    await _cacheManager.remove(AppConstants.myCardsKey);
  }
}