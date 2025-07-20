// lib/core/network/response_handler.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'network_exceptions.dart';

/// API 響應處理器
/// 
/// 提供統一的響應處理邏輯
/// 包括成功響應解析、錯誤處理、資料轉換等
class ResponseHandler {
  // 防止實例化
  ResponseHandler._();

  /// 處理 API 響應
  static ApiResult<T> handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      // 檢查響應狀態
      if (!_isSuccessResponse(response)) {
        return ApiResult.failure(_extractError(response));
      }

      // 解析響應資料
      final data = _parseResponseData<T>(response, fromJson);
      return ApiResult.success(data);
    } catch (e, stackTrace) {
      debugPrint('❌ Response handling error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      
      return ApiResult.failure(
        const NetworkExceptions.formatException(),
      );
    }
  }

  /// 處理列表響應
  static ApiResult<List<T>> handleListResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (!_isSuccessResponse(response)) {
        return ApiResult.failure(_extractError(response));
      }

      final data = _parseListResponseData<T>(response, fromJson);
      return ApiResult.success(data);
    } catch (e, stackTrace) {
      debugPrint('❌ List response handling error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      
      return ApiResult.failure(
        const NetworkExceptions.formatException(),
      );
    }
  }

  /// 處理分頁響應
  static ApiResult<PaginatedResult<T>> handlePaginatedResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (!_isSuccessResponse(response)) {
        return ApiResult.failure(_extractError(response));
      }

      final data = _parsePaginatedResponseData<T>(response, fromJson);
      return ApiResult.success(data);
    } catch (e, stackTrace) {
      debugPrint('❌ Paginated response handling error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      
      return ApiResult.failure(
        const NetworkExceptions.formatException(),
      );
    }
  }

  /// 處理檔案響應
  static ApiResult<String> handleFileResponse(Response response) {
    try {
      if (!_isSuccessResponse(response)) {
        return ApiResult.failure(_extractError(response));
      }

      // 檔案響應通常包含檔案 URL 或路徑
      final data = response.data;
      if (data is String) {
        return ApiResult.success(data);
      } else if (data is Map<String, dynamic>) {
        final url = data['url'] ?? data['path'] ?? data['file_url'];
        if (url is String) {
          return ApiResult.success(url);
        }
      }

      return ApiResult.failure(
        const NetworkExceptions.formatException(),
      );
    } catch (e) {
      return ApiResult.failure(
        const NetworkExceptions.formatException(),
      );
    }
  }

  /// 檢查是否為成功響應
  static bool _isSuccessResponse(Response response) {
    final statusCode = response.statusCode;
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  /// 提取錯誤資訊
  static NetworkExceptions _extractError(Response response) {
    final statusCode = response.statusCode;
    final data = response.data;

    // 嘗試從響應中提取錯誤訊息
    String? errorMessage;
    if (data is Map<String, dynamic>) {
      errorMessage = data['message'] ?? 
                    data['error'] ?? 
                    data['msg'] ??
                    data['detail'];
    }

    // 根據狀態碼返回對應的錯誤
    switch (statusCode) {
      case 400:
        return const NetworkExceptions.badRequest();
      case 401:
        return const NetworkExceptions.unauthorizedRequest();
      case 404:
        return NetworkExceptions.notFound(
          errorMessage ?? '找不到請求的資源'
        );
      case 422:
        return const NetworkExceptions.unableToProcess();
      case 429:
        return const NetworkExceptions.tooManyRequests();
      case 500:
        return const NetworkExceptions.internalServerError();
      case 503:
        return const NetworkExceptions.serviceUnavailable();
      default:
        return NetworkExceptions.defaultError(
          errorMessage ?? '請求失敗 (狀態碼: $statusCode)'
        );
    }
  }

  /// 解析單一物件響應資料
  static T _parseResponseData<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = response.data;
    
    if (data == null) {
      throw const FormatException('響應資料為空');
    }

    if (data is Map<String, dynamic>) {
      return fromJson(data);
    }

    if (data is String) {
      try {
        final jsonData = jsonDecode(data) as Map<String, dynamic>;
        return fromJson(jsonData);
      } catch (e) {
        throw FormatException('無法解析 JSON 資料: $e');
      }
    }

    throw FormatException('不支援的資料格式: ${data.runtimeType}');
  }

  /// 解析列表響應資料
  static List<T> _parseListResponseData<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = response.data;
    
    if (data == null) {
      return [];
    }

    if (data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map(fromJson)
          .toList();
    }

    if (data is Map<String, dynamic>) {
      // 檢查是否有 data 或 items 字段
      final items = data['data'] ?? data['items'] ?? data['results'];
      if (items is List) {
        return items
            .cast<Map<String, dynamic>>()
            .map(fromJson)
            .toList();
      }
    }

    if (data is String) {
      try {
        final jsonData = jsonDecode(data);
        if (jsonData is List) {
          return jsonData
              .cast<Map<String, dynamic>>()
              .map(fromJson)
              .toList();
        }
      } catch (e) {
        throw FormatException('無法解析 JSON 列表: $e');
      }
    }

    throw FormatException('不支援的列表格式: ${data.runtimeType}');
  }

  /// 解析分頁響應資料
  static PaginatedResult<T> _parsePaginatedResponseData<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = response.data;
    
    if (data == null || data is! Map<String, dynamic>) {
      throw const FormatException('分頁響應格式錯誤');
    }

    final items = data['data'] ?? data['items'] ?? data['results'] ?? [];
    final total = data['total'] ?? data['count'] ?? 0;
    final page = data['page'] ?? data['current_page'] ?? 1;
    final pageSize = data['page_size'] ?? data['per_page'] ?? AppConstants.pageSize;
    final hasMore = data['has_more'] ?? 
                   data['has_next'] ?? 
                   (page * pageSize < total);

    if (items is! List) {
      throw const FormatException('分頁資料格式錯誤');
    }

    final itemList = items
        .cast<Map<String, dynamic>>()
        .map(fromJson)
        .toList();

    return PaginatedResult<T>(
      items: itemList,
      total: total is int ? total : int.tryParse(total.toString()) ?? 0,
      page: page is int ? page : int.tryParse(page.toString()) ?? 1,
      pageSize: pageSize is int ? pageSize : int.tryParse(pageSize.toString()) ?? AppConstants.pageSize,
      hasMore: hasMore is bool ? hasMore : false,
    );
  }

  /// 記錄響應詳情
  static void logResponse(Response response, [String? tag]) {
    if (!kDebugMode) return;

    final buffer = StringBuffer();
    buffer.writeln('📥 ======= API Response ${tag ?? ''} =======');
    buffer.writeln('Status: ${response.statusCode}');
    buffer.writeln('URL: ${response.requestOptions.uri}');
    
    if (response.headers.isNotEmpty) {
      buffer.writeln('Headers:');
      response.headers.forEach((key, values) {
        buffer.writeln('  $key: ${values.join(', ')}');
      });
    }
    
    buffer.writeln('Data: ${_formatResponseData(response.data)}');
    buffer.writeln('==========================================');
    
    debugPrint(buffer.toString());
  }

  /// 格式化響應資料用於日誌
  static String _formatResponseData(dynamic data) {
    try {
      if (data == null) return 'null';
      if (data is String) {
        // 限制字串長度避免日誌過長
        return data.length > 500 ? '${data.substring(0, 500)}...' : data;
      }
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      // 限制 JSON 長度
      return jsonString.length > 1000 ? '${jsonString.substring(0, 1000)}...' : jsonString;
    } catch (e) {
      return data.toString();
    }
  }
}

