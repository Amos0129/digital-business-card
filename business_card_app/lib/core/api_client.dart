// lib/core/api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiClient {
  static const Duration _timeout = Duration(seconds: 30);
  
  // 獲取請求標頭
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
  
  // 處理 API 回應
  static dynamic _handleResponse(http.Response response) {
    print('API Response: ${response.statusCode} - ${response.body}'); // 調試用
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return json.decode(response.body);
      } catch (e) {
        throw ApiException('回應格式錯誤', response.statusCode);
      }
    } else {
      String errorMessage = AppConstants.errorUnknown;
      
      try {
        final errorData = json.decode(response.body);
        if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
      } catch (e) {
        // 無法解析錯誤訊息，使用預設訊息
      }
      
      switch (response.statusCode) {
        case 401:
          throw ApiException(AppConstants.errorAuth, 401);
        case 404:
          throw ApiException(AppConstants.errorNotFound, 404);
        case 422:
          throw ApiException(errorMessage, 422);
        default:
          throw ApiException(errorMessage, response.statusCode);
      }
    }
  }
  
  // GET 請求
  static Future<dynamic> get(String endpoint, {bool needAuth = false}) async {
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final url = '${AppConstants.baseUrl}$endpoint';
      print('GET: $url'); // 調試用
      
      final response = await http.get(
        Uri.parse(url),
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
  
  // POST 請求
  static Future<dynamic> post(String endpoint, Map<String, dynamic> data, {bool needAuth = false}) async {
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final url = '${AppConstants.baseUrl}$endpoint';
      final body = json.encode(data);
      
      print('POST: $url'); // 調試用
      print('Body: $body'); // 調試用
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
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
  
  // PUT 請求
  static Future<dynamic> put(String endpoint, Map<String, dynamic> data, {bool needAuth = false}) async {
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final url = '${AppConstants.baseUrl}$endpoint';
      final body = json.encode(data);
      
      print('PUT: $url'); // 調試用
      print('Body: $body'); // 調試用
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
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
  
  // DELETE 請求
  static Future<dynamic> delete(String endpoint, {bool needAuth = false}) async {
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      final url = '${AppConstants.baseUrl}$endpoint';
      
      print('DELETE: $url'); // 調試用
      
      final response = await http.delete(
        Uri.parse(url),
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
  
  // 帶查詢參數的 GET 請求
  static Future<dynamic> getWithParams(String endpoint, Map<String, dynamic> params, {bool needAuth = false}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint').replace(
      queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
    );
    
    try {
      final headers = await _getHeaders(needAuth: needAuth);
      print('GET with params: $uri'); // 調試用
      
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
}

// 自定義 API 異常類
class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  ApiException(this.message, this.statusCode);
  
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}