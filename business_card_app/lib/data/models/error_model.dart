// lib/data/models/error_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_model.freezed.dart';
part 'error_model.g.dart';

/// 錯誤模型
/// 
/// 統一處理 API 錯誤回應格式
/// 支援多種錯誤類型和詳細資訊
@freezed
class ErrorModel with _$ErrorModel {
  const factory ErrorModel({
    required String message,
    String? code,
    @JsonKey(name: 'error_code') String? errorCode,
    @Default([]) List<String> details,
    @JsonKey(name: 'timestamp') DateTime? timestamp,
    String? path,
    @Default(500) int status,
    Map<String, dynamic>? metadata,
  }) = _ErrorModel;

  factory ErrorModel.fromJson(Map<String, dynamic> json) =>
      _$ErrorModelFromJson(json);
}

/// 表單驗證錯誤模型
@freezed
class ValidationErrorModel with _$ValidationErrorModel {
  const factory ValidationErrorModel({
    required String field,
    required String message,
    String? code,
    dynamic value,
  }) = _ValidationErrorModel;

  factory ValidationErrorModel.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorModelFromJson(json);
}

/// API 錯誤回應模型
@freezed
class ApiErrorResponse with _$ApiErrorResponse {
  const factory ApiErrorResponse({
    required String error,
    String? message,
    @JsonKey(name: 'error_description') String? errorDescription,
    @Default([]) List<ValidationErrorModel> validationErrors,
    @JsonKey(name: 'request_id') String? requestId,
    @Default(500) int statusCode,
    DateTime? timestamp,
  }) = _ApiErrorResponse;

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorResponseFromJson(json);
}

/// 網路錯誤模型
@freezed
class NetworkErrorModel with _$NetworkErrorModel {
  const factory NetworkErrorModel({
    required NetworkErrorType type,
    required String message,
    String? originalError,
    @JsonKey(name: 'retry_after') int? retryAfter,
    @Default(false) bool canRetry,
  }) = _NetworkErrorModel;

  factory NetworkErrorModel.fromJson(Map<String, dynamic> json) =>
      _$NetworkErrorModelFromJson(json);
}

/// 網路錯誤類型枚舉
enum NetworkErrorType {
  timeout('timeout', '請求逾時'),
  noConnection('no_connection', '無網路連線'),
  serverError('server_error', '伺服器錯誤'),
  badRequest('bad_request', '請求錯誤'),
  unauthorized('unauthorized', '未經授權'),
  forbidden('forbidden', '存取被拒'),
  notFound('not_found', '找不到資源'),
  conflict('conflict', '資料衝突'),
  tooManyRequests('too_many_requests', '請求過於頻繁'),
  unknown('unknown', '未知錯誤');

  const NetworkErrorType(this.code, this.message);
  final String code;
  final String message;

  static NetworkErrorType fromCode(String code) {
    return NetworkErrorType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => NetworkErrorType.unknown,
    );
  }
}

/// 錯誤嚴重性等級
enum ErrorSeverity {
  low('low', '輕微'),
  medium('medium', '中等'),
  high('high', '嚴重'),
  critical('critical', '緊急');

  const ErrorSeverity(this.level, this.displayName);
  final String level;
  final String displayName;
}

/// 錯誤模型擴展方法
extension ErrorModelExtension on ErrorModel {
  /// 檢查是否為認證錯誤
  bool get isAuthError {
    return status == 401 || 
           status == 403 ||
           code == 'UNAUTHORIZED' ||
           code == 'FORBIDDEN';
  }

  /// 檢查是否為網路錯誤
  bool get isNetworkError {
    return status >= 500 ||
           code == 'NETWORK_ERROR' ||
           code == 'CONNECTION_ERROR';
  }

  /// 檢查是否為驗證錯誤
  bool get isValidationError {
    return status == 400 ||
           code == 'VALIDATION_ERROR' ||
           details.isNotEmpty;
  }

  /// 檢查是否可以重試
  bool get canRetry {
    return status >= 500 || 
           status == 408 || 
           status == 429;
  }