/// API 結果封裝類
class ApiResult<T> {
  final T? data;
  final NetworkExceptions? error;
  final bool isSuccess;

  const ApiResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  /// 創建成功結果
  factory ApiResult.success(T data) {
    return ApiResult._(
      data: data,
      isSuccess: true,
    );
  }

  /// 創建失敗結果
  factory ApiResult.failure(NetworkExceptions error) {
    return ApiResult._(
      error: error,
      isSuccess: false,
    );
  }

  /// 當成功時執行
  R when<R>({
    required R Function(T data) success,
    required R Function(NetworkExceptions error) failure,
  }) {
    if (isSuccess && data != null) {
      return success(data!);
    } else if (error != null) {
      return failure(error!);
    } else {
      throw StateError('ApiResult 處於無效狀態');
    }
  }

  /// 映射資料
  ApiResult<R> map<R>(R Function(T data) transform) {
    if (isSuccess && data != null) {
      try {
        return ApiResult.success(transform(data!));
      } catch (e) {
        return ApiResult.failure(
          NetworkExceptions.defaultError('資料轉換失敗: $e'),
        );
      }
    }
    return ApiResult.failure(error ?? const NetworkExceptions.unexpectedError());
  }

  /// 異步映射資料
  Future<ApiResult<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    if (isSuccess && data != null) {
      try {
        final result = await transform(data!);
        return ApiResult.success(result);
      } catch (e) {
        return ApiResult.failure(
          NetworkExceptions.defaultError('異步資料轉換失敗: $e'),
        );
      }
    }
    return ApiResult.failure(error ?? const NetworkExceptions.unexpectedError());
  }

  /// 獲取資料或拋出異常
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw error?.toException() ?? Exception('未知錯誤');
  }

  /// 獲取資料或返回預設值
  T getDataOrElse(T defaultValue) {
    return isSuccess && data != null ? data! : defaultValue;
  }

  /// 獲取錯誤訊息
  String get errorMessage {
    return error?.errorMessage ?? '未知錯誤';
  }

  /// 檢查是否為特定錯誤類型
  bool isErrorType<E extends NetworkExceptions>() {
    return error is E;
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResult.success($data)';
    } else {
      return 'ApiResult.failure($error)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiResult<T> &&
        other.data == data &&
        other.error == error &&
        other.isSuccess == isSuccess;
  }

  @override
  int get hashCode {
    return Object.hash(data, error, isSuccess);
  }
}

