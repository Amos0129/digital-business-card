// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _errorMessage;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  
  AuthProvider() {
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    await checkAuthStatus();
  }
  
  // 檢查登入狀態
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyJwtToken);
      
      if (token != null && token.isNotEmpty) {
        // 驗證 token 是否有效
        try {
          final response = await ApiClient.get(ApiEndpoints.me, needAuth: true);
          if (response != null) {
            _user = User.fromJson(response);
            _isLoggedIn = true;
            _errorMessage = null;
          } else {
            await _clearAuthData();
          }
        } catch (e) {
          print('Token 驗證失敗: $e');
          await _clearAuthData();
        }
      } else {
        await _clearAuthData();
      }
    } catch (e) {
      print('檢查認證狀態錯誤: $e');
      await _clearAuthData();
    }
    
    _setLoading(false);
  }
  
  // 登入
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final response = await ApiClient.post(
        ApiEndpoints.login, 
        {
          'email': email.trim(),
          'password': password,
        }
      );
      
      if (response != null) {
        _user = User.fromJson(response);
        _isLoggedIn = true;
        
        // 儲存到本地
        await _saveAuthData();
        
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      print('登入錯誤: $e');
    }
    
    _setLoading(false);
    return false;
  }
  
  // 註冊
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await ApiClient.post(
        ApiEndpoints.register,
        {
          'email': email.trim(),
          'password': password,
        }
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      print('註冊錯誤: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // 忘記密碼
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await ApiClient.post(
        ApiEndpoints.forgotPassword,
        {'email': email.trim()}
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      print('忘記密碼錯誤: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // 登出
  Future<void> logout() async {
    await _clearAuthData();
    _setLoading(false);
  }
  
  // 儲存認證資料
  Future<void> _saveAuthData() async {
    if (_user?.token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyJwtToken, _user!.token!);
      await prefs.setString(AppConstants.keyUserData, jsonEncode(_user!.toJson()));
    }
  }
  
  // 清除認證資料
  Future<void> _clearAuthData() async {
    _user = null;
    _isLoggedIn = false;
    _errorMessage = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyJwtToken);
    await prefs.remove(AppConstants.keyUserData);
  }
  
  // 設定載入狀態
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  // 清除錯誤訊息
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
  
  // 獲取錯誤訊息
  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 401:
          return '帳號或密碼錯誤';
        case 422:
          return error.message;
        case 0:
          return AppConstants.errorNetwork;
        default:
          return error.message;
      }
    }
    return AppConstants.errorUnknown;
  }
}