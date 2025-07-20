// lib/data/datasources/card_remote_datasource.dart
import 'dart:io';
import '../../core/network/dio_client.dart';
import '../../core/network/response_handler.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/card_model.dart';

/// 名片遠端資料源
/// 
/// 負責處理與名片相關的 API 請求
/// 包括建立、讀取、更新、刪除名片等功能
abstract class CardRemoteDataSource {
  /// 獲取我的名片列表
  Future<ApiResult<List<CardModel>>> getMyCards();
  
  /// 建立我的名片
  Future<ApiResult<CardModel>> createMyCard(CardRequest request);
  
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

/// 名片遠端資料源實作
class CardRemoteDataSourceImpl implements CardRemoteDataSource {
  final DioClient _dioClient;

  CardRemoteDataSourceImpl({
    required DioClient dioClient,
  }) : _dioClient = dioClient;

  @override
  Future<ApiResult<List<CardModel>>> getMyCards() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.myCards);
      
      return ResponseHandler.handleListResponse(
        response,
        (json) => CardModel.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<CardModel>> createMyCard(CardRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.createMyCard,
        data: request.toJson(),
      );
      
      return ResponseHandler.handleResponse(
        response,
        (json) => CardModel.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<CardModel>> updateCard(int cardId, CardRequest request) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.updateCard(cardId),
        data: request.toJson(),
      );
      
      return ResponseHandler.handleResponse(
        response,
        (json) => CardModel.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<void>> deleteCard(int cardId) async {
    try {
      final response = await _dioClient.delete(
        ApiEndpoints.deleteCard(cardId),
      );
      
      if (response.statusCode == 200) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          NetworkExceptions.defaultError('刪除名片失敗'),
        );
      }
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<CardModel>> getCardById(int cardId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getCard(cardId),
      );
      
      return ResponseHandler.handleResponse(
        response,
        (json) => CardModel.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<List<CardModel>>> searchPublicCards(String? query) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }

      final response = await _dioClient.get(
        ApiEndpoints.searchPublicCards,
        queryParameters: queryParams,
      );
      
      return ResponseHandler.handleListResponse(
        response,
        (json) => CardModel.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<void>> updateCardPublicStatus(int cardId, bool isPublic) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.updateCardPublicStatus(cardId),
        queryParameters: {'value': isPublic},
      );
      
      if (response.statusCode == 200) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          NetworkExceptions.defaultError('更新公開狀態失敗'),
        );
      }
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<String>> uploadCardAvatar(int cardId, File file) async {
    try {
      final response = await _dioClient.uploadFile(
        ApiEndpoints.uploadCardAvatar(cardId),
        file,
        fileKey: 'file',
      );
      
      return ResponseHandler.handleFileResponse(response);
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<void>> clearCardAvatar(int cardId) async {
    try {
      final response = await _dioClient.patch(
        ApiEndpoints.clearCardAvatar(cardId),
      );
      
      if (response.statusCode == 200) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          NetworkExceptions.defaultError('清除頭像失敗'),
        );
      }
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }
}