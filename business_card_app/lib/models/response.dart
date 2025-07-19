// 通用API回應模型
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success({
    T? data,
    String? message,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.failure({
    String? error,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'],
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'error': error,
      'statusCode': statusCode,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, message: $message, error: $error)';
  }
}

// 分頁回應模型
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List)
          .map((item) => fromJsonT(item))
          .toList(),
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 10,
      hasNext: json['hasNext'] ?? false,
      hasPrevious: json['hasPrevious'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
    };
  }
}

// 錯誤回應模型
class ErrorResponse {
  final String error;
  final String? message;
  final int? statusCode;
  final String? timestamp;
  final String? path;

  ErrorResponse({
    required this.error,
    this.message,
    this.statusCode,
    this.timestamp,
    this.path,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error'] ?? 'Unknown error',
      message: json['message'],
      statusCode: json['statusCode'],
      timestamp: json['timestamp'],
      path: json['path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'statusCode': statusCode,
      'timestamp': timestamp,
      'path': path,
    };
  }

  @override
  String toString() {
    return 'ErrorResponse(error: $error, message: $message, statusCode: $statusCode)';
  }
}

// 上傳結果模型
class UploadResult {
  final String url;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;

  UploadResult({
    required this.url,
    this.fileName,
    this.fileSize,
    this.mimeType,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      url: json['url'] ?? json['avatarUrl'] ?? '',
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      mimeType: json['mimeType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
    };
  }
}

// 操作結果模型
class OperationResult {
  final bool success;
  final String? message;
  final dynamic data;

  OperationResult({
    required this.success,
    this.message,
    this.data,
  });

  factory OperationResult.success({String? message, dynamic data}) {
    return OperationResult(
      success: true,
      message: message,
      data: data,
    );
  }

  factory OperationResult.failure({String? message}) {
    return OperationResult(
      success: false,
      message: message,
    );
  }

  @override
  String toString() {
    return 'OperationResult(success: $success, message: $message)';
  }
}

// 搜尋結果模型
class SearchResult<T> {
  final List<T> results;
  final String query;
  final int totalCount;
  final int page;
  final int pageSize;

  SearchResult({
    required this.results,
    required this.query,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory SearchResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return SearchResult<T>(
      results: (json['results'] as List? ?? [])
          .map((item) => fromJsonT(item))
          .toList(),
      query: json['query'] ?? '',
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results,
      'query': query,
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
    };
  }

  bool get hasResults => results.isNotEmpty;
  bool get isEmpty => results.isEmpty;
  int get resultCount => results.length;
}