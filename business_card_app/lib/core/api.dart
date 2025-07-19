import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiClient {
  static const Duration _timeout = Duration(seconds: 30);
  
  // 取得請求headers
  static Future<Map<String, String>> _getHeaders({bool needAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (needAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyJwtToken);
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // 處理API回應
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      String errorMessage = AppConstants.errorUnknown;
      
      try {
        final errorData = json.decode(response.body);
        if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        }
      } catch (e) {
        // 如果無法解析錯誤訊息，使用預設訊息
      }
      
      switch (response.statusCode) {
        case 401:
          throw ApiException(AppConstants.errorAuth, 401);
        case 404:
          throw ApiException(AppConstants.errorNotFound, 404);
        default:
          throw ApiException(errorMessage, response.statusCode);
      }
    }
  }
  
  // GET請求
  static Future<dynamic> get(String endpoint, {bool needAuth = false}) async {
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: headers,
      ).timeout(_timeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } on http.ClientException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(AppConstants.errorUnknown, 0);
    }
  }
  
  // POST請求
  static Future<dynamic> post(String endpoint, Map<String, dynamic> data, {bool needAuth = false}) async {
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: headers,
        body: json.encode(data),
      ).timeout(_timeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } on http.ClientException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(AppConstants.errorUnknown, 0);
    }
  }
  
  // PUT請求
  static Future<dynamic> put(String endpoint, Map<String, dynamic> data, {bool needAuth = false}) async {
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: headers,
        body: json.encode(data),
      ).timeout(_timeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } on http.ClientException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(AppConstants.errorUnknown, 0);
    }
  }
  
  // DELETE請求
  static Future<dynamic> delete(String endpoint, {bool needAuth = false}) async {
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: headers,
      ).timeout(_timeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } on http.ClientException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(AppConstants.errorUnknown, 0);
    }
  }
  
  // 帶查詢參數的GET請求
  static Future<dynamic> getWithParams(String endpoint, Map<String, dynamic> params, {bool needAuth = false}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint').replace(
      queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
    );
    
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final response = await http.get(uri, headers: headers).timeout(_timeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } on http.ClientException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(AppConstants.errorUnknown, 0);
    }
  }

  // 帶參數的POST請求
  static Future<dynamic> postWithParams(String endpoint, Map<String, dynamic> params, {bool needAuth = false}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint').replace(
      queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
    );
    
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final response = await http.post(uri, headers: headers).timeout(_timeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } on http.ClientException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(AppConstants.errorUnknown, 0);
    }
  }

  // 帶參數的PUT請求
  static Future<dynamic> putWithParams(String endpoint, Map<String, dynamic> params, {bool needAuth = false}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint').replace(
      queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
    );
    
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final response = await http.put(uri, headers: headers).timeout(_timeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } on http.ClientException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(AppConstants.errorUnknown, 0);
    }
  }

  // 帶參數的PATCH請求
  static Future<dynamic> patchWithParams(String endpoint, Map<String, dynamic> params, {bool needAuth = false}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint').replace(
      queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
    );
    
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final response = await http.patch(uri, headers: headers).timeout(_timeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } on http.ClientException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(AppConstants.errorUnknown, 0);
    }
  }

  // 帶參數的DELETE請求
  static Future<dynamic> deleteWithParams(String endpoint, Map<String, dynamic> params, {bool needAuth = false}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint').replace(
      queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
    );
    
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final response = await http.delete(uri, headers: headers).timeout(_timeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } on http.ClientException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(AppConstants.errorUnknown, 0);
    }
  }
  
  // 檔案上傳
  static Future<dynamic> uploadFile(String endpoint, File file, {bool needAuth = false}) async {
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      headers.remove('Content-Type'); // multipart/form-data會自動設定
      
      final request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}$endpoint'));
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } on http.ClientException {
      throw ApiException(AppConstants.errorNetwork, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(AppConstants.errorUnknown, 0);
    }
  }
}

// 自定義API異常類
class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  ApiException(this.message, this.statusCode);
  
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}