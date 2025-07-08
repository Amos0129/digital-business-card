import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'package:business_card_app/services/user_service.dart';
import 'package:business_card_app/constants/api_routes.dart';

import '../test/mocks/mock_http_client.mocks.dart';
import '../lib/services/api_client.dart';

void main() {
  group('UserService', () {
    late MockClient mockClient;
    late UserService userService;

    setUp(() {
      mockClient = MockClient();
      userService = UserService(apiClient: ApiClient(client: mockClient));
    });

    test('login returns UserModel when successful', () async {
      const email = 'test@example.com';
      const password = '123456';
      final mockResponse = {'id': 1, 'name': 'Test User', 'email': email};

      when(
        mockClient.post(
          ApiRoutes.login(),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await userService.login(email, password);
      expect(result.name, equals('Test User'));
      expect(result.email, equals(email));
    });

    test('findByEmail returns UserModel when email found', () async {
      const email = 'test@example.com';
      final mockResponse = {'id': 1, 'name': 'Alice', 'email': email};

      when(
        mockClient.get(ApiRoutes.findByEmail(email)),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await userService.findByEmail(email);
      expect(result, isNotNull);
      expect(result?.email, equals(email));
    });

    test('existsByEmail returns true when API returns true', () async {
      const email = 'someone@example.com';

      when(
        mockClient.get(ApiRoutes.existsByEmail(email)),
      ).thenAnswer((_) async => http.Response('true', 200));

      final result = await userService.existsByEmail(email);
      expect(result, isTrue);
    });

    test('existsByEmail returns false when API returns false', () async {
      const email = 'notfound@example.com';

      when(
        mockClient.get(ApiRoutes.existsByEmail(email)),
      ).thenAnswer((_) async => http.Response('false', 200));

      final result = await userService.existsByEmail(email);
      expect(result, isFalse);
    });

    test('login throws Exception when status code is not 200', () async {
      when(
        mockClient.post(
          ApiRoutes.login(),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(() => userService.login('x', 'y'), throwsA(isA<Exception>()));
    });
  });
}
