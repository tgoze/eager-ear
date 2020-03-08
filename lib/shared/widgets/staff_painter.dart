import 'package:flutter/material.dart';

class StaffPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    paint.color = Color(0xFF376996);
    paint.strokeWidth = 5;

    int spaces = 8;
    int lines = 5;
    double spacing = size.height / spaces;

    double startY =  2 * spacing;

    for(int i = 0; i < lines; i++) {
      canvas.drawLine(
        Offset(0, startY + (spacing * i)),
        Offset(size.width, startY + (spacing * i)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}