import 'package:flutter/material.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

enum AnchorAlertVariant { info, success, warning, error }

class AnchorAlert extends StatelessWidget {
  const AnchorAlert({
    super.key,
    required this.message,
    this.variant = AnchorAlertVariant.info,
  });

  final String message;
  final AnchorAlertVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      AnchorAlertVariant.info => (AnchorColors.blue50, AnchorColors.blue700),
      AnchorAlertVariant.success => (AnchorColors.green100, AnchorColors.green700),
      AnchorAlertVariant.warning => (AnchorColors.yellow50, AnchorColors.yellow700),
      AnchorAlertVariant.error => (AnchorColors.red50, AnchorColors.red700),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AnchorSpacing.s3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 12, color: fg, height: 1.4),
      ),
    );
  }
}
