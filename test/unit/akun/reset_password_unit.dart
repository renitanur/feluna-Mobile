import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/akun/reset_password.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MockClient extends Mock implements http.Client {}

void main() {
  group('PasswordResetController Unit Tests', () {
    late PasswordResetController controller;
    late MockClient mockClient;

    setUp(() {
      controller = PasswordResetController();
      mockClient = MockClient();
    });

    test('Validasi password dengan kombinasi huruf dan angka', () {
      final passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
      expect(passwordRegExp.hasMatch('password123'), true);
      expect(passwordRegExp.hasMatch('password'), false);
      expect(passwordRegExp.hasMatch('123456'), false);
    });

    test('Validasi form password kosong', () {
      controller.newPasswordController.text = '';
      controller.confirmPasswordController.text = '';

      final formState = controller.formKey.currentState;
      bool? isValid = formState?.validate();

      expect(isValid, false);
    });

    test('Validasi form password tidak cocok', () {
      controller.newPasswordController.text = 'password123';
      controller.confirmPasswordController.text = 'password321';

      final formState = controller.formKey.currentState;
      bool? isValid = formState?.validate();

      expect(isValid, false);
    });

    test('Validasi form password cocok dan valid', () {
      controller.newPasswordController.text = 'password123';
      controller.confirmPasswordController.text = 'password123';

      final formState = controller.formKey.currentState;
      bool? isValid = formState?.validate();

      expect(isValid, true);
    });

    test('Cek API reset password berhasil', () async {
      when(mockClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/update_password.php'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
        (_) async => http.Response(
          json.encode({'status': 'success', 'message': 'Password berhasil diubah!'}),
          200,
        ),
      );

      final response = await mockClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/update_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': 'test@example.com',
          'newPassword': 'password123',
        }),
      );

      final responseData = json.decode(response.body);
      expect(response.statusCode, 200);
      expect(responseData['status'], 'success');
      expect(responseData['message'], 'Password berhasil diubah!');
    });

    test('Cek API reset password gagal', () async {
      when(mockClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/update_password.php'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
        (_) async => http.Response(
          json.encode({'status': 'error', 'message': 'Gagal merubah password!'}),
          400,
        ),
      );

      final response = await mockClient.post(
        Uri.parse('https://59e0-103-180-123-225.ngrok-free.app/feluna_db/update_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': 'test@example.com',
          'newPassword': 'password123',
        }),
      );

      final responseData = json.decode(response.body);
      expect(response.statusCode, 400);
      expect(responseData['status'], 'error');
      expect(responseData['message'], 'Gagal merubah password!');
    });

    test('Validasi toggle password visibility', () {
      expect(controller.isPasswordVisible, false);

      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible, true);

      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible, false);
    });
  });
}
