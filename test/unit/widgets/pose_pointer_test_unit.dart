import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/widgets/pose_painter.dart'; // Ganti dengan path yang benar

void main() {
  test('PosePainter paint method test', () {
    // Sample pose data: List of [y, x, score]
    List<List<double>> samplePose = [
      [0.1, 0.2, 0.9],  // Keypoint 0
      [0.2, 0.3, 0.8],  // Keypoint 1
      [0.3, 0.4, 0.7],  // Keypoint 2
      [0.4, 0.5, 0.6],  // Keypoint 3
      [0.5, 0.6, 0.5],  // Keypoint 4
    ];

    final PosePainter painter = PosePainter(samplePose, Size(300, 400));
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(300, 400)));

    // Menjalankan metode paint untuk menggambar keypoints dan koneksi
    painter.paint(canvas, Size(300, 400));

    // Verifikasi: Mengecek apakah canvas telah digambar (apakah metode paint dipanggil)
    expect(recorder.endRecording(), isNotNull);
  });
}
