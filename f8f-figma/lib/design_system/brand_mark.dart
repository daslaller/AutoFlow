import 'package:flutter/material.dart';
import 'package:autoflow/design_system/icons/lucide_icons.dart';
import 'package:autoflow/design_system/icons/lucide_path_icon.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

/// The AutoFlow brand mark: gradient box with a bolt glyph.
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
        gradient: AnchorColors.gradientBrand,
        boxShadow: AnchorShadows.md,
      ),
      alignment: Alignment.center,
      child: LucidePathIcon(
        pathData: LucideIcons.zap,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}
