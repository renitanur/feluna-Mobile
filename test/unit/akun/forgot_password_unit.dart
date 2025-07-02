import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:feluna/akun/forgot_password.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('sendOtpToEmail Unit Test', () {
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
    });

    test('sendOtpToEmail returns success response', () async {
      final email = 'test@example.com';

      // Mock HTTP response
      when(mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/send_otp.php'),
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'message': 'Success'}), 200));

      final forgotPasswordScreen = ForgotPasswordScreen();

      // Mengatur emailController.text menggunakan getter
      forgotPasswordScreen.emailControllerGetter.text = email;

      // Memanggil sendOtpToEmail()
      await forgotPasswordScreen.sendOtpToEmail();

      // Verifikasi bahwa errorMessage tidak ada (berhasil)
      expect(forgotPasswordScreen.errorMessage, isNull);
    });

    test('sendOtpToEmail returns error response', () async {
      final email = 'test@example.com';

      // Mock HTTP response dengan error
      when(mockHttpClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/send_otp.php'),
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'error': 'Invalid email'}), 400));

      final forgotPasswordScreen = ForgotPasswordScreen();

      // Mengatur emailController.text menggunakan getter
      forgotPasswordScreen.emailControllerGetter.text = email;

      // Memanggil sendOtpToEmail()
      await forgotPasswordScreen.sendOtpToEmail();

      // Verifikasi bahwa errorMessage ada (gagal)
      expect(forgotPasswordScreen.errorMessage, isNotNull);
    });
  });
}
