import 'package:feluna/page/ubah_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/page/profile.dart'; // Pastikan path ini benar

void main() {
  testWidgets('ProfilePage displays user data and updates profile', (WidgetTester tester) async {
    // Menyusun ProfilePage untuk pengujian
    await tester.pumpWidget(MaterialApp(home: ProfilePage()));

    // Memverifikasi apakah teks username dan email muncul dengan benar
    expect(find.text('Guest'), findsOneWidget); // Teks default saat data belum dimuat
    expect(find.text('guest@gmail.com'), findsOneWidget);

    // Menunggu dan mengisi data dari SharedPreferences
    await tester.pumpAndSettle();

    // Verifikasi apakah data yang benar ditampilkan
    expect(find.text('JohnDoe'), findsOneWidget);
    expect(find.text('johndoe@example.com'), findsOneWidget);

    // Mengklik tombol 'Ubah Profile'
    await tester.tap(find.text('Ubah Profile'));
    await tester.pumpAndSettle();

    // Memverifikasi bahwa setelah tombol ditekan, halaman UbahProfilePage dimunculkan
    expect(find.byType(UbahProfilePage), findsOneWidget);

    // Kembali ke ProfilePage dan periksa pembaruan
    await tester.tap(find.text('Ubah Profile'));
    await tester.pumpAndSettle();

    // Memastikan bahwa data username dan email diperbarui
    expect(find.text('UpdatedUser'), findsOneWidget);
    expect(find.text('updateduser@example.com'), findsOneWidget);
  });
}
