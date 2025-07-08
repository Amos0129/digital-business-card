import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card_request.dart';
import '../models/card_response.dart';
import '../constants/api_routes.dart';
import '../services/api_client.dart';

class CardService {
  final ApiClient api;

  CardService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<void> updateCard(int cardId, CardRequest card) async {
    final url = ApiRoutes.updateCard(cardId);
    final response = await api.put(url, card.toJson(), auth: true);

    if (response.statusCode != 200) {
      final msg = _parseError(response.body);
      throw Exception('更新失敗: $msg');
    }
  }

  Future<List<CardResponse>> getMyCards() async {
    final url = ApiRoutes.getMyCards();
    final response = await api.get(url, auth: true);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => CardResponse.fromJson(e)).toList();
    } else {
      final msg = _parseError(response.body);
      throw Exception('取得名片失敗: $msg');
    }
  }

  Future<CardResponse> getCardById(int cardId) async {
    final url = ApiRoutes.getCardById(cardId);
    final response = await api.get(url, auth: true);

    if (response.statusCode == 200) {
      return CardResponse.fromJson(jsonDecode(response.body));
    } else {
      final msg = _parseError(response.body);
      throw Exception('查詢名片失敗: $msg');
    }
  }

  Future<void> createCard(CardRequest card) async {
    final url = ApiRoutes.createCard(); // ✅ 改為無 userId
    final response = await api.post(url, card.toJson(), auth: true);

    if (response.statusCode != 200) {
      final msg = _parseError(response.body);
      throw Exception('建立名片失敗: $msg');
    }
  }

  String _parseError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded.containsKey('message')) {
        return decoded['message'];
      }
    } catch (_) {}
    return body;
  }
}
