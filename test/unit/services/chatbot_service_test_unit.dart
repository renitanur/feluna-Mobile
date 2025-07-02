import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:feluna/services/chatbot_service.dart';

// Membuat mock dari class http.Client
class MockClient extends Mock implements http.Client {}

void main() {
  group('ChatbotService', () {
    late ChatbotService chatbotService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      chatbotService = ChatbotService();
    });

    test('should return response when the HTTP call is successful', () async {
      // Mengatur mock response
      when(mockClient.post(
        Uri.parse(chatbotService.apiUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'response': 'Hello!'}), 200));

      final result = await chatbotService.sendMessage('Hello');

      expect(result, 'Hello!');
    });

    test('should return error message when HTTP response is not 200', () async {
      // Mengatur mock response dengan status selain 200
      when(mockClient.post(
        Uri.parse(chatbotService.apiUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      final result = await chatbotService.sendMessage('Hello');

      expect(result, 'Maaf, terjadi kesalahan saat menghubungi chatbot.');
    });

    test('should return error message when an exception occurs', () async {
      // Mengatur mock response untuk exception
      when(mockClient.post(
        Uri.parse(chatbotService.apiUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(Exception('Network error'));

      final result = await chatbotService.sendMessage('Hello');

      expect(result, 'Maaf, terjadi kesalahan saat mengirim pesan.');
    });
  });
}
