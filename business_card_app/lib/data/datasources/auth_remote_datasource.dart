// lib/data/datasources/auth_remote_datasource.dart
import '../../core/network/dio_client.dart';
import '../../core/network/response_handler.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

/// 認證遠端資料源
/// 
/// 負責處理與認證相關的 API 請求
/// 包括登入、註冊、忘記密碼等功能
abstract class AuthRemoteDataSource {
  /// 使用者註冊
  Future<ApiResult<UserModel>> register(UserRegisterRequest request);
  
  /// 使用者登入
  Future<ApiResult<UserLoginResponse>> login(UserLoginRequest request);
  
  /// 忘記密碼
  Future<ApiResult<void>> forgotPassword(ForgotPasswordRequest request);
  
  /// 重設密碼
  Future<ApiResult<void>> resetPassword(ResetPasswordRequest request);
  
  /// 獲取當前使用者資訊
  Future<ApiResult<UserModel>> getCurrentUser();
  
  /// 檢查使用者是否存在
  Future<ApiResult<bool>> checkUserExists(String email);
  
  /// 根據 Email 查找使用者
  Future<ApiResult<UserModel?>> getUserByEmail(String email);
  
  /// 更新顯示名稱
  Future<ApiResult<void>> updateDisplayName(String name);
  
  /// 修改密碼
  Future<ApiResult<void>> changePassword(ChangePasswordRequest request);
}

/// 認證遠端資料源實作
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl({
    required DioClient dioClient,
  }) : _dioClient = dioClient;

  @override
  Future<ApiResult<UserModel>> register(UserRegisterRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );
      
      return ResponseHandler.handleResponse(
        response,
        (json) => UserModel.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<UserLoginResponse>> login(UserLoginRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      
      return ResponseHandler.handleResponse(
        response,
        (json) => UserLoginResponse.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<void>> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.forgotPassword,
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          NetworkExceptions.defaultError('忘記密碼請求失敗'),
        );
      }
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<void>> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.resetPassword,
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          NetworkExceptions.defaultError('重設密碼失敗'),
        );
      }
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

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
}