// lib/data/repositories/auth_repository.dart
import '../../core/network/response_handler.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/cache_manager.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// 認證資料倉庫
/// 
/// 負責處理認證相關的資料操作
/// 整合遠端資料源和本地儲存
abstract class AuthRepository {
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
  
  /// 登出
  Future<void> logout();
  
  /// 檢查是否已登入
  Future<bool> isLoggedIn();
  
  /// 獲取儲存的 Token
  Future<String?> getToken();
  
  /// 儲存 Token
  Future<void> saveToken(String token);
  
  /// 清除 Token
  Future<void> clearToken();
  
  /// 檢查使用者是否存在
  Future<ApiResult<bool>> checkUserExists(String email);
  
  /// 更新顯示名稱
  Future<ApiResult<void>> updateDisplayName(String name);
  
  /// 修改密碼
  Future<ApiResult<void>> changePassword(ChangePasswordRequest request);
}

/// 認證資料倉庫實作
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;
  final CacheManager _cacheManager;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorage secureStorage,
    required CacheManager cacheManager,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage,
        _cacheManager = cacheManager;

  @override
  Future<ApiResult<UserModel>> register(UserRegisterRequest request) async {
    final result = await _remoteDataSource.register(request);
    
    return result.when(
      success: (user) async {
        // 註冊成功後可以快取使用者資料
        await _cacheUserData(user);
        return ApiResult.success(user);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<UserLoginResponse>> login(UserLoginRequest request) async {
    final result = await _remoteDataSource.login(request);
    
    return result.when(
      success: (loginResponse) async {
        // 儲存 Token
        await saveToken(loginResponse.token);
        
        // 快取使用者資料
        final userData = {
          'id': loginResponse.id,
          'email': loginResponse.email,
          'name': loginResponse.name,
        };
        await _cacheManager.cacheUserData(userData);
        
        return ApiResult.success(loginResponse);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<void>> forgotPassword(ForgotPasswordRequest request) async {
    return await _remoteDataSource.forgotPassword(request);
  }

  @override
  Future<ApiResult<void>> resetPassword(ResetPasswordRequest request) async {
    return await _remoteDataSource.resetPassword(request);
  }

  @override
  Future<ApiResult<UserModel>> getCurrentUser() async {
    // 先嘗試從快取獲取
    final cachedData = await _cacheManager.getCachedUserData();
    if (cachedData != null) {
      try {
        final user = UserModel.fromJson(cachedData);
        return ApiResult.success(user);
      } catch (e) {
        // 快取資料格式錯誤，清除快取
        await _cacheManager.remove(AppConstants.userDataKey);
      }
    }
    
    // 從遠端獲取
    final result = await _remoteDataSource.getCurrentUser();
    
    return result.when(
      success: (user) async {
        await _cacheUserData(user);
        return ApiResult.success(user);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<void> logout() async {
    // 清除 Token
    await clearToken();
    
    // 清除快取的使用者資料
    await _cacheManager.remove(AppConstants.userDataKey);
    
    // 清除其他相關快取
    await _cacheManager.remove(AppConstants.recentCardsKey);
    await _cacheManager.remove(AppConstants.searchHistoryKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(AppConstants.tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.store(AppConstants.tokenKey, token);
  }

  @override
  Future<void> clearToken() async {
    await _secureStorage.delete(AppConstants.tokenKey);
  }

  @override
  Future<ApiResult<bool>> checkUserExists(String email) async {
    return await _remoteDataSource.checkUserExists(email);
  }

  @override
  Future<ApiResult<void>> updateDisplayName(String name) async {
    final result = await _remoteDataSource.updateDisplayName(name);
    
    return result.when(
      success: (_) async {
        // 更新快取中的使用者資料
        await _updateCachedUserName(name);
        return ApiResult.success(null);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<void>> changePassword(ChangePasswordRequest request) async {
    return await _remoteDataSource.changePassword(request);
  }

  /// 快取使用者資料
  Future<void> _cacheUserData(UserModel user) async {
    final userData = {
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'createdAt': user.createdAt?.toIso8601String(),
      'updatedAt': user.updatedAt?.toIso8601String(),
    };
    await _cacheManager.cacheUserData(userData);
  }

  /// 更新快取中的使用者名稱
  Future<void> _updateCachedUserName(String name) async {
    final cachedData = await _cacheManager.getCachedUserData();
    if (cachedData != null) {
      cachedData['name'] = name;
      cachedData['updatedAt'] = DateTime.now().toIso8601String();
      await _cacheManager.cacheUserData(cachedData);
    }
  }
}