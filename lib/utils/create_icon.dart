import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Future<void> createIcon() async {
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  const size = Size(192.0, 192.0);

  // رسم الخلفية
  final paint = Paint()
    ..color = const Color(0xFF3B95A9)
    ..style = PaintingStyle.fill;

  canvas.drawCircle(
    Offset(size.width / 2, size.height / 2),
    size.width / 2,
    paint,
  );

  // رسم أيقونة المحفظة باللون الأبيض
  final iconPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill
    ..strokeWidth = 8;

  const iconSize = 120.0;
  const startX = (192 - iconSize) / 2;
  const startY = (192 - iconSize) / 2;

  final path = Path();
  
  // رسم الجسم الرئيسي للمحفظة
  path.moveTo(startX, startY + 40);
  path.lineTo(startX + iconSize, startY + 40);
  path.lineTo(startX + iconSize, startY + iconSize - 20);
  path.lineTo(startX, startY + iconSize - 20);
  path.close();

  // رسم الجزء العلوي
  path.moveTo(startX + 20, startY + 20);
  path.lineTo(startX + iconSize - 20, startY + 20);
  path.lineTo(startX + iconSize - 20, startY + 40);
  path.lineTo(startX + 20, startY + 40);
  path.close();

  canvas.drawPath(path, iconPaint);

  // تحويل الرسم إلى صورة
  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(192, 192);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // حفظ الصورة
  final iconFile = File('assets/icon/icon.png');
  await iconFile.writeAsBytes(buffer);
  
  // نسخ نفس الصورة كـ foreground
  final foregroundFile = File('assets/icon/icon_foreground.png');
  await foregroundFile.writeAsBytes(buffer);
}
