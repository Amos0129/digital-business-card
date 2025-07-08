import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:business_card_app/services/group_service.dart';
import 'package:business_card_app/models/group_model.dart';
import 'package:business_card_app/constants/api_routes.dart';

void main() {
  group('GroupService', () {
    test('getGroupsByUser returns group list on success', () async {
      final mockClient = MockClient((request) async {
        // 驗證路徑正確
        expect(request.url, ApiRoutes.getGroupsByUser(1));

        // 模擬 JSON 回傳
        return http.Response(
          jsonEncode([
            {'id': 1, 'name': '業務'},
            {'id': 2, 'name': '工程'},
          ]),
          200,
        );
      });

      // 暫時改寫 GroupService，使用 mockClient
      final service = _TestableGroupService(mockClient);

      final groups = await service.getGroupsByUser(1);
      expect(groups.length, 2);
      expect(groups[0].name, '業務');
      expect(groups[1].name, '工程');
    });

    test('getGroupsByUser throws exception on failure', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = _TestableGroupService(mockClient);

      expect(() => service.getGroupsByUser(1), throwsException);
    });
  });
}

/// 提供一個可以注入 client 的 GroupService
class _TestableGroupService extends GroupService {
  final http.Client _client;
  _TestableGroupService(this._client);

  @override
  Future<List<GroupModel>> getGroupsByUser(int userId) {
    final uri = ApiRoutes.getGroupsByUser(userId);
    return _client.get(uri).then((response) {
      if (response.statusCode != 200) {
        throw Exception('讀取群組失敗: ${response.body}');
      }
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => GroupModel.fromJson(json)).toList();
    });
  }
}
