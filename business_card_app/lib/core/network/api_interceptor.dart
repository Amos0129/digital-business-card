// lib/core/network/api_interceptor.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import '../services/navigation_service.dart';
import 'network_exceptions.dart';

/// API 請求攔截器
/// 
/// 負責處理請求和響應的攔截邏輯
/// 包括認證、錯誤處理、重試等
class ApiInterceptor extends Interceptor {
  /// 需要重試的 HTTP 狀態碼
  static const List<int> retryStatusCodes = [408, 429, 500, 502, 503, 504];
  
  /// 最大重試次數
  static const int maxRetries = AppConstants.maxRetryCount;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // 添加認證 Token
      await _addAuthToken(options);
      
      // 添加請求 ID 用於追蹤
      options.headers['X-Request-ID'] = _generateRequestId();
      
      // 添加設備資訊
      await _addDeviceInfo(options);
      
      // 添加時間戳
      options.headers['X-Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
      
      if (kDebugMode) {
        debugPrint('🚀 API Request: ${options.method} ${options.path}');
        debugPrint('📤 Headers: ${options.headers}');
        if (options.data != null) {
          debugPrint('📤 Data: ${options.data}');
        }
      }
      
      handler.next(options);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Request Error: $e');
      }
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    try {
      // 記錄響應時間
      final requestTime = response.requestOptions.headers['X-Timestamp'];
      if (requestTime != null) {
        final responseTime = DateTime.now().millisecondsSinceEpoch;
        final duration = responseTime - int.parse(requestTime.toString());
        response.extra['duration'] = duration;
        
        if (kDebugMode) {
          debugPrint('⏱️ Response Time: ${duration}ms');
        }
      }
      
      if (kDebugMode) {
        debugPrint('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
        debugPrint('📥 Data: ${response.data}');
      }
      
      // 處理特殊狀態碼
      _handleSpecialStatusCodes(response);
      
      handler.next(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Response Error: $e');
      }
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      debugPrint('❌ API Error: ${err.type} ${err.message}');
      debugPrint('🔍 Error Details: ${err.error}');
      debugPrint('📍 Path: ${err.requestOptions.path}');
    }
    
    // 處理認證錯誤
    if (await _handleAuthError(err)) {
      return;
    }
    
    // 處理網路錯誤並重試
    if (await _handleRetryableError(err, handler)) {
      return;
    }
    
    // 處理其他錯誤類型
    _handleOtherErrors(err);
    
    handler.next(err);
  }

  /// 添加認證 Token
  Future<void> _addAuthToken(RequestOptions options) async {
    try {
      final token = await SecureStorage.instance.read(AppConstants.tokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to read auth token: $e');
      }
    }
  }

