import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/page/edit_date.dart';

void main() {
  testWidgets('Test save menstruation dates', (WidgetTester tester) async {
    // Persiapkan halaman EditDatePage
    await tester.pumpWidget(
      MaterialApp(
        home: EditDatePage(),
      ),
    );

    // Pilih dua tanggal
    await tester.tap(find.text('1')); // Tap the 1st day
    await tester.tap(find.text('2')); // Tap the 2nd day
    await tester.pumpAndSettle();

    // Verifikasi jika tombol Simpan aktif
    expect(find.text('Simpan'), findsOneWidget);
    final saveButton = tester.widget<ElevatedButton>(find.text('Simpan'));
    expect(saveButton.enabled, true); // Tombol harus aktif

    // Simulasikan tap pada tombol Simpan
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Verifikasi jika data disimpan dengan benar
    // Anda dapat memeriksa SharedPreferences atau menggunakan mocking untuk mengecek
  });
}
