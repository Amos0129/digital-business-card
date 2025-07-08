import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'package:business_card_app/services/card_group_service.dart';
import 'package:business_card_app/models/group_model.dart';
import 'package:business_card_app/models/card_group_dto.dart';
import 'package:business_card_app/constants/api_routes.dart';
import '../test/mocks/mock_http_client.mocks.dart';

void main() {
  late MockClient mockClient;
  late CardGroupService service;

  setUp(() {
    mockClient = MockClient();
    service = CardGroupService(client: mockClient);
  });

  test('getGroupsByUser returns list of GroupModel', () async {
    const userId = 1;
    final mockData = [
      {'id': 1, 'name': 'Group A'},
      {'id': 2, 'name': 'Group B'},
    ];

    final url = ApiRoutes.getGroupsByUser(userId);
    when(
      mockClient.get(url),
    ).thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

    final result = await service.getGroupsByUser(userId);
    expect(result, isA<List<GroupModel>>());
    expect(result.length, 2);
    expect(result.first.name, 'Group A');
  });

  test('getGroupOfCardForUser returns CardGroupDto', () async {
    const userId = 1;
    const cardId = 99;
    final mockData = {'cardId': 99, 'groupId': 2, 'groupName': 'VIP Clients'};

    final url = ApiRoutes.getGroupOfCard(userId, cardId);
    when(
      mockClient.get(url),
    ).thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

    final result = await service.getGroupOfCardForUser(userId, cardId);
    expect(result, isA<CardGroupDto>());
    expect(result?.groupId, 2);
  });

  test('getCardsByUser returns list of cards', () async {
    const userId = 1;
    final mockData = [
      {'id': 1, 'name': 'Card A'},
      {'id': 2, 'name': 'Card B'},
    ];

    final url = ApiRoutes.getCardsByUser(userId);
    when(
      mockClient.get(url),
    ).thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

    final result = await service.getCardsByUser(userId);
    expect(result, isA<List<Map<String, dynamic>>>());
    expect(result.length, 2);
  });

  test('getCardsByGroup returns list of cards', () async {
    const groupId = 42;
    final mockData = [
      {'id': 1, 'name': 'Card X'},
      {'id': 2, 'name': 'Card Y'},
    ];

    final url = ApiRoutes.getCardsByGroup(groupId);
    when(
      mockClient.get(url),
    ).thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

    final result = await service.getCardsByGroup(groupId);
    expect(result, isA<List<Map<String, dynamic>>>());
    expect(result.first['name'], 'Card X');
  });

  test('changeCardGroup succeeds with 200', () async {
    final url = ApiRoutes.changeCardGroup(1, 2, 3);
    when(mockClient.put(url)).thenAnswer((_) async => http.Response('', 200));

    await service.changeCardGroup(1, 2, 3);
  });

  test('addCardToGroup succeeds with 200', () async {
    final url = ApiRoutes.addCardToGroup(1, 2);
    when(mockClient.post(url)).thenAnswer((_) async => http.Response('', 200));

    await service.addCardToGroup(1, 2);
  });

  test('removeCardFromGroup succeeds with 200', () async {
    final url = ApiRoutes.removeCardFromGroup(1, 2);
    when(
      mockClient.delete(url),
    ).thenAnswer((_) async => http.Response('', 200));

    await service.removeCardFromGroup(1, 2);
  });
}
