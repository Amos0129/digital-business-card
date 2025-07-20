// lib/presentation/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../core/network/response_handler.dart';

/// 認證狀態提供者
/// 
/// 管理使用者認證狀態和相關操作
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // 狀態變數
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// 初始化認證狀態
  Future<void> initAuth() async {
    _setLoading(true);
    
    try {
      _isLoggedIn = await _authRepository.isLoggedIn();
      
      if (_isLoggedIn) {
        await getCurrentUser();
      }
    } catch (e) {
      _setError('初始化失敗: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 使用者登入
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final request = UserLoginRequest(email: email, password: password);
      final result = await _authRepository.login(request);

      return result.when(
        success: (loginResponse) async {
          _currentUser = UserModel(
            id: loginResponse.id,
            email: loginResponse.email,
            name: loginResponse.name,
          );
          _isLoggedIn = true;
          _setLoading(false);
          notifyListeners();
          return true;
        },
        failure: (error) {
          _setError(error.message);
          return false;
        },
      );
    } catch (e) {
      _setError('登入失敗: ${e.toString()}');
      return false;
    }
  }

  /// 使用者註冊
  Future<bool> register(String email, String password, {String? name}) async {
    _setLoading(true);
    _clearError();

    try {
      final request = UserRegisterRequest(
        email: email,
        password: password,
        name: name,
      );
      final result = await _authRepository.register(request);

      return result.when(
        success: (user) {
          _setLoading(false);
          // 註冊成功後，可以選擇自動登入或導向登入頁
          return true;
        },
        failure: (error) {
          _setError(error.message);
          return false;
        },
      );
    } catch (e) {
      _setError('註冊失敗: ${e.toString()}');
      return false;
    }
  }

  /// 忘記密碼
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final request = ForgotPasswordRequest(email: email);
      final result = await _authRepository.forgotPassword(request);

      return result.when(
        success: (_) {
          _setLoading(false);
          return true;
        },
        failure: (error) {
          _setError(error.message);
          return false;
        },
      );
    } catch (e) {
      _setError('發送重設信件失敗: ${e.toString()}');
      return false;
    }
  }

  /// 重設密碼
  Future<bool> resetPassword(String token, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      final request = ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
      );
      final result = await _authRepository.resetPassword(request);

      return result.when(
        success: (_) {
          _setLoading(false);
          return true;
        },
        failure: (error) {
          _setError(error.message);
          return false;
        },
      );
    } catch (e) {
      _setError('重設密碼失敗: ${e.toString()}');
      return false;
    }
  }

  /// 獲取當前使用者資訊
  Future<void> getCurrentUser() async {
    try {
      final result = await _authRepository.getCurrentUser();
      
      result.when(
        success: (user) {
          _currentUser = user;
          notifyListeners();
        },
        failure: (error) {
          _setError(error.message);
        },
      );
    } catch (e) {
      _setError('獲取使用者資訊失敗: ${e.toString()}');
    }
  }

  /// 更新使用者顯示名稱
  Future<bool> updateDisplayName(String name) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authRepository.updateDisplayName(name);

      return result.when(
        success: (_) {
          if (_currentUser != null) {
            _currentUser = _currentUser!.updateName(name);
            notifyListeners();
          }
          _setLoading(false);
          return true;
        },
        failure: (error) {
          _setError(error.message);
          return false;
        },
      );
    } catch (e) {
      _setError('更新姓名失敗: ${e.toString()}');
      return false;
    }
  }

  /// 修改密碼
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      final request = ChangePasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      final result = await _authRepository.changePassword(request);

      return result.when(
        success: (_) {
          _setLoading(false);
          return true;
        },
        failure: (error) {
          _setError(error.message);
          return false;
        },
      );
    } catch (e) {
      _setError('修改密碼失敗: ${e.toString()}');
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authRepository.logout();
      _currentUser = null;
      _isLoggedIn = false;
      _clearError();
    } catch (e) {
      _setError('登出失敗: ${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// 清除錯誤訊息
  void clearError() {
    _clearError();
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}