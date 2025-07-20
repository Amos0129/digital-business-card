// lib/data/models/response_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'response_model.freezed.dart';
part 'response_model.g.dart';

/// 基礎 API 回應模型
/// 
/// 統一處理 API 回應格式
/// 支援泛型資料類型
@freezed
class BaseResponse<T> with _$BaseResponse<T> {
  const factory BaseResponse({
    required bool success,
    String? message,
    T? data,
    @JsonKey(name: 'error_code') String? errorCode,
    @JsonKey(name: 'request_id') String? requestId,
    DateTime? timestamp,
  }) = _BaseResponse<T>;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$BaseResponseFromJson(json, fromJsonT);
}

/// 分頁回應模型
@freezed
class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    required List<T> data,
    required PaginationMeta meta,
    @Default(true) bool success,
    String? message,
  }) = _PaginatedResponse<T>;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);
}

/// 分頁元資料模型
@freezed
class PaginationMeta with _$PaginationMeta {
  const factory PaginationMeta({
    @JsonKey(name: 'current_page') required int currentPage,
    @JsonKey(name: 'per_page') required int perPage,
    @JsonKey(name: 'total_items') required int totalItems,
    @JsonKey(name: 'total_pages') required int totalPages,
    @JsonKey(name: 'has_more') required bool hasMore,
    @JsonKey(name: 'has_previous') required bool hasPrevious,
  }) = _PaginationMeta;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}

/// 成功回應模型
@freezed
class SuccessResponse with _$SuccessResponse {
  const factory SuccessResponse({
    @Default(true) bool success,
    required String message,
    @JsonKey(name: 'request_id') String? requestId,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) = _SuccessResponse;

  factory SuccessResponse.fromJson(Map<String, dynamic> json) =>
      _$SuccessResponseFromJson(json);
}

/// 檔案上傳回應模型
@freezed
class FileUploadResponse with _$FileUploadResponse {
  const factory FileUploadResponse({
    @Default(true) bool success,
    required String message,
    @JsonKey(name: 'file_url') required String fileUrl,
    @JsonKey(name: 'file_name') String? fileName,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'file_type') String? fileType,
    @JsonKey(name: 'upload_id') String? uploadId,
  }) = _FileUploadResponse;

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$FileUploadResponseFromJson(json);
}

/// 批次操作回應模型
@freezed
class BatchResponse<T> with _$BatchResponse<T> {
  const factory BatchResponse({
    @Default(true) bool success,
    required String message,
    @Default([]) List<T> successful,
    @Default([]) List<BatchError> failed,
    @JsonKey(name: 'total_count') required int totalCount,
    @JsonKey(name: 'success_count') required int successCount,
    @JsonKey(name: 'failed_count') required int failedCount,
  }) = _BatchResponse<T>;

  factory BatchResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$BatchResponseFromJson(json, fromJsonT);
}

/// 批次錯誤模型
@freezed
class BatchError with _$BatchError {
  const factory BatchError({
    required String id,
    required String error,
    String? message,
    @JsonKey(name: 'error_code') String? errorCode,
  }) = _BatchError;

  factory BatchError.fromJson(Map<String, dynamic> json) =>
      _$BatchErrorFromJson(json);
}

/// 統計回應模型
@freezed
class StatsResponse with _$StatsResponse {
  const factory StatsResponse({
    @Default(true) bool success,
    required Map<String, int> counts,
    required Map<String, double> percentages,
    @JsonKey(name: 'time_range') TimeRange? timeRange,
    @JsonKey(name: 'last_updated') DateTime? lastUpdated,
  }) = _StatsResponse;

  factory StatsResponse.fromJson(Map<String, dynamic> json) =>
      _$StatsResponseFromJson(json);
}

/// 時間範圍模型
@freezed
class TimeRange with _$TimeRange {
  const factory TimeRange({
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') required DateTime endDate,
    String? label,
  }) = _TimeRange;

  factory TimeRange.fromJson(Map<String, dynamic> json) =>
      _$TimeRangeFromJson(json);
}

/// 回應狀態枚舉
enum ResponseStatus {
  success('success', '成功'),
  error('error', '錯誤'),
  warning('warning', '警告'),
  info('info', '資訊');

  const ResponseStatus(this.code, this.message);
  final String code;
  final String message;

  static ResponseStatus fromCode(String code) {
    return ResponseStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => ResponseStatus.info,
    );
  }
}

