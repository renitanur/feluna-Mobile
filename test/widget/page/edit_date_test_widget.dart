import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('HTTP request mock test', () {
    test('test mock POST request with anyNamed', () async {
      // Membuat instance mock HttpClient
      final mockHttpClient = MockHttpClient();

      // Menambahkan mock untuk HTTP POST request
      when(mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/send_otp.php'),
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer(
        (_) async => http.Response(jsonEncode({'error': 'Email tidak valid'}), 400),
      );

      // Melakukan panggilan HTTP menggunakan mock
      final response = await mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/send_otp.php'),
        body: jsonEncode({'email': 'invalid@example.com'}),
        headers: {'Content-Type': 'application/json'},
      );

      // Verifikasi jika HTTP POST request dilakukan dengan body dan headers yang sesuai
      verify(mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/send_otp.php'),
        body: anyNamed('body'), // Mock body, tidak perlu tahu nilai spesifiknya
        headers: anyNamed('headers'), // Mock headers
      )).called(1);

      // Memverifikasi response yang diterima
      expect(response.statusCode, 400);
      expect(jsonDecode(response.body)['error'], 'Email tidak valid');
    });
  });
}
