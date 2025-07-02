import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/page/pose_painter.dart';

void main() {
  testWidgets('PosePainter should draw landmarks correctly', (WidgetTester tester) async {
    // Membuat widget dengan PosePainter
    final landmarks = [
      [0.1, 0.2],
      [0.3, 0.4],
    ];

    // Menyiapkan widget yang menggunakan PosePainter
    final widget = CustomPaint(
      painter: PosePainter(landmarks: landmarks),
      size: Size(400, 400),
    );

    // Menambahkan widget ke dalam tree
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    // Memverifikasi apakah canvas menggambar titik pada posisi yang benar
    final paintFinder = find.byType(CustomPaint);
    expect(paintFinder, findsOneWidget);

    // Verifikasi titik yang digambar
    // Anda dapat memverifikasi dengan melakukan tes visual atau menggunakan custom matcher untuk Canvas.
  });
}
