import 'package:flutter/material.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

class AnchorProgress extends StatelessWidget {
  const AnchorProgress({super.key, required this.value});

  /// 0.0 – 1.0
  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AnchorSpacing.radiusFull),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: AnchorColors.slate100,
        color: AnchorColors.primary,
      ),
    );
  }
}
