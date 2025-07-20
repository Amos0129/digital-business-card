// lib/core/network/network_exceptions.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_exceptions.freezed.dart';

/// 網路例外處理類
/// 
/// 使用 Freezed 包來創建不可變的例外類型
/// 提供統一的錯誤處理和使用者友好的錯誤訊息
@freezed
class NetworkExceptions with _$NetworkExceptions {
  /// 請求已取消
  const factory NetworkExceptions.requestCancelled() = RequestCancelled;

  /// 未經授權
  const factory NetworkExceptions.unauthorizedRequest() = UnauthorizedRequest;

  /// 請求錯誤
  const factory NetworkExceptions.badRequest() = BadRequest;

  /// 資源未找到
  const factory NetworkExceptions.notFound(String reason) = NotFound;

  /// 方法不被允許
  const factory NetworkExceptions.methodNotAllowed() = MethodNotAllowed;

  /// 不可接受的請求
  const factory NetworkExceptions.notAcceptable() = NotAcceptable;

  /// 請求逾時
  const factory NetworkExceptions.requestTimeout() = RequestTimeout;

  /// 發送逾時
  const factory NetworkExceptions.sendTimeout() = SendTimeout;

  /// 衝突
  const factory NetworkExceptions.conflict() = Conflict;

  /// 內部伺服器錯誤
  const factory NetworkExceptions.internalServerError() = InternalServerError;

  /// 未實現
  const factory NetworkExceptions.notImplemented() = NotImplemented;

  /// 服務不可用
  const factory NetworkExceptions.serviceUnavailable() = ServiceUnavailable;

  /// 無網路連線
  const factory NetworkExceptions.noInternetConnection() = NoInternetConnection;

  /// 格式錯誤的請求
  const factory NetworkExceptions.formatException() = FormatException;

  /// 無法處理的實體
  const factory NetworkExceptions.unableToProcess() = UnableToProcess;

  /// 預設錯誤
  const factory NetworkExceptions.defaultError(String error) = DefaultError;

  /// 接收逾時
  const factory NetworkExceptions.unexpectedError() = UnexpectedError;

  /// 憑證錯誤
  const factory NetworkExceptions.badCertificate() = BadCertificate;

  /// 太多請求
  const factory NetworkExceptions.tooManyRequests() = TooManyRequests;

  /// 伺服器無回應
  const factory NetworkExceptions.serverNotResponding() = ServerNotResponding;

  /// 從 DioException 創建 NetworkExceptions
  static NetworkExceptions fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        return const NetworkExceptions.requestCancelled();
      
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkExceptions.requestTimeout();
      
      case DioExceptionType.sendTimeout:
        return const NetworkExceptions.sendTimeout();
      
      case DioExceptionType.badResponse:
        return _handleResponseError(dioException);
      
      case DioExceptionType.badCertificate:
        return const NetworkExceptions.badCertificate();
      
      case DioExceptionType.connectionError:
        return _handleConnectionError(dioException);
      
      case DioExceptionType.unknown:
      default:
        return _handleUnknownError(dioException);
    }
  }

  /// 處理響應錯誤
  static NetworkExceptions _handleResponseError(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    
    switch (statusCode) {
      case 400:
        return const NetworkExceptions.badRequest();
      case 401:
        return const NetworkExceptions.unauthorizedRequest();
      case 404:
        return NetworkExceptions.notFound(
          dioException.response?.data?['message'] ?? '找不到請求的資源'
        );
      case 405:
        return const NetworkExceptions.methodNotAllowed();
      case 406:
        return const NetworkExceptions.notAcceptable();
      case 408:
        return const NetworkExceptions.requestTimeout();
      case 409:
        return const NetworkExceptions.conflict();
      case 422:
        return const NetworkExceptions.unableToProcess();
      case 429:
        return const NetworkExceptions.tooManyRequests();
      case 500:
        return const NetworkExceptions.internalServerError();
      case 501:
        return const NetworkExceptions.notImplemented();
      case 503:
        return const NetworkExceptions.serviceUnavailable();
      default:
        return NetworkExceptions.defaultError(
          dioException.response?.data?['message'] ?? 
          '收到意外的狀態碼: $statusCode'
        );
    }
  }

  /// 處理連線錯誤
  static NetworkExceptions _handleConnectionError(DioException dioException) {
    if (dioException.error is SocketException) {
      return const NetworkExceptions.noInternetConnection();
    }
    
    // 檢查是否為 DNS 解析錯誤
    if (dioException.message?.contains('Failed host lookup') == true) {
      return const NetworkExceptions.noInternetConnection();
    }
    
    // 檢查是否為伺服器無回應
    if (dioException.message?.contains('Connection refused') == true ||
        dioException.message?.contains('Network is unreachable') == true) {
      return const NetworkExceptions.serverNotResponding();
    }
    
    return NetworkExceptions.defaultError(
      dioException.message ?? '連線錯誤'
    );
  }

  /// 處理未知錯誤
  static NetworkExceptions _handleUnknownError(DioException dioException) {
    if (dioException.error is SocketException) {
      return const NetworkExceptions.noInternetConnection();
    }
    
    if (dioException.error is FormatException) {
      return const NetworkExceptions.formatException();
    }
    
    return NetworkExceptions.defaultError(
      dioException.message ?? '發生未知錯誤'
    );
  }
}

