// lib/data/repositories/user_repository.dart
import '../../core/network/response_handler.dart';
import '../../core/storage/cache_manager.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

/// 使用者資料倉庫
/// 
/// 負責處理使用者相關的資料操作
/// 整合遠端資料源和本地快取
abstract class UserRepository {
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

/// 使用者資料倉庫實作
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final CacheManager _cacheManager;

  UserRepositoryImpl({
    required UserRemoteDataSource remoteDataSource,
    required CacheManager cacheManager,
  })  : _remoteDataSource = remoteDataSource,
        _cacheManager = cacheManager;

  @override
  Future<ApiResult<UserModel>> getCurrentUser() async {
    // 先嘗試從快取獲取
    final cachedUser = await _cacheManager.getCachedData<UserModel>(
      AppConstants.userDataKey,
      (json) => UserModel.fromJson(json),
    );
    
    if (cachedUser != null) {
      return ApiResult.success(cachedUser);
    }
    
    final result = await _remoteDataSource.getCurrentUser();
    
    return result.when(
      success: (user) async {
        // 快取使用者資料
        await _cacheManager.cacheData(AppConstants.userDataKey, user.toJson());
        return ApiResult.success(user);
      },
      failure: (error) => ApiResult.failure(error),
    );
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

  @override
  Future<ApiResult<bool>> checkUserExists(String email) async {
    return await _remoteDataSource.checkUserExists(email);
  }

  @override
  Future<ApiResult<UserModel?>> getUserByEmail(String email) async {
    return await _remoteDataSource.getUserByEmail(email);
  }

  @override
  Future<ApiResult<void>> updateSettings(UserSettings settings) async {
    final result = await _remoteDataSource.updateSettings(settings);
    
    return result.when(
      success: (_) async {
        // 快取設定資料
        await _cacheManager.cacheData(AppConstants.userSettingsKey, settings.toJson());
        return ApiResult.success(null);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<UserStats>> getUserStats() async {
    // 先嘗試從快取獲取（統計資料快取時間較短）
    final cachedStats = await _cacheManager.getCachedData<UserStats>(
      AppConstants.userStatsKey,
      (json) => UserStats.fromJson(json),
      expiration: const Duration(minutes: 5), // 5分鐘過期
    );
    
    if (cachedStats != null) {
      return ApiResult.success(cachedStats);
    }
    
    final result = await _remoteDataSource.getUserStats();
    
    return result.when(
      success: (stats) async {
        // 快取統計資料
        await _cacheManager.cacheData(AppConstants.userStatsKey, stats.toJson());
        return ApiResult.success(stats);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<List<UserActivity>>> getUserActivities({int page = 1}) async {
    final cacheKey = 'user_activities_$page';
    
    // 先嘗試從快取獲取
    final cachedActivities = await _cacheManager.getCachedData<List<UserActivity>>(
      cacheKey,
      (json) => (json as List).map((item) => UserActivity.fromJson(item)).toList(),
      expiration: const Duration(minutes: 10), // 10分鐘過期
    );
    
    if (cachedActivities != null) {
      return ApiResult.success(cachedActivities);
    }
    
    final result = await _remoteDataSource.getUserActivities(page: page);
    
    return result.when(
      success: (activities) async {
        // 快取活動記錄
        final activitiesJson = activities.map((activity) => activity.toJson()).toList();
        await _cacheManager.cacheData(cacheKey, activitiesJson);
        return ApiResult.success(activities);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  /// 更新快取中的使用者名稱
  Future<void> _updateCachedUserName(String name) async {
    final cachedUserData = await _cacheManager.getCachedUserData();
    if (cachedUserData != null) {
      cachedUserData['name'] = name;
      cachedUserData['updatedAt'] = DateTime.now().toIso8601String();
      await _cacheManager.cacheUserData(cachedUserData);
    }
  }
}