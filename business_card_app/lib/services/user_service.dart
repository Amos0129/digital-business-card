import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../constants/api_routes.dart';
import '../services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final ApiClient api;

  UserService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    if (id == null) throw Exception('使用者未登入');
    return id;
  }

  Future<UserModel?> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return null;

    final response = await http.get(
      ApiRoutes.getMe(),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      await prefs.remove('jwt_token');
      return null;
    } else {
      throw Exception('無法取得使用者資料');
    }
  }

  Future<UserModel?> findByEmail(String email) async {
    final res = await api.get(ApiRoutes.findByEmail(email));
    if (res.statusCode == 200) {
      return res.body.isEmpty ? null : UserModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('查詢失敗');
    }
  }

  Future<bool> existsByEmail(String email) async {
    final res = await api.get(ApiRoutes.existsByEmail(email));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('檢查失敗');
    }
  }

  Future<UserModel> login(String email, String password) async {
    final res = await api.post(ApiRoutes.login(), {
      'email': email,
      'password': password,
    });

    if (res.statusCode == 200) {
      final user = UserModel.fromJson(jsonDecode(res.body));

      // ✅ 登入成功時儲存 JWT token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', user.token!);

      return user;
    } else {
      throw Exception('帳號或密碼錯誤');
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    final res = await api.post(ApiRoutes.register(), {
      'name': name,
      'email': email,
      'password': password,
    });

    if (res.statusCode == 200 || res.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('註冊失敗');
    }
  }

  Future<void> updateDisplayName(String name) async {
    final res = await api.put(
      ApiRoutes.updateDisplayName(name),
      {},
      auth: true,
    );
    if (res.statusCode != 200) {
      throw Exception('更新失敗：${res.body}');
    }
  }

  Future<void> changePassword(String oldPw, String newPw) async {
    final res = await api.put(
      ApiRoutes.changePassword(oldPw, newPw),
      {},
      auth: true,
    );
    if (res.statusCode != 200) {
      throw Exception('密碼修改失敗：${res.body}');
    }
  }
}
