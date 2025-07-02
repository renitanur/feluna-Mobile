import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http_client;
import 'package:feluna/services/chatbot_service.dart';

class MockHttpClient extends Mock implements http_client.Client {}

void main() {
  group('ChatbotService', () {
    late MockHttpClient mockHttpClient;
    late ChatbotService chatbotService;

    setUp(() {
      mockHttpClient = MockHttpClient();
      chatbotService = ChatbotService(); // Inisialisasi ChatbotService dengan mockHttpClient jika perlu
    });

    test('should handle error when response is 400', () async {
      // Simulasi response HTTP 400 dengan body error JSON
      when(mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/send_otp.php'),
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer(
        (_) async => http.Response(jsonEncode({'error': 'Email tidak valid'}), 400)
      );

      final result = await chatbotService.sendMessage('test message');

      // Verifikasi bahwa error yang sesuai dikembalikan
      expect(result, 'Maaf, terjadi kesalahan saat mengirim pesan.');
    });
  });
}
