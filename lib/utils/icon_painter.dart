import 'package:flutter/material.dart';

class IconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B95A9)
      ..style = PaintingStyle.fill;

    // رسم الخلفية الدائرية
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // رسم أيقونة المحفظة
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final iconSize = size.width * 0.6;
    final startX = (size.width - iconSize) / 2;
    final startY = (size.height - iconSize) / 2;

    // رسم شكل المحفظة
    path.moveTo(startX, startY + iconSize * 0.3);
    path.lineTo(startX + iconSize, startY + iconSize * 0.3);
    path.lineTo(startX + iconSize, startY + iconSize * 0.8);
    path.lineTo(startX, startY + iconSize * 0.8);
    path.close();

    // رسم الجزء العلوي من المحفظة
    path.moveTo(startX + iconSize * 0.15, startY + iconSize * 0.2);
    path.lineTo(startX + iconSize * 0.85, startY + iconSize * 0.2);
    path.lineTo(startX + iconSize * 0.85, startY + iconSize * 0.3);
    path.lineTo(startX + iconSize * 0.15, startY + iconSize * 0.3);
    path.close();

    canvas.drawPath(path, iconPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
