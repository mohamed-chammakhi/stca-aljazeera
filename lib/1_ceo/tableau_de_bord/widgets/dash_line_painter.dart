import 'package:flutter/material.dart';

/// Draws a solid or dashed horizontal line — used in the sales chart legend.
class DashLinePainter extends CustomPainter {
  final Color color;
  final bool dashed;

  const DashLinePainter({required this.color, this.dashed = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + 5).clamp(0, size.width), size.height / 2),
        paint,
      );
      x += 8;
    }
  }

  @override
  bool shouldRepaint(DashLinePainter old) =>
      old.color != color || old.dashed != dashed;
}
