// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../core/api.dart';
import '../core/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  
  AuthProvider() {
    checkAuthStatus();
  }
  
  // 檢查登入狀態
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyJwtToken);
      
      if (token != null) {
        // 驗證 token 是否有效
        final userData = prefs.getString(AppConstants.keyUserData);
        if (userData != null) {
          _user = User.fromJson(Map<String, dynamic>.from(
            const JsonDecoder().convert(userData)
          ));
          _isLoggedIn = true;
        }
      }
    } catch (e) {
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 登入
  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiClient.post(
        ApiEndpoints.login, 
        {'email': email, 'password': password}
      );
      
      _user = User.fromJson(response);
      _isLoggedIn = true;
      
      // 儲存到本地
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyJwtToken, _user!.token!);
      await prefs.setString(AppConstants.keyUserData, 
          const JsonEncoder().convert(_user!.toJson()));
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // 註冊
  Future<bool> register(String email, String password) async {
    try {
      await ApiClient.post(
        ApiEndpoints.register,
        {'email': email, 'password': password}
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // 登出
  Future<void> logout() async {
    _user = null;
    _isLoggedIn = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyJwtToken);
    await prefs.remove(AppConstants.keyUserData);
    
    notifyListeners();
  }
}