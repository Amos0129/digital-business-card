import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../core/constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  // 初始化認證狀態
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    
    try {
      // 檢查是否有儲存的token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyJwtToken);
      
      if (token != null) {
        // 嘗試用token取得使用者資料
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _user = user;
          _clearError();
        } else {
          // Token無效，清除
          await _clearStoredAuth();
        }
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      await _clearStoredAuth();
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  // 檢查認證狀態（為了兼容 splash_screen.dart）
  Future<void> checkAuthStatus() async {
    await initialize();
  }

  // 登入
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final loginResponse = await _authService.login(email, password);
      
      // 儲存認證資訊
      await _storeAuthInfo(loginResponse.token, loginResponse);
      
      _user = User(
        id: loginResponse.id,
        email: loginResponse.email,
        name: loginResponse.name,
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 註冊
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final userResponse = await _authService.register(email, password);
      
      // 註冊成功，但不自動登入
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 忘記密碼
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.forgotPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 重設密碼
  Future<bool> resetPassword(String token, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(token, newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 更新顯示名稱
  Future<bool> updateDisplayName(String name) async {
    if (_user == null) return false;
    
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateDisplayName(name);
      
      // 更新本地使用者資料
      _user = _user!.copyWith(name: name);
      
      // 更新儲存的使用者資料
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserData, _user!.toJson().toString());
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 變更密碼
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_user == null) return false;
    
    _setLoading(true);
    _clearError();

    try {
      await _authService.changePassword(oldPassword, newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 登出
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _clearStoredAuth();
      _user = null;
      _clearError();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 刷新使用者資料
  Future<void> refreshUser() async {
    if (_user == null) return;
    
    try {
      final refreshedUser = await _authService.getCurrentUser();
      if (refreshedUser != null) {
        _user = refreshedUser;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Refresh user error: $e');
    }
  }

  // 檢查是否已認證
  bool get isAuthenticated => _user != null;

  // 取得JWT Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyJwtToken);
  }

  // 私有方法：設定載入狀態
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 私有方法：設定錯誤訊息
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // 私有方法：清除錯誤訊息
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 私有方法：儲存認證資訊
  Future<void> _storeAuthInfo(String token, LoginResponse loginResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyJwtToken, token);
    
    final userData = {
      'id': loginResponse.id,
      'email': loginResponse.email,
      'name': loginResponse.name,
    };
    await prefs.setString(AppConstants.keyUserData, userData.toString());
  }

  // 私有方法：清除儲存的認證資訊
  Future<void> _clearStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyJwtToken);
    await prefs.remove(AppConstants.keyUserData);
  }

  // 清除錯誤訊息（供UI使用）
  void clearError() {
    _clearError();
  }
}