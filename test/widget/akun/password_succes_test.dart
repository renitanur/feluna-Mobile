import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/akun/password_success.dart'; // Sesuaikan dengan path proyek Anda
import 'package:feluna/akun/login.dart';  // Pastikan LoginScreen diimpor dengan benar

void main() {
  // Unit test untuk PasswordSuccessScreen
  group('PasswordSuccessScreen', () {
    testWidgets('renders PasswordSuccessScreen correctly', (WidgetTester tester) async {
      // Build PasswordSuccessScreen
      await tester.pumpWidget(MaterialApp(
        home: PasswordSuccessScreen(),
      ));

      // Verify if the Success Text is shown
      expect(find.text('Password Berhasil!'), findsOneWidget);
      expect(find.text('Password anda telah berhasil diubah'), findsOneWidget);

      // Verify if the button text 'Kembali ke Login' is present
      expect(find.text('Kembali ke Login'), findsOneWidget);

      // Verify if the logo image is present
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('button navigates to LoginScreen on tap', (WidgetTester tester) async {
      // Create a mock LoginScreen widget
      await tester.pumpWidget(MaterialApp(
        home: PasswordSuccessScreen(),
      ));

      // Tap the "Kembali ke Login" button
      await tester.tap(find.text('Kembali ke Login'));
      await tester.pumpAndSettle();

      // Verify if the LoginScreen is pushed
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