/// NetworkExceptions 擴展方法
extension NetworkExceptionsExtension on NetworkExceptions {
  /// 獲取使用者友好的錯誤訊息
  String get errorMessage {
    return when(
      requestCancelled: () => '請求已取消',
      unauthorizedRequest: () => '未經授權，請重新登入',
      badRequest: () => '請求格式錯誤',
      notFound: (reason) => reason,
      methodNotAllowed: () => '不支援的請求方法',
      notAcceptable: () => '請求不被接受',
      requestTimeout: () => '請求逾時，請稍後再試',
      sendTimeout: () => '發送逾時，請檢查網路連線',
      conflict: () => '請求衝突，請稍後再試',
      internalServerError: () => '伺服器內部錯誤',
      notImplemented: () => '功能尚未實現',
      serviceUnavailable: () => '服務暫時不可用',
      noInternetConnection: () => '無網路連線，請檢查網路設定',
      formatException: () => '資料格式錯誤',
      unableToProcess: () => '無法處理請求',
      defaultError: (error) => error,
      unexpectedError: () => '發生意外錯誤',
      badCertificate: () => 'SSL 憑證錯誤',
      tooManyRequests: () => '請求過於頻繁，請稍後再試',
      serverNotResponding: () => '伺服器無回應',
    );
  }

  /// 獲取錯誤代碼
  String get errorCode {
    return when(
      requestCancelled: () => 'REQUEST_CANCELLED',
      unauthorizedRequest: () => 'UNAUTHORIZED',
      badRequest: () => 'BAD_REQUEST',
      notFound: (reason) => 'NOT_FOUND',
      methodNotAllowed: () => 'METHOD_NOT_ALLOWED',
      notAcceptable: () => 'NOT_ACCEPTABLE',
      requestTimeout: () => 'REQUEST_TIMEOUT',
      sendTimeout: () => 'SEND_TIMEOUT',
      conflict: () => 'CONFLICT',
      internalServerError: () => 'INTERNAL_SERVER_ERROR',
      notImplemented: () => 'NOT_IMPLEMENTED',
      serviceUnavailable: () => 'SERVICE_UNAVAILABLE',
      noInternetConnection: () => 'NO_INTERNET_CONNECTION',
      formatException: () => 'FORMAT_EXCEPTION',
      unableToProcess: () => 'UNABLE_TO_PROCESS',
      defaultError: (error) => 'DEFAULT_ERROR',
      unexpectedError: () => 'UNEXPECTED_ERROR',
      badCertificate: () => 'BAD_CERTIFICATE',
      tooManyRequests: () => 'TOO_MANY_REQUESTS',
      serverNotResponding: () => 'SERVER_NOT_RESPONDING',
    );
  }

  /// 檢查是否為網路連線錯誤
  bool get isNetworkError {
    return when(
      noInternetConnection: () => true,
      requestTimeout: () => true,
      sendTimeout: () => true,
      serverNotResponding: () => true,
      orElse: () => false,
    );
  }

  /// 檢查是否為認證錯誤
  bool get isAuthError {
    return when(
      unauthorizedRequest: () => true,
      orElse: () => false,
    );
  }

  /// 檢查是否為伺服器錯誤
  bool get isServerError {
    return when(
      internalServerError: () => true,
      notImplemented: () => true,
      serviceUnavailable: () => true,
      serverNotResponding: () => true,
      orElse: () => false,
    );
  }

  /// 檢查是否為客戶端錯誤
  bool get isClientError {
    return when(
      badRequest: () => true,
      notFound: (_) => true,
      methodNotAllowed: () => true,
      notAcceptable: () => true,
      conflict: () => true,
      unableToProcess: () => true,
      tooManyRequests: () => true,
      orElse: () => false,
    );
  }

  /// 檢查是否可以重試
  bool get canRetry {
    return when(
      requestTimeout: () => true,
      sendTimeout: () => true,
      noInternetConnection: () => true,
      internalServerError: () => true,
      serviceUnavailable: () => true,
      serverNotResponding: () => true,
      tooManyRequests: () => true,
      orElse: () => false,
    );
  }

  /// 獲取建議的重試延遲時間（秒）
  int get retryDelaySeconds {
    return when(
      tooManyRequests: () => 60, // 請求過於頻繁，等待較長時間
      serviceUnavailable: () => 30, // 服務不可用，等待中等時間
      internalServerError: () => 15, // 伺服器錯誤，等待較短時間
      requestTimeout: () => 5, // 請求逾時，快速重試
      sendTimeout: () => 5, // 發送逾時，快速重試
      noInternetConnection: () => 10, // 無網路連線，等待較短時間
      serverNotResponding: () => 20, // 伺服器無回應，等待中等時間
      orElse: () => 5, // 其他錯誤，預設等待時間
    );
  }

  /// 轉換為異常物件
  Exception toException() {
    return Exception(errorMessage);
  }

  /// 記錄錯誤到日誌
  void logError([String? context]) {
    final logMessage = context != null 
        ? '$context: $errorCode - $errorMessage'
        : '$errorCode - $errorMessage';
    
    print('🔥 NetworkException: $logMessage');
  }
}