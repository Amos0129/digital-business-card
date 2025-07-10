import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, String>> _headers({bool withAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> get(Uri url, {bool auth = false}) async {
    final headers = await _headers(withAuth: auth);
    return _client.get(url, headers: headers);
  }

  Future<http.Response> post(Uri url, dynamic body, {bool auth = false}) async {
    final headers = await _headers(withAuth: auth);
    return _client.post(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> put(Uri url, dynamic body, {bool auth = false}) async {
    final headers = await _headers(withAuth: auth);
    return _client.put(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> patch(
    Uri url,
    dynamic body, {
    bool auth = false,
  }) async {
    final headers = await _headers(withAuth: auth);
    return _client.patch(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(Uri url, {bool auth = false}) async {
    final headers = await _headers(withAuth: auth);
    return _client.delete(url, headers: headers);
  }
}
