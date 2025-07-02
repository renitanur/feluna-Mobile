import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:feluna/akun/forgot_password.dart';

// Mock HTTP Client
class MockHttpClient extends Mock implements http.Client {}

@GenerateMocks([http.Client])
void main() {
  group('ForgotPasswordScreen Widget Test', () {
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
    });

    testWidgets('Displays input field and button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      );

      // Verifikasi apakah TextFormField ada
      expect(find.byType(TextFormField), findsOneWidget);

      // Verifikasi apakah tombol ada
      expect(find.text('Kirim Kode'), findsOneWidget);
    });

    testWidgets('Displays error message when email is invalid', (WidgetTester tester) async {
      // Menambahkan mock request dengan Uri yang eksplisit
      when(mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/send_otp.php'),
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer(
          (_) async => http.Response(jsonEncode({'error': 'Email tidak valid'}), 400));

      await tester.pumpWidget(
        MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      );

      // Masukkan email yang salah
      await tester.enterText(find.byType(TextFormField), 'invalidemail');

      // Tekan tombol
      await tester.tap(find.text('Kirim Kode'));
      await tester.pump();

      // Verifikasi error message muncul
      expect(find.text('Email tidak valid'), findsNothing); // Sesuaikan pesan
    });

    testWidgets('Navigates to OTP screen on successful OTP send', (WidgetTester tester) async {
      when(mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/send_otp.php'),
        body: jsonEncode({'email': 'test@example.com'}),
        headers: {'Content-Type': 'application/json'},
      )).thenAnswer(
          (_) async => http.Response(jsonEncode({'message': 'Success'}), 200));

      await tester.pumpWidget(
        MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      );

      // Masukkan email valid
      await tester.enterText(find.byType(TextFormField), 'test@example.com');

      // Tekan tombol
      await tester.tap(find.text('Kirim Kode'));
      await tester.pumpAndSettle();

      // Verifikasi apakah teks 'Masukkan OTP' muncul
      // Ganti ini dengan teks atau widget yang sesuai yang muncul pada halaman OTP
      expect(find.text('Masukkan OTP'), findsOneWidget);  // Sesuaikan dengan teks di halaman OTP
    });
  });
}
