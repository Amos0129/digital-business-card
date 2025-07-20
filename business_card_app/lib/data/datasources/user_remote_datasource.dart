// lib/data/datasources/user_remote_datasource.dart
import '../../core/network/dio_client.dart';
import '../../core/network/response_handler.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

/// 使用者遠端資料源
/// 
/// 負責處理與使用者相關的 API 請求
/// 包括個人資料更新、密碼修改等功能
abstract class UserRemoteDataSource {
  /// 獲取當前使用者資訊
  Future<ApiResult<UserModel>> getCurrentUser();
  
  /// 更新顯示名稱
  Future<ApiResult<void>> updateDisplayName(String name);
  
  /// 修改密碼
  Future<ApiResult<void>> changePassword(ChangePasswordRequest request);
  
  /// 檢查使用者是否存在
  Future<ApiResult<bool>> checkUserExists(String email);
  
  /// 根據 Email 查找使用者
  Future<ApiResult<UserModel?>> getUserByEmail(String email);
  
  /// 更新使用者設定
  Future<ApiResult<void>> updateSettings(UserSettings settings);
  
  /// 獲取使用者統計資料
  Future<ApiResult<UserStats>> getUserStats();
  
  /// 獲取使用者活動記錄
  Future<ApiResult<List<UserActivity>>> getUserActivities({int page = 1});
}

/// 使用者遠端資料源實作
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient _dioClient;

  UserRemoteDataSourceImpl({
    required DioClient dioClient,
  }) : _dioClient = dioClient;

  @override
  Future<ApiResult<UserModel>> getCurrentUser() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.userMe);
      
      return ResponseHandler.handleResponse(
        response,
        (json) => UserModel.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<void>> updateDisplayName(String name) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.updateDisplayName,
        queryParameters: {'name': name},
      );
      
      if (response.statusCode == 200) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          NetworkExceptions.defaultError('更新姓名失敗'),
        );
      }
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<void>> changePassword(ChangePasswordRequest request) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.changePassword,
        queryParameters: {
          'oldPassword': request.oldPassword,
          'newPassword': request.newPassword,
        },
      );
      
      if (response.statusCode == 200) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          NetworkExceptions.defaultError('修改密碼失敗'),
        );
      }
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<bool>> checkUserExists(String email) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.userExists,
        queryParameters: {'email': email},
      );
      
      if (response.statusCode == 200 && response.data is bool) {
        return ApiResult.success(response.data as bool);
      } else {
        return ApiResult.success(false);
      }
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<UserModel?>> getUserByEmail(String email) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.userByEmail,
        queryParameters: {'email': email},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return ResponseHandler.handleResponse(
          response,
          (json) => UserModel.fromJson(json),
        );
      } else {
        return ApiResult.success(null);
      }
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<void>> updateSettings(UserSettings settings) async {
    try {
      final response = await _dioClient.put(
        '/api/user/settings',
        data: settings.toJson(),
      );
      
      if (response.statusCode == 200) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          NetworkExceptions.defaultError('更新設定失敗'),
        );
      }
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<UserStats>> getUserStats() async {
    try {
      final response = await _dioClient.get('/api/user/stats');
      
      return ResponseHandler.handleResponse(
        response,
        (json) => UserStats.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<List<UserActivity>>> getUserActivities({int page = 1}) async {
    try {
      final response = await _dioClient.get(
        '/api/user/activities',
        queryParameters: {'page': page, 'pageSize': 20},
      );
      
      return ResponseHandler.handleListResponse(
        response,
        (json) => UserActivity.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }
}