import 'package:flutter/material.dart';

class PosePainter extends CustomPainter {
  final List<List<double>> landmarks;

  PosePainter({required this.landmarks});

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) return;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    for (var landmark in landmarks) {
      double x = landmark[0] * size.width;
      double y = landmark[1] * size.height;
      canvas.drawCircle(Offset(x, y), 4.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.landmarks != landmarks;
  }
}
