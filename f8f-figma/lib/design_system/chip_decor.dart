import 'package:flutter/material.dart';

/// Solid/gradient icon chip — a bolder alternative to an alpha-tinted icon box.
class ChipDecor extends StatelessWidget {
  const ChipDecor({
    super.key,
    required this.color,
    required this.child,
    this.gradient,
    this.size = 32,
    this.radius = 9,
  });

  final Color color;
  final Gradient? gradient;
  final Widget child;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: color,
        gradient: gradient,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
