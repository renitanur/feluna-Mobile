import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/akun/password_success.dart'; // Ganti dengan path sesuai project Anda
import 'package:feluna/akun/login.dart'; // Import LoginScreen untuk navigasi

void main() {
  testWidgets('PasswordSuccessScreen displays correct content', (WidgetTester tester) async {
    // Build the PasswordSuccessScreen widget
    await tester.pumpWidget(
      MaterialApp(
        home: PasswordSuccessScreen(),
      ),
    );

    // Verify if the screen displays the correct text
    expect(find.text('Password Berhasil!'), findsOneWidget);
    expect(find.text('Password anda telah berhasil diubah'), findsOneWidget);

    // Verify if the button text is correct
    expect(find.text('Kembali ke Login'), findsOneWidget);

    // Verify if the image is present
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Navigates to LoginScreen when button is pressed', (WidgetTester tester) async {
    // Build the PasswordSuccessScreen widget with a mock navigator
    await tester.pumpWidget(
      MaterialApp(
        home: PasswordSuccessScreen(),
        routes: {
          '/login': (context) => const LoginScreen(), // Define the LoginScreen route
        },
      ),
    );

    // Find the 'Kembali ke Login' button and tap on it
    final loginButton = find.text('Kembali ke Login');
    await tester.tap(loginButton);

    // Pump the widget tree to allow navigation to occur
    await tester.pumpAndSettle();

    // Verify if the LoginScreen is displayed after navigation
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
