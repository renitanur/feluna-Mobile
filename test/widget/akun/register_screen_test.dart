import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:feluna/akun/register.dart';
import 'dart:convert';


class MockClient extends Mock implements http.Client {}

void main() {
  group('RegisterScreen Widget Tests', () {
    testWidgets('Tampilkan semua elemen UI di RegisterScreen',
        (WidgetTester tester) async {
      // Render widget
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      // Verifikasi elemen utama muncul
      expect(
          find.text('Halo! Daftar sekarang untuk join Feluna'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('Validasi email yang tidak valid', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      // Isi email dengan format tidak valid
      await tester.enterText(find.byType(TextField).at(1), 'invalid_email');
      await tester.tap(find.text('Register'));
      await tester.pump();

      // Periksa apakah pesan error muncul
      expect(find.text('Format email tidak valid'), findsOneWidget);
    });

    testWidgets('Validasi password yang tidak sesuai',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      // Isi password dan konfirmasi password yang tidak sesuai
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.enterText(find.byType(TextField).at(3), 'password321');
      await tester.tap(find.text('Register'));
      await tester.pump();

      // Periksa apakah pesan error muncul
      expect(find.text('Password tidak cocok'), findsOneWidget);
    });
  });

  group('RegisterScreen Unit Tests', () {
    test('Validasi email benar', () {
      final emailRegExp =
          RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
      expect(emailRegExp.hasMatch('test@example.com'), true);
      expect(emailRegExp.hasMatch('invalid_email'), false);
    });

    test('Validasi password benar', () {
      final passwordRegExp = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).{6,}$');
      expect(passwordRegExp.hasMatch('pass123'), true);
      expect(passwordRegExp.hasMatch('password'), false);
      expect(passwordRegExp.hasMatch('123456'), false);
    });

    test('Cek koneksi API registrasi', () async {
      final client = MockClient();

      when(client.post(
        Uri.parse(
            ' https://59e0-103-180-123-225.ngrok-free.app/feluna_db/register.php'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
        (_) async => http.Response(
          json.encode({'message': 'Registrasi berhasil!'}),
          200,
        ),
      );

      final response = await client.post(
        Uri.parse(
            ' https://59e0-103-180-123-225.ngrok-free.app/feluna_db/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': 'testuser',
          'email': 'test@example.com',
          'password': 'pass123',
        }),
      );

      final responseData = json.decode(response.body);
      expect(response.statusCode, 200);
      expect(responseData['message'], 'Registrasi berhasil!');
    });
  });
}
