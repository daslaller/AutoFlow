import 'package:flutter/material.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

/// White elevated surface: borderless + shadow-md (Anchor cards).
class AnchorCard extends StatelessWidget {
  const AnchorCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(AnchorSpacing.s4),
      decoration: BoxDecoration(
        color: AnchorColors.card,
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusXl),
        boxShadow: AnchorShadows.md,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusXl),
        child: content,
      ),
    );
  }
}
