// lib/services/auth_service.dart
import '../models/user.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

// 登入請求模型
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// 登入回應模型
class LoginResponse {
  final User user;
  final String token;

  LoginResponse({
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: User.fromJson(json['user'] ?? json),
      token: json['token'] ?? json['accessToken'] ?? '',
    );
  }
}

// 註冊請求模型
class RegisterRequest {
  final String email;
  final String password;

  RegisterRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// 忘記密碼請求模型
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

// 重設密碼請求模型
class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'newPassword': newPassword,
    };
  }
}

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