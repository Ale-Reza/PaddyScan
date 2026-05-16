import 'package:flutter/material.dart';
import 'package:paddy_scan/data/models/prediction_result.dart';

class UniversalBoxPainter extends CustomPainter {
  final List<BoundingBox> boxes;
  final double sourceW;
  final double sourceH;

  UniversalBoxPainter(
      {required this.boxes, required this.sourceW, required this.sourceH});

  @override
  void paint(Canvas canvas, Size size) {
    if (sourceW <= 0 || sourceH <= 0) return;

    // Replicate BoxFit.contain: uniform scale so the full source fits, centered.
    // For 128×128 source in a ~screenWidth×350 container:
    //   scale ≈ 350/128 = 2.734 (height is limiting axis on most phones)
    //   renderedW = renderedH ≈ 350, offsetX = (screenWidth - 350) / 2, offsetY = 0
    final double scale = (size.width / sourceW) < (size.height / sourceH)
        ? size.width / sourceW
        : size.height / sourceH;

    final double offsetX = (size.width - sourceW * scale) / 2;
    final double offsetY = (size.height - sourceH * scale) / 2;

    final paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (var box in boxes) {
      final rect = Rect.fromLTRB(
        box.x1 * scale + offsetX,
        box.y1 * scale + offsetY,
        box.x2 * scale + offsetX,
        box.y2 * scale + offsetY,
      );
      canvas.drawRect(rect, paint);

      _drawLabel(canvas, box, scale, offsetX, offsetY);
    }
  }

  void _drawLabel(
      Canvas canvas, BoundingBox box, double scale, double ox, double oy) {
    final tp = TextPainter(
      text: TextSpan(
        text: "${box.className} ${(box.confidence * 100).toInt()}%",
        style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.redAccent),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(box.x1 * scale + ox, (box.y1 * scale + oy) - 12));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
