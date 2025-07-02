// test/widgets/pose_painter_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/widgets/pose_painter.dart'; // Ganti dengan path yang benar

void main() {
  testWidgets('PosePainter widget test', (WidgetTester tester) async {
    // Sample pose data: List of [y, x, score]
    List<List<double>> samplePose = [
      [0.1, 0.2, 0.9],  // Keypoint 0
      [0.2, 0.3, 0.8],  // Keypoint 1
      [0.3, 0.4, 0.7],  // Keypoint 2
      [0.4, 0.5, 0.6],  // Keypoint 3
      [0.5, 0.6, 0.5],  // Keypoint 4
    ];

    // Widget untuk menguji PosePainter
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CustomPaint(
          size: Size(300, 400),
          painter: PosePainter(samplePose, Size(300, 400)),
        ),
      ),
    ));

    // Verifikasi jika widget CustomPaint ada
    expect(find.byType(CustomPaint), findsOneWidget);

    // Verifikasi jika keypoints ditampilkan (misalnya dengan mencari koordinat tertentu)
    expect(find.byType(PosePainter), findsOneWidget);
  });
}
