import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/akun/login.dart';  // Import LoginScreen
import 'package:feluna/akun/register.dart';  // Import RegisterScreen
import 'package:feluna/akun/welcome.dart';  // Import LoginRegisterScreen

void main() {
  group('LoginRegisterScreen Widget Tests', () {
    testWidgets('Menampilkan semua elemen UI yang diperlukan', (WidgetTester tester) async {
      // Render widget LoginRegisterScreen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginRegisterScreen(),
        ),
      );

      // Verifikasi tombol Login dan Register
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);

      // Verifikasi apakah gambar muncul
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Navigasi ke LoginScreen ketika tombol Login ditekan', (WidgetTester tester) async {
      // Render widget LoginRegisterScreen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginRegisterScreen(),
        ),
      );

      // Temukan dan tekan tombol Login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verifikasi apakah LoginScreen muncul
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Navigasi ke RegisterScreen ketika tombol Register ditekan', (WidgetTester tester) async {
      // Render widget LoginRegisterScreen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginRegisterScreen(),
        ),
      );

      // Temukan dan tekan tombol Register
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verifikasi apakah RegisterScreen muncul
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('Memeriksa apakah gambar berada di posisi yang benar', (WidgetTester tester) async {
      // Render widget LoginRegisterScreen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginRegisterScreen(),
        ),
      );

      // Verifikasi apakah gambar berada di layar
      expect(find.byType(Image), findsOneWidget);

      // Pastikan gambar menggunakan asset yang benar
      expect(find.byWidgetPredicate(
        (widget) =>
            widget is Image && widget.image == const AssetImage('assets/000.png'),
      ), findsOneWidget);
    });
  });
}
