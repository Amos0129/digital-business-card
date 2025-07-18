import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/card_request.dart';
import '../models/card_response.dart';
import '../constants/api_routes.dart';
import '../services/api_client.dart';
import '../services/local_storage_service.dart';

class CardService {
  final ApiClient api;
  bool? lastCardsFromCache;
  bool? lastFromCache;

  CardService({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  Future<List<Map<String, dynamic>>> searchPublicCards({
    required String query,
  }) async {
    final url = ApiRoutes.searchPublicCards(query);
    final response = await api.get(url, auth: false);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      final msg = _parseError(response.body);
      throw Exception('搜尋公開名片失敗: $msg');
    }
  }

  Future<void> updatePublicStatus(int cardId, bool value) async {
    final url = Uri.parse(
      '${ApiRoutes.base}/api/cards/$cardId/public?value=$value',
    );
    final response = await api.put(url, null, auth: true); // PUT with no body

    if (response.statusCode != 200) {
      final msg = _parseError(response.body);
      throw Exception('更新公開狀態失敗: $msg');
    }

    await _clearMyCardsCache();
  }

  Future<void> updateCard(int cardId, CardRequest card) async {
    final url = ApiRoutes.updateCard(cardId);
    final response = await api.put(url, card.toJson(), auth: true);

    if (response.statusCode != 200) {
      final msg = _parseError(response.body);
      throw Exception('更新失敗: $msg');
    }
    await _clearMyCardsCache();
  }

  Future<List<CardResponse>> getMyCards() async {
    const boxName = 'cardsBox';
    const key = 'myCards';

    // 👉 嘗試讀快取
    final cached = await LocalStorageService.getData(boxName, key);
    if (cached != null && cached is List) {
      try {
        final cards = (cached as List)
            .map((e) => CardResponse.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        lastCardsFromCache = true; // ✅ 來自快取
        return cards;
      } catch (_) {}
    }

    // 👉 fallback：打 API
    final url = ApiRoutes.getMyCards();
    final response = await api.get(url, auth: true);

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body);
      await LocalStorageService.saveData(boxName, key, jsonList);
      lastCardsFromCache = false; // ✅ 來自 API
      return (jsonList as List).map((e) => CardResponse.fromJson(e)).toList();
    } else {
      final msg = _parseError(response.body);
      throw Exception('取得名片失敗: $msg');
    }
  }

  Future<CardResponse> getCardById(int cardId) async {
    final boxName = 'cardsBox';
    final key = 'card_$cardId';

    final cached = await LocalStorageService.getData(boxName, key);
    if (cached != null) {
      try {
        lastFromCache = true;
        return CardResponse.fromJson(Map<String, dynamic>.from(cached));
      } catch (_) {}
    }

    // fallback：打 API
    final url = ApiRoutes.getCardById(cardId);
    final response = await api.get(url, auth: true);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      await LocalStorageService.saveData(boxName, key, json);
      lastFromCache = false;
      return CardResponse.fromJson(json);
    } else {
      final msg = _parseError(response.body);
      throw Exception('查詢名片失敗: $msg');
    }
  }

  Future<String> uploadAvatar(int cardId, XFile imageFile) async {
    final url = ApiRoutes.uploadAvatar(cardId);
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${await api.getToken()}';

    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      );
      request.files.add(multipartFile);
    } else {
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      final msg = _parseError(response.body);
      throw Exception('頭像上傳失敗: $msg');
    }
  }

  Future<void> clearAvatar(int cardId) async {
    final url = ApiRoutes.clearAvatar(cardId);
    final response = await api.patch(url, null, auth: true); // PATCH + auth

    if (response.statusCode != 200) {
      final msg = _parseError(response.body);
      throw Exception('清除頭像失敗: $msg');
    }
    await _clearMyCardsCache();
  }

  Future<void> createCard(CardRequest card) async {
    final url = ApiRoutes.createCard(); // ✅ 改為無 userId
    final response = await api.post(url, card.toJson(), auth: true);

    if (response.statusCode != 200) {
      final msg = _parseError(response.body);
      throw Exception('建立名片失敗: $msg');
    }
    await _clearMyCardsCache();
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

  Future<void> _clearMyCardsCache() async {
    const boxName = 'cardsBox';
    const key = 'myCards';
    await LocalStorageService.deleteData(boxName, key);
  }
}
