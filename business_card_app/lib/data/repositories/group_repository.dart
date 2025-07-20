// lib/data/repositories/group_repository.dart
import '../../core/network/response_handler.dart';
import '../../core/storage/cache_manager.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/group_remote_datasource.dart';
import '../models/group_model.dart';

/// 群組資料倉庫
/// 
/// 負責處理群組相關的資料操作
/// 整合遠端資料源和本地快取
abstract class GroupRepository {
  /// 獲取預設群組
  Future<ApiResult<GroupModel>> getDefaultGroup();
  
  /// 建立群組
  Future<ApiResult<GroupModel>> createGroup(CreateGroupRequest request);
  
  /// 重新命名群組
  Future<ApiResult<GroupModel>> renameGroup(int groupId, String name);
  
  /// 獲取使用者的群組列表
  Future<ApiResult<List<GroupModel>>> getUserGroups();
  
  /// 刪除群組
  Future<ApiResult<void>> deleteGroup(int groupId);
  
  /// 清除群組快取
  Future<void> clearGroupsCache();
}

/// 群組資料倉庫實作
class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource _remoteDataSource;
  final CacheManager _cacheManager;

  GroupRepositoryImpl({
    required GroupRemoteDataSource remoteDataSource,
    required CacheManager cacheManager,
  })  : _remoteDataSource = remoteDataSource,
        _cacheManager = cacheManager;

  @override
  Future<ApiResult<GroupModel>> getDefaultGroup() async {
    // 先嘗試從快取獲取
    final cachedGroup = await _cacheManager.getCachedData<GroupModel>(
      AppConstants.defaultGroupKey,
      (json) => GroupModel.fromJson(json),
    );
    
    if (cachedGroup != null) {
      return ApiResult.success(cachedGroup);
    }
    
    final result = await _remoteDataSource.getDefaultGroup();
    
    return result.when(
      success: (group) async {
        // 快取預設群組
        await _cacheManager.cacheData(
          AppConstants.defaultGroupKey, 
          group.toJson(),
        );
        return ApiResult.success(group);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<GroupModel>> createGroup(CreateGroupRequest request) async {
    final result = await _remoteDataSource.createGroup(request);
    
    return result.when(
      success: (group) async {
        // 清除群組列表快取，強制重新載入
        await _invalidateGroupsCache();
        return ApiResult.success(group);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<GroupModel>> renameGroup(int groupId, String name) async {
    final result = await _remoteDataSource.renameGroup(groupId, name);
    
    return result.when(
      success: (group) async {
        // 更新快取
        await _invalidateGroupsCache();
        await _cacheManager.remove('group_$groupId');
        return ApiResult.success(group);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<List<GroupModel>>> getUserGroups() async {
    // 先嘗試從快取獲取
    final cachedGroups = await _cacheManager.getCachedData<List<GroupModel>>(
      AppConstants.userGroupsKey,
      (json) => (json as List).map((item) => GroupModel.fromJson(item)).toList(),
    );
    
    if (cachedGroups != null) {
      // 背景更新
      _refreshUserGroups();
      return ApiResult.success(cachedGroups);
    }
    
    return await _refreshUserGroups();
  }

  @override
  Future<ApiResult<void>> deleteGroup(int groupId) async {
    final result = await _remoteDataSource.deleteGroup(groupId);
    
    return result.when(
      success: (_) async {
        // 清除相關快取
        await _invalidateGroupsCache();
        await _cacheManager.remove('group_$groupId');
        return ApiResult.success(null);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<void> clearGroupsCache() async {
    await _invalidateGroupsCache();
  }

  /// 刷新使用者群組快取
  Future<ApiResult<List<GroupModel>>> _refreshUserGroups() async {
    final result = await _remoteDataSource.getUserGroups();
    
    return result.when(
      success: (groups) async {
        // 快取群組列表
        final groupsJson = groups.map((group) => group.toJson()).toList();
        await _cacheManager.cacheData(AppConstants.userGroupsKey, groupsJson);
        
        // 快取個別群組資料
        for (final group in groups) {
          await _cacheManager.cacheData('group_${group.id}', group.toJson());
        }
        
        return ApiResult.success(groups);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  /// 清除群組相關快取
  Future<void> _invalidateGroupsCache() async {
    await _cacheManager.remove(AppConstants.userGroupsKey);
    await _cacheManager.remove(AppConstants.defaultGroupKey);
  }
}