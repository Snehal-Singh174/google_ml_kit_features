import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:ui' as ui;

class ObjectPainter extends CustomPainter {
  final ui.Image image;
  final List<DetectedObject> objects;
  final List<Rect> rects = [];

  ObjectPainter(this.image, this.objects) {
    for (var i = 0; i < objects.length; i++) {
      rects.add(objects[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.red;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < objects.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(ObjectPainter old) {
    return image != old.image || objects != old.objects;
  }
}
