import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Path path = Path();

    paint.color = Color(0xFF55AE00);
    paint.style = PaintingStyle.fill;

    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.575,
        size.width * 0.5, size.height * 0.9167);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9584,
        size.width * 1.0, size.height * 0.9167);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    canvas.drawPath(path, paint);

    Path path2 = Path();
    paint.color = Colors.green;
    path2.moveTo(size.width, size.height * 0.67);
    path2.quadraticBezierTo(size.width * 0.8, size.height * 0.50,
        size.width * 0.43, size.height * 0.8);
    path2.lineTo(0, size.height);
    path2.lineTo(size.width, size.height);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}