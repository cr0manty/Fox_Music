import 'package:flutter/material.dart';

class ArcPainter extends CustomPainter {
  final double progress;
  ArcPainter({this.progress = 0.0});

  double _setRadius() {
    return progress * 6.25 ;
  }

  @override
  bool shouldRepaint(ArcPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 10.0, 23, 23);
    Path path = Path()..arcTo(rect, -1.55, _setRadius(), true);

    canvas.drawArc(
        rect,
        0.0,
        100,
        false,
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke);
    canvas.drawPath(
        path,
        Paint()
          ..color = Color.fromRGBO(193, 39, 45, 1)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke);
  }
}
