// lib/services/auth_service.dart
import '../models/user.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class AuthService {
  // 登入
  Future<LoginResponse> login(String email, String password) async {
    final data = LoginRequest(
      email: email,
      password: password,
    ).toJson();

    final response = await ApiClient.post(ApiEndpoints.login, data);
    return LoginResponse.fromJson(response);
  }

  // 註冊
  Future<User> register(String email, String password) async {
    final data = RegisterRequest(
      email: email,
      password: password,
    ).toJson();

    final response = await ApiClient.post(ApiEndpoints.register, data);
    return User.fromJson(response);
  }

  // 取得目前使用者資訊
  Future<User?> getCurrentUser() async {
    try {
      final response = await ApiClient.get(ApiEndpoints.me, needAuth: true);
      return User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 忘記密碼
  Future<void> forgotPassword(String email) async {
    final data = ForgotPasswordRequest(email: email).toJson();
    await ApiClient.post(ApiEndpoints.forgotPassword, data);
  }

  // 重設密碼
  Future<void> resetPassword(String token, String newPassword) async {
    final data = ResetPasswordRequest(
      token: token,
      newPassword: newPassword,
    ).toJson();
    await ApiClient.post(ApiEndpoints.resetPassword, data);
  }

  // 更新顯示名稱
  Future<void> updateDisplayName(String name) async {
    final data = {'name': name};
    await ApiClient.put(ApiEndpoints.updateDisplayName, data, needAuth: true);
  }

  // 變更密碼
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final data = {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
    await ApiClient.put(ApiEndpoints.changePassword, data, needAuth: true);
  }
}