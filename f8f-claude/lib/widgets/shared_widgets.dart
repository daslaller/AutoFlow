import 'package:flutter/material.dart';
import 'package:flowstock/data/node_catalog.dart';
import 'package:flowstock/models/models.dart';
import 'package:flowstock/theme/flowstock_colors.dart';
import 'package:flowstock/widgets/icons/lucide_path_icon.dart';

class ChipDecor extends StatelessWidget {
  const ChipDecor({
    super.key,
    required this.category,
    required this.iconPath,
    this.size = 32,
    this.iconSize = 15,
    this.radius = 9,
  });

  final NodeCategory category;
  final String iconPath;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final style = NodeCatalog.categoryOf(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: style.color,
        gradient: style.gradient,
      ),
      alignment: Alignment.center,
      child: LucidePathIcon(
        pathData: iconPath,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 34,
    this.iconSize = 18,
    this.radius = 10,
  });

  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: FsColors.brandGradient,
        boxShadow: FsColors.shadowMd,
      ),
      alignment: Alignment.center,
      child: LucidePathIcon(
        pathData: Ic.zap,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}

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
    final stroke = mathMax(1.5, size.width * 0.166);
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

double mathMax(double a, double b) => a > b ? a : b;

class HoverButton extends StatefulWidget {
  const HoverButton({
    super.key,
    required this.onTap,
    required this.child,
    this.style,
    this.hoverStyle,
    this.tooltip,
  });

  final VoidCallback? onTap;
  final Widget child;
  final BoxDecoration? style;
  final BoxDecoration? hoverStyle;
  final String? tooltip;

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final child = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: _hover
              ? (widget.hoverStyle ?? widget.style)
              : widget.style,
          child: widget.child,
        ),
      ),
    );
    if (widget.tooltip == null) return child;
    return Tooltip(message: widget.tooltip!, child: child);
  }
}
