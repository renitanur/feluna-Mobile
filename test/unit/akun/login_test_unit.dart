import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:feluna/akun/login.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('loginUser Unit Test', () {
    late MockHttpClient mockHttpClient;
    late LoginScreen loginScreen;

    setUp(() {
      mockHttpClient = MockHttpClient();
      loginScreen = const LoginScreen();
    });

    test('loginUser returns success response', () async {
      final username = 'testuser';
      final password = 'password123';

      // Mock HTTP response
      when(mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/login.php'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({
            'message': 'Login berhasil!',
            'username': 'testuser',
            'email': 'test@example.com',
            'user_id': 1,
          }), 200));

      final state = loginScreen.createState();
      state.usernameController.text = username;
      state.passwordController.text = password;

      await state.loginUser();

      expect(state.errorMessage, isEmpty);
    });

    test('loginUser returns error response', () async {
      final username = 'testuser';
      final password = 'wrongpassword';

      // Mock HTTP response
      when(mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/login.php'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({
            'error': 'Invalid username or password',
          }), 400));

      final state = loginScreen.createState();
      state.usernameController.text = username;
      state.passwordController.text = password;

      await state.loginUser();

      expect(state.errorMessage, isNotEmpty);
    });
  });
}
