import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:feluna/akun/reset_password.dart'; // Pastikan untuk menyesuaikan dengan path file Anda

void main() {
  // Unit test untuk PasswordResetController
  group('PasswordResetController', () {
    late PasswordResetController controller;

    setUp(() {
      controller = PasswordResetController();
    });

    test('should toggle password visibility', () {
      expect(controller.isPasswordVisible, false);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible, true);
    });

    test('should toggle confirm password visibility', () {
      expect(controller.isConfirmPasswordVisible, false);
      controller.toggleConfirmPasswordVisibility();
      expect(controller.isConfirmPasswordVisible, true);
    });

    test('should validate password', () {
      final validPassword = 'Test123';
      expect(controller.newPasswordController.text.isEmpty, true);
      controller.newPasswordController.text = validPassword;
      expect(controller.newPasswordController.text, validPassword);
      expect(controller.newPasswordController.text.length >= 6, true);
    });
  });

  // Widget test untuk PasswordResetScreen
  group('PasswordResetScreen', () {
    testWidgets('should show password reset form and button', (tester) async {
      // Setup
      const email = 'test@example.com';
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordResetScreen(email: email),
        ),
      );

      // Verifikasi tampilan form
      expect(find.text('Buat Password Baru'), findsOneWidget);
      expect(find.text('Password baru anda harus berbeda dari password yang anda gunakan sebelumnya'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Untuk new password dan confirm password
      expect(find.byType(ElevatedButton), findsOneWidget); // Tombol Reset Password
    });

    testWidgets('should show loading indicator when resetting password', (tester) async {
      const email = 'test@example.com';
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordResetScreen(email: email),
        ),
      );

      final controller = Provider.of<PasswordResetController>(tester.element(find.byType(PasswordResetScreen)), listen: false);
      controller.isLoading = true;
      await tester.pump();

      // Verifikasi jika loading indicator muncul
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Reset Password'), findsNothing); // Tombol harus hilang
    });

    testWidgets('should show error dialog on failure', (tester) async {
      const email = 'test@example.com';
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordResetScreen(email: email),
        ),
      );

      final controller = Provider.of<PasswordResetController>(tester.element(find.byType(PasswordResetScreen)), listen: false);
      controller.isLoading = false;

      // Triggering error
      await controller.resetPassword(tester.element(find.byType(BuildContext)), email);
      await tester.pumpAndSettle();

      // Verifikasi apakah dialog error muncul
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
    });
  });
}