/// 分頁結果封裝類
class PaginatedResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  /// 總頁數
  int get totalPages => (total / pageSize).ceil();

  /// 是否為第一頁
  bool get isFirstPage => page <= 1;

  /// 是否為最後一頁
  bool get isLastPage => !hasMore || page >= totalPages;

  /// 下一頁頁碼
  int? get nextPage => hasMore ? page + 1 : null;

  /// 上一頁頁碼
  int? get prevPage => page > 1 ? page - 1 : null;

  /// 當前頁的起始索引
  int get startIndex => (page - 1) * pageSize + 1;

  /// 當前頁的結束索引
  int get endIndex => (startIndex + items.length - 1).clamp(0, total);

  /// 複製並更新部分屬性
  PaginatedResult<T> copyWith({
    List<T>? items,
    int? total,
    int? page,
    int? pageSize,
    bool? hasMore,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// 映射項目類型
  PaginatedResult<R> map<R>(R Function(T item) transform) {
    return PaginatedResult<R>(
      items: items.map(transform).toList(),
      total: total,
      page: page,
      pageSize: pageSize,
      hasMore: hasMore,
    );
  }

  /// 過濾項目
  PaginatedResult<T> where(bool Function(T item) test) {
    final filteredItems = items.where(test).toList();
    return PaginatedResult<T>(
      items: filteredItems,
      total: filteredItems.length,
      page: page,
      pageSize: pageSize,
      hasMore: false, // 過濾後的結果不再支援分頁
    );
  }

  /// 合併另一個分頁結果（用於載入更多）
  PaginatedResult<T> merge(PaginatedResult<T> other) {
    return PaginatedResult<T>(
      items: [...items, ...other.items],
      total: other.total,
      page: other.page,
      pageSize: pageSize,
      hasMore: other.hasMore,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T item) itemToJson) {
    return {
      'items': items.map(itemToJson).toList(),
      'total': total,
      'page': page,
      'pageSize': pageSize,
      'hasMore': hasMore,
      'totalPages': totalPages,
    };
  }

  /// 從 JSON 創建
  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final itemsJson = json['items'] as List? ?? [];
    final items = itemsJson
        .cast<Map<String, dynamic>>()
        .map(itemFromJson)
        .toList();

    return PaginatedResult<T>(
      items: items,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? AppConstants.pageSize,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'PaginatedResult(items: ${items.length}, total: $total, page: $page/$totalPages, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginatedResult<T> &&
        other.items == items &&
        other.total == total &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.hasMore == hasMore;
  }

  @override
  int get hashCode {
    return Object.hash(items, total, page, pageSize, hasMore);
  }
}