// lib/data/datasources/group_remote_datasource.dart
import '../../core/network/dio_client.dart';
import '../../core/network/response_handler.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/group_model.dart';

/// 群組遠端資料源
/// 
/// 負責處理與群組相關的 API 請求
/// 包括建立、讀取、更新、刪除群組等功能
abstract class GroupRemoteDataSource {
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
}

/// 群組遠端資料源實作
class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final DioClient _dioClient;

  GroupRemoteDataSourceImpl({
    required DioClient dioClient,
  }) : _dioClient = dioClient;

  @override
  Future<ApiResult<GroupModel>> getDefaultGroup() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.defaultGroup);
      
      return ResponseHandler.handleResponse(
        response,
        (json) => GroupModel.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<GroupModel>> createGroup(CreateGroupRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.createGroup,
        data: request.toJson(),
      );
      
      return ResponseHandler.handleResponse(
        response,
        (json) => GroupModel.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<GroupModel>> renameGroup(int groupId, String name) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.renameGroup(groupId),
        data: {'name': name},
      );
      
      return ResponseHandler.handleResponse(
        response,
        (json) => GroupModel.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<List<GroupModel>>> getUserGroups() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.userGroups);
      
      return ResponseHandler.handleListResponse(
        response,
        (json) => GroupModel.fromJson(json),
      );
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }

  @override
  Future<ApiResult<void>> deleteGroup(int groupId) async {
    try {
      final response = await _dioClient.delete(
        ApiEndpoints.deleteGroup(groupId),
      );
      
      if (response.statusCode == 200) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          NetworkExceptions.defaultError('刪除群組失敗'),
        );
      }
    } catch (e) {
      return ApiResult.failure(e as NetworkExceptions);
    }
  }
}

/// 建立群組請求模型
class CreateGroupRequest {
  final String name;

  CreateGroupRequest({required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}