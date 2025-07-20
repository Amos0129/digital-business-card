// lib/core/network/dio_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import 'api_interceptor.dart';
import 'network_exceptions.dart';

/// Dio HTTP 客戶端
/// 
/// 負責處理所有的 HTTP 請求
/// 包括請求配置、攔截器、錯誤處理等
class DioClient {
  // 單例模式
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late Dio _dio;
  
  /// 獲取 Dio 實例
  Dio get dio => _dio;

  /// 初始化 Dio 客戶端
  Future<void> initialize() async {
    _dio = Dio();
    
    // 基礎配置
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: Duration(seconds: AppConstants.connectTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppConstants.requestTimeoutSeconds),
      sendTimeout: Duration(seconds: AppConstants.requestTimeoutSeconds),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      },
    );

    // 添加攔截器
    await _addInterceptors();
    
    if (kDebugMode) {
      print('✅ DioClient 初始化完成');
    }
  }

  /// 添加攔截器
  Future<void> _addInterceptors() async {
    // API 攔截器（處理認證、錯誤等）
    _dio.interceptors.add(ApiInterceptor());
    
    // 日誌攔截器（僅在開發模式下）
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  // ========== GET 請求 ==========
  /// 發送 GET 請求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    }
  }

  // ========== POST 請求 ==========
  /// 發送 POST 請求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    }
  }

  // ========== PUT 請求 ==========
  /// 發送 PUT 請求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    }
  }

  // ========== PATCH 請求 ==========
  /// 發送 PATCH 請求
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    }
  }

  // ========== DELETE 請求 ==========
  /// 發送 DELETE 請求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    }
  }

  // ========== 檔案上傳 ==========
  /// 上傳檔案
  Future<Response<T>> uploadFile<T>(
    String path,
    File file, {
    String fileKey = 'file',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData();
      
      // 添加檔案
      formData.files.add(
        MapEntry(
          fileKey,
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
      
      // 添加其他資料
      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    }
  }

  // ========== 檔案下載 ==========
  /// 下載檔案
  Future<Response> downloadFile(
    String url,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    }
  }

  // ========== 認證相關方法 ==========
  /// 設定認證 Token
  Future<void> setAuthToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    await SecureStorage.instance.store(AppConstants.tokenKey, token);
  }

  /// 清除認證 Token
  Future<void> clearAuthToken() async {
    _dio.options.headers.remove('Authorization');
    await SecureStorage.instance.delete(AppConstants.tokenKey);
  }

  /// 從儲存中恢復認證 Token
  Future<void> restoreAuthToken() async {
    final token = await SecureStorage.instance.read(AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // ========== 工具方法 ==========
  /// 檢查網路連線狀態
  Future<bool> hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// 取消所有請求
  void cancelAllRequests() {
    _dio.clear();
  }

  /// 重新配置基礎 URL
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// 添加自定義攔截器
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// 移除攔截器
  void removeInterceptor(Interceptor interceptor) {
    _dio.interceptors.remove(interceptor);
  }

  /// 創建取消令牌
  CancelToken createCancelToken() {
    return CancelToken();
  }

  /// 重試請求
  Future<Response<T>> retryRequest<T>(
    RequestOptions requestOptions, {
    int maxRetries = AppConstants.maxRetryCount,
  }) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        final response = await _dio.fetch<T>(requestOptions);
        return response;
      } on DioException catch (e) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          throw NetworkExceptions.fromDioException(e);
        }
        
        // 指數退避延遲
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
    
    throw const NetworkExceptions.requestTimeout();
  }

  /// 獲取當前網路狀態
  Future<String> getNetworkInfo() async {
    try {
      final response = await get('/health');
      return 'Network OK - Status: ${response.statusCode}';
    } catch (e) {
      return 'Network Error: $e';
    }
  }

  /// 清理資源
  void dispose() {
    _dio.close();
  }
}