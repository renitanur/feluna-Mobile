// lib/services/chatbot_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  final String apiUrl = 'https://feluna.my.id/groq-chatbot';

  Future<String> sendMessage(String pertanyaan) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'pertanyaan': pertanyaan}), // Ubah key menjadi 'pertanyaan'
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['jawaban']; // Ubah key menjadi 'jawaban'
      } else {
        print('Error: ${response.statusCode}');
        print('Response Body: ${response.body}'); // Tambahkan logging respons
        return 'Maaf, terjadi kesalahan saat menghubungi chatbot.';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Maaf, terjadi kesalahan saat mengirim pesan.';
    }
  }
}
