import 'package:flutter/material.dart';

/// A thin custom-painted loading ring — an alternative to
/// [CircularProgressIndicator] with a lighter, more precise track.
class SpinningRing extends StatefulWidget {
  const SpinningRing({
    super.key,
    this.size = 12,
    this.color = Colors.white,
    this.trackAlpha = 0.4,
  });

  final double size;
  final Color color;
  final double trackAlpha;

  @override
  State<SpinningRing> createState() => _SpinningRingState();
}

class _SpinningRingState extends State<SpinningRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _c,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _RingPainter(
            color: widget.color,
            trackAlpha: widget.trackAlpha,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.color, required this.trackAlpha});

  final Color color;
  final double trackAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = (size.width * 0.166).clamp(1.5, double.infinity);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    paint.color = color.withValues(alpha: trackAlpha);
    canvas.drawCircle(
      size.center(Offset.zero),
      (size.width - stroke) / 2,
      paint,
    );
    paint.color = color;
    canvas.drawArc(
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: (size.width - stroke) / 2,
      ),
      -1.5708,
      1.8,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.trackAlpha != trackAlpha;
}
