import 'package:feluna/page/ubah_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feluna/page/profile.dart'; // Pastikan path ini benar

// Membuat Mock dari SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('ProfilePage Tests', () {
    testWidgets('should load and display default profile data', (WidgetTester tester) async {
      // Menyiapkan SharedPreferences kosong (mock initial values)
      SharedPreferences.setMockInitialValues({});

      // Menyusun ProfilePage untuk pengujian
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      // Verifikasi apakah default data 'Guest' dan 'guest@gmail.com' ditampilkan
      expect(find.text('Guest'), findsOneWidget);
      expect(find.text('guest@gmail.com'), findsOneWidget);
    });

    testWidgets('should load and display saved profile data', (WidgetTester tester) async {
      // Mengatur nilai awal SharedPreferences
      SharedPreferences.setMockInitialValues({
        'username': 'JohnDoe',
        'email': 'johndoe@example.com',
      });

      // Menyusun ProfilePage untuk pengujian
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      // Menunggu hingga UI selesai dirender
      await tester.pumpAndSettle();

      // Verifikasi apakah data yang disimpan di SharedPreferences ditampilkan
      expect(find.text('JohnDoe'), findsOneWidget);
      expect(find.text('johndoe@example.com'), findsOneWidget);
    });

    testWidgets('should navigate to UbahProfilePage when button is pressed', (WidgetTester tester) async {
      // Menyiapkan SharedPreferences kosong (mock initial values)
      SharedPreferences.setMockInitialValues({});

      // Menyusun ProfilePage untuk pengujian
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      // Tekan tombol "Ubah Profile"
      await tester.tap(find.text('Ubah Profile'));
      await tester.pumpAndSettle();

      // Verifikasi apakah halaman UbahProfilePage dimunculkan
      expect(find.byType(UbahProfilePage), findsOneWidget);
    });
  });
}
