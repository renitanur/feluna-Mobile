// lib/widgets/pose_painter.dart

import 'package:flutter/material.dart';

class PosePainter extends CustomPainter {
  final List<List<double>> pose;
  final Size widgetSize;

  PosePainter(
    this.pose,
    this.widgetSize,
  );

  // Definisikan koneksi antar keypoints sesuai dengan model MoveNet
  final List<List<int>> connections = [
    [0, 1], // Nose to Left Eye
    [0, 2], // Nose to Right Eye
    [1, 3], // Left Eye to Left Ear
    [2, 4], // Right Eye to Right Ear
    [5, 6], // Left Shoulder to Right Shoulder
    [5, 7], // Left Shoulder to Left Elbow
    [7, 9], // Left Elbow to Left Wrist
    [6, 8], // Right Shoulder to Right Elbow
    [8, 10], // Right Elbow to Right Wrist
    [5, 11], // Left Shoulder to Left Hip
    [6, 12], // Right Shoulder to Right Hip
    [11, 12], // Left Hip to Right Hip
    [11, 13], // Left Hip to Left Knee
    [13, 15], // Left Knee to Left Ankle
    [12, 14], // Right Hip to Right Knee
    [14, 16], // Right Knee to Right Ankle
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 6.0
      ..style = PaintingStyle.fill;

    // Gambar keypoints
    for (var keypoint in pose) {
      double y = keypoint[0] * widgetSize.height;
      double x = keypoint[1] * widgetSize.width;

      // Pastikan koordinat berada dalam batas widget
      x = x.clamp(0.0, widgetSize.width);
      y = y.clamp(0.0, widgetSize.height);

      // Lewati keypoints dengan skor rendah
      double score = keypoint[2];
      if (score < 0.5) continue; // Atur threshold sesuai kebutuhan

      canvas.drawCircle(Offset(x, y), 5.0, pointPaint);
    }

    // Gambar koneksi antar keypoints
    for (var connection in connections) {
      int startIdx = connection[0];
      int endIdx = connection[1];

      if (startIdx >= pose.length || endIdx >= pose.length) continue;

      var startKeypoint = pose[startIdx];
      var endKeypoint = pose[endIdx];

      double startY = startKeypoint[0] * widgetSize.height;
      double startX = startKeypoint[1] * widgetSize.width;
      double endY = endKeypoint[0] * widgetSize.height;
      double endX = endKeypoint[1] * widgetSize.width;

      // Pastikan koordinat berada dalam batas widget
      startX = startX.clamp(0.0, widgetSize.width);
      startY = startY.clamp(0.0, widgetSize.height);
      endX = endX.clamp(0.0, widgetSize.width);
      endY = endY.clamp(0.0, widgetSize.height);

      // Lewati koneksi jika salah satu keypoint memiliki skor rendah
      if (startKeypoint[2] < 0.5 || endKeypoint[2] < 0.5) continue;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose || oldDelegate.widgetSize != widgetSize;
  }
}
