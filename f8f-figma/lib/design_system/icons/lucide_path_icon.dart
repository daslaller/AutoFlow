import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

/// Renders Lucide-style SVG path data with stroke (matching the HTML icons).
class LucidePathIcon extends StatelessWidget {
  const LucidePathIcon({
    super.key,
    required this.pathData,
    this.size = 14,
    this.color = Colors.white,
    this.strokeWidth = 2,
    this.filled = false,
  });

  final String pathData;
  final double size;
  final Color color;
  final double strokeWidth;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _LucidePainter(
        pathData: pathData,
        color: color,
        strokeWidth: strokeWidth,
        filled: filled,
      ),
    );
  }
}

class _LucidePainter extends CustomPainter {
  _LucidePainter({
    required this.pathData,
    required this.color,
    required this.strokeWidth,
    required this.filled,
  });

  final String pathData;
  final Color color;
  final double strokeWidth;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final path = parseSvgPathData(pathData);
    final bounds = path.getBounds();
    if (bounds.isEmpty) return;

    // Lucide icons are designed in a 24x24 viewBox.
    const vb = 24.0;
    final scale = size.width / vb;
    canvas
      ..save()
      ..scale(scale);

    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LucidePainter oldDelegate) =>
      oldDelegate.pathData != pathData ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.filled != filled;
}
