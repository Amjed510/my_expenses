import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'icon_painter.dart';

Future<void> generateIcons() async {
  const sizes = [48, 72, 96, 144, 192];
  
  for (final size in sizes) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    IconPainter().paint(canvas, Size(size.toDouble(), size.toDouble()));
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    final directory = Directory('assets/icon');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    
    final file = File('assets/icon/icon${size == 192 ? "" : "_$size"}.png');
    await file.writeAsBytes(buffer);
    
    if (size == 192) {
      final foregroundFile = File('assets/icon/icon_foreground.png');
      await foregroundFile.writeAsBytes(buffer);
    }
  }
}