  /// 添加設備資訊
  Future<void> _addDeviceInfo(RequestOptions options) async {
    try {
      // 添加平台資訊
      options.headers['X-Platform'] = defaultTargetPlatform.name;
      
      // 添加應用版本
      options.headers['X-App-Version'] = AppConstants.appVersion;
      
      // 添加用戶代理
      options.headers['User-Agent'] = 
          '${AppConstants.appName}/${AppConstants.appVersion} (${defaultTargetPlatform.name})';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to add device info: $e');
      }
    }
  }

  /// 生成請求 ID
  String _generateRequestId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        (1000 + (999 * (DateTime.now().microsecond / 1000000))).round().toString();
  }

  /// 處理特殊狀態碼
  void _handleSpecialStatusCodes(Response response) {
    switch (response.statusCode) {
      case 202:
        // 接受處理，但尚未完成
        if (kDebugMode) {
          debugPrint('ℹ️ Request accepted but processing not complete');
        }
        break;
      case 204:
        // 無內容響應
        if (kDebugMode) {
          debugPrint('ℹ️ No content response');
        }
        break;
    }
  }

  /// 處理認證錯誤
  Future<bool> _handleAuthError(DioException err) async {
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        debugPrint('🔐 Authentication error - clearing token and redirecting to login');
      }
      
      try {
        // 清除認證資訊
        await SecureStorage.instance.delete(AppConstants.tokenKey);
        await SecureStorage.instance.delete(AppConstants.userDataKey);
        
        // 導航到登入頁面
        final navigationService = NavigationService.instance;
        if (navigationService.currentContext != null) {
          // 延遲執行以避免在攔截器中直接導航
          Future.microtask(() {
            navigationService.pushNamedAndClearStack('/auth/login');
          });
        }
        
        return true;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Failed to handle auth error: $e');
        }
      }
    }
    
    return false;
  }

  /// 處理可重試的錯誤
  Future<bool> _handleRetryableError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 檢查是否為可重試的錯誤
    if (!_isRetryableError(err)) {
      return false;
    }
    
    // 獲取當前重試次數
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
    
    if (retryCount < maxRetries) {
      if (kDebugMode) {
        debugPrint('🔄 Retrying request (${retryCount + 1}/$maxRetries)');
      }
      
      try {
        // 增加重試次數
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        // 計算延遲時間（指數退避）
        final delaySeconds = _calculateRetryDelay(retryCount);
        await Future.delayed(Duration(seconds: delaySeconds));
        
        // 重新發送請求
        final dio = Dio();
        final response = await dio.fetch(err.requestOptions);
        
        handler.resolve(response);
        return true;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Retry failed: $e');
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint('❌ Max retries exceeded');
      }
    }
    
    return false;
  }

  /// 處理其他錯誤
  void _handleOtherErrors(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        if (kDebugMode) {
          debugPrint('⏰ Timeout error: ${err.type}');
        }
        break;
      case DioExceptionType.badCertificate:
        if (kDebugMode) {
          debugPrint('🔒 SSL certificate error');
        }
        break;
      case DioExceptionType.connectionError:
        if (kDebugMode) {
          debugPrint('🌐 Connection error - check network');
        }
        break;
      case DioExceptionType.unknown:
        if (kDebugMode) {
          debugPrint('❓ Unknown error: ${err.error}');
        }
        break;
      default:
        if (kDebugMode) {
          debugPrint('❌ Other error: ${err.type}');
        }
    }
  }

  /// 檢查是否為可重試的錯誤
  bool _isRetryableError(DioException err) {
    // 網路相關錯誤
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    
    // 特定的 HTTP 狀態碼
    if (err.response?.statusCode != null) {
      return retryStatusCodes.contains(err.response!.statusCode);
    }
    
    return false;
  }

  /// 計算重試延遲時間（指數退避算法）
  int _calculateRetryDelay(int retryCount) {
    // 基礎延遲 1 秒，每次重試翻倍，最大 8 秒
    final baseDelay = 1;
    final maxDelay = 8;
    final delay = baseDelay * (1 << retryCount); // 2^retryCount
    
    return delay.clamp(baseDelay, maxDelay);
  }

  /// 記錄詳細的錯誤資訊
  void _logDetailedError(DioException err) {
    if (!kDebugMode) return;
    
    final buffer = StringBuffer();
    buffer.writeln('🚨 ======= API Error Details =======');
    buffer.writeln('Method: ${err.requestOptions.method}');
    buffer.writeln('URL: ${err.requestOptions.uri}');
    buffer.writeln('Error Type: ${err.type}');
    buffer.writeln('Status Code: ${err.response?.statusCode}');
    buffer.writeln('Message: ${err.message}');
    
    if (err.requestOptions.headers.isNotEmpty) {
      buffer.writeln('Request Headers:');
      err.requestOptions.headers.forEach((key, value) {
        // 隱藏敏感資訊
        if (key.toLowerCase().contains('auth') || 
            key.toLowerCase().contains('token')) {
          buffer.writeln('  $key: ***HIDDEN***');
        } else {
          buffer.writeln('  $key: $value');
        }
      });
    }
    
    if (err.requestOptions.data != null) {
      buffer.writeln('Request Data: ${err.requestOptions.data}');
    }
    
    if (err.response?.data != null) {
      buffer.writeln('Response Data: ${err.response!.data}');
    }
    
    if (err.stackTrace != null) {
      buffer.writeln('Stack Trace: ${err.stackTrace}');
    }
    
    buffer.writeln('=====================================');
    
    debugPrint(buffer.toString());
  }

  /// 檢查響應是否包含錯誤
  bool _hasResponseError(Response response) {
    // 檢查狀態碼
    if (response.statusCode == null || response.statusCode! >= 400) {
      return true;
    }
    
    // 檢查響應體中的錯誤標記
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      return data.containsKey('error') || 
             data.containsKey('errors') ||
             (data.containsKey('success') && data['success'] == false);
    }
    
    return false;
  }

  /// 格式化響應資料
  String _formatResponseData(dynamic data) {
    try {
      if (data == null) return 'null';
      if (data is String) return data;
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  /// 獲取錯誤描述
  String _getErrorDescription(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return '連線逾時';
      case DioExceptionType.sendTimeout:
        return '發送逾時';
      case DioExceptionType.receiveTimeout:
        return '接收逾時';
      case DioExceptionType.badResponse:
        return '伺服器響應錯誤';
      case DioExceptionType.cancel:
        return '請求已取消';
      case DioExceptionType.connectionError:
        return '連線錯誤';
      case DioExceptionType.badCertificate:
        return 'SSL 憑證錯誤';
      case DioExceptionType.unknown:
      default:
        return '未知錯誤';
    }
  }
}