/// 基礎回應擴展方法
extension BaseResponseExtension<T> on BaseResponse<T> {
  /// 檢查是否成功
  bool get isSuccess => success && errorCode == null;

  /// 檢查是否失敗
  bool get isFailure => !success || errorCode != null;

  /// 獲取錯誤訊息
  String? get errorMessage => isFailure ? message : null;

  /// 安全獲取資料
  T? get safeData => isSuccess ? data : null;

  /// 轉換資料類型
  BaseResponse<R> map<R>(R Function(T) transform) {
    if (isSuccess && data != null) {
      return BaseResponse<R>(
        success: success,
        message: message,
        data: transform(data as T),
        errorCode: errorCode,
        requestId: requestId,
        timestamp: timestamp,
      );
    }
    return BaseResponse<R>(
      success: success,
      message: message,
      data: null,
      errorCode: errorCode,
      requestId: requestId,
      timestamp: timestamp,
    );
  }

  /// 創建成功回應
  static BaseResponse<T> success<T>({
    T? data,
    String? message,
    String? requestId,
  }) {
    return BaseResponse<T>(
      success: true,
      message: message ?? '操作成功',
      data: data,
      requestId: requestId,
      timestamp: DateTime.now(),
    );
  }

  /// 創建失敗回應
  static BaseResponse<T> failure<T>({
    required String message,
    String? errorCode,
    String? requestId,
  }) {
    return BaseResponse<T>(
      success: false,
      message: message,
      data: null,
      errorCode: errorCode,
      requestId: requestId,
      timestamp: DateTime.now(),
    );
  }
}

/// 分頁回應擴展方法
extension PaginatedResponseExtension<T> on PaginatedResponse<T> {
  /// 檢查是否有下一頁
  bool get hasNextPage => meta.hasMore;

  /// 檢查是否有上一頁
  bool get hasPreviousPage => meta.hasPrevious;

  /// 檢查是否為第一頁
  bool get isFirstPage => meta.currentPage == 1;

  /// 檢查是否為最後一頁
  bool get isLastPage => !meta.hasMore;

  /// 獲取下一頁頁碼
  int? get nextPage => hasNextPage ? meta.currentPage + 1 : null;

  /// 獲取上一頁頁碼
  int? get previousPage => hasPreviousPage ? meta.currentPage - 1 : null;

  /// 獲取顯示範圍文字
  String get displayRange {
    final start = (meta.currentPage - 1) * meta.perPage + 1;
    final end = (start + data.length - 1).clamp(0, meta.totalItems);
    return '$start-$end / ${meta.totalItems}';
  }

  /// 合併分頁資料（用於無限滾動）
  PaginatedResponse<T> merge(PaginatedResponse<T> other) {
    return copyWith(
      data: [...data, ...other.data],
      meta: other.meta,
    );
  }
}

/// 分頁元資料擴展方法
extension PaginationMetaExtension on PaginationMeta {
  /// 獲取起始項目索引
  int get startIndex => (currentPage - 1) * perPage + 1;

  /// 獲取結束項目索引
  int get endIndex => (startIndex + perPage - 1).clamp(startIndex, totalItems);

  /// 計算進度百分比
  double get progressPercentage {
    if (totalItems == 0) return 0.0;
    return (currentPage * perPage) / totalItems;
  }

  /// 獲取分頁摘要
  String get summary {
    return '第 $currentPage 頁，共 $totalPages 頁 (總計 $totalItems 項)';
  }
}

/// 批次回應擴展方法
extension BatchResponseExtension<T> on BatchResponse<T> {
  /// 獲取成功率
  double get successRate {
    if (totalCount == 0) return 0.0;
    return successCount / totalCount;
  }

  /// 獲取失敗率
  double get failureRate {
    if (totalCount == 0) return 0.0;
    return failedCount / totalCount;
  }

  /// 檢查是否全部成功
  bool get isAllSuccess => failedCount == 0 && totalCount > 0;

  /// 檢查是否全部失敗
  bool get isAllFailure => successCount == 0 && totalCount > 0;

  /// 檢查是否部分成功
  bool get isPartialSuccess => successCount > 0 && failedCount > 0;

  /// 獲取處理摘要
  String get processSummary {
    if (isAllSuccess) {
      return '全部 $totalCount 項處理成功';
    } else if (isAllFailure) {
      return '全部 $totalCount 項處理失敗';
    } else {
      return '成功 $successCount 項，失敗 $failedCount 項，共 $totalCount 項';
    }
  }
}