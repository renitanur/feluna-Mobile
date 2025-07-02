import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/page/pose_painter.dart'; // Sesuaikan dengan jalur file yang benar

void main() {
  group('PosePainter', () {
    test('should repaint when landmarks change', () {
      // Test untuk memastikan repaint terjadi ketika landmarks berubah
      final painter1 = PosePainter(landmarks: [
        [0.1, 0.2],
        [0.3, 0.4],
      ]);
      final painter2 = PosePainter(landmarks: [
        [0.2, 0.3],
        [0.4, 0.5],
      ]);

      // Memastikan bahwa shouldRepaint bernilai true ketika landmarks berubah
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('should not repaint when landmarks are the same', () {
      // Test untuk memastikan tidak terjadi repaint jika landmarks tidak berubah
      final painter1 = PosePainter(landmarks: [
        [0.1, 0.2],
        [0.3, 0.4],
      ]);
      final painter2 = PosePainter(landmarks: [
        [0.1, 0.2],
        [0.3, 0.4],
      ]);

      // Memastikan bahwa shouldRepaint bernilai false jika landmarks tidak berubah
      expect(painter1.shouldRepaint(painter2), isFalse);
    });
  });
}
