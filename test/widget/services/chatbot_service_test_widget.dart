import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:feluna/services/chatbot_service.dart';

// Mock client dan widget
class MockClient extends Mock implements http.Client {}

void main() {
  testWidgets('should display response from chatbot service', (WidgetTester tester) async {
    // Setup mock response
    final mockClient = MockClient();
    final chatbotService = ChatbotService();
    when(mockClient.post(
      Uri.parse(chatbotService.apiUrl),
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response(jsonEncode({'response': 'Hello!'}), 200));

    // Create the widget under test
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FutureBuilder<String>(
          future: chatbotService.sendMessage('Hello'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(snapshot.data ?? 'Error');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    ));

    // Check if the result text is displayed correctly
    expect(find.text('Hello!'), findsOneWidget);
  });

  testWidgets('should display error message if chatbot fails', (WidgetTester tester) async {
    // Setup mock response for error
    final mockClient = MockClient();
    final chatbotService = ChatbotService();
    when(mockClient.post(
      Uri.parse(chatbotService.apiUrl),
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response('Error', 400));

    // Create the widget under test
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FutureBuilder<String>(
          future: chatbotService.sendMessage('Hello'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(snapshot.data ?? 'Error');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    ));

    // Check if error message is displayed
    expect(find.text('Maaf, terjadi kesalahan saat menghubungi chatbot.'), findsOneWidget);
  });
}