  /// 獲取錯誤嚴重性
  ErrorSeverity get severity {
    if (status >= 500) return ErrorSeverity.critical;
    if (status == 401 || status == 403) return ErrorSeverity.high;
    if (status >= 400) return ErrorSeverity.medium;
    return ErrorSeverity.low;
  }

  /// 獲取使用者友好的錯誤訊息
  String get userFriendlyMessage {
    switch (status) {
      case 400:
        return '請求格式錯誤，請檢查輸入的資料';
      case 401:
        return '請重新登入';
      case 403:
        return '權限不足，無法執行此操作';
      case 404:
        return '找不到請求的資源';
      case 408:
        return '請求逾時，請稍後再試';
      case 429:
        return '請求過於頻繁，請稍後再試';
      case 500:
        return '伺服器錯誤，請稍後再試';
      case 503:
        return '服務暫時不可用，請稍後再試';
      default:
        return message.isNotEmpty ? message : '發生未知錯誤';
    }
  }

  /// 創建網路錯誤
  static ErrorModel networkError({String? message}) {
    return ErrorModel(
      message: message ?? '網路連線異常',
      code: 'NETWORK_ERROR',
      status: 0,
      timestamp: DateTime.now(),
    );
  }

  /// 創建認證錯誤
  static ErrorModel authError({String? message}) {
    return ErrorModel(
      message: message ?? '認證失敗',
      code: 'AUTH_ERROR',
      status: 401,
      timestamp: DateTime.now(),
    );
  }

  /// 創建驗證錯誤
  static ErrorModel validationError({
    String? message,
    List<String>? details,
  }) {
    return ErrorModel(
      message: message ?? '資料驗證失敗',
      code: 'VALIDATION_ERROR',
      status: 400,
      details: details ?? [],
      timestamp: DateTime.now(),
    );
  }
}

/// API 錯誤回應擴展方法
extension ApiErrorResponseExtension on ApiErrorResponse {
  /// 檢查是否有驗證錯誤
  bool get hasValidationErrors => validationErrors.isNotEmpty;

  /// 獲取第一個驗證錯誤訊息
  String? get firstValidationError {
    return validationErrors.isNotEmpty 
        ? validationErrors.first.message 
        : null;
  }

  /// 獲取特定欄位的驗證錯誤
  ValidationErrorModel? getFieldError(String fieldName) {
    try {
      return validationErrors.firstWhere(
        (error) => error.field == fieldName,
      );
    } catch (e) {
      return null;
    }
  }

  /// 獲取所有驗證錯誤訊息
  List<String> get allValidationMessages {
    return validationErrors.map((error) => error.message).toList();
  }

  /// 轉換為 ErrorModel
  ErrorModel toErrorModel() {
    return ErrorModel(
      message: message ?? error,
      code: 'API_ERROR',
      status: statusCode,
      details: allValidationMessages,
      timestamp: timestamp,
    );
  }
}

/// 驗證錯誤擴展方法
extension ValidationErrorModelExtension on ValidationErrorModel {
  /// 檢查是否為必填欄位錯誤
  bool get isRequiredError {
    return code == 'required' || 
           message.contains('必填') ||
           message.contains('不可為空');
  }

  /// 檢查是否為格式錯誤
  bool get isFormatError {
    return code == 'format' ||
           code == 'pattern' ||
           message.contains('格式');
  }

  /// 檢查是否為長度錯誤
  bool get isLengthError {
    return code == 'min_length' ||
           code == 'max_length' ||
           message.contains('長度');
  }
}

/// 網路錯誤擴展方法
extension NetworkErrorModelExtension on NetworkErrorModel {
  /// 獲取建議的重試延遲時間（秒）
  int get suggestedRetryDelay {
    if (retryAfter != null) return retryAfter!;
    
    switch (type) {
      case NetworkErrorType.timeout:
        return 5;
      case NetworkErrorType.serverError:
        return 10;
      case NetworkErrorType.tooManyRequests:
        return 30;
      case NetworkErrorType.noConnection:
        return 5;
      default:
        return 3;
    }
  }

  /// 創建連線錯誤
  static NetworkErrorModel connectionError() {
    return const NetworkErrorModel(
      type: NetworkErrorType.noConnection,
      message: '無法連線到伺服器，請檢查網路連線',
      canRetry: true,
    );
  }