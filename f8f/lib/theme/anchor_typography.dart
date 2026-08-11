import 'package:flutter/material.dart';
import 'package:autoflow/theme/anchor_colors.dart';

/// Anchor type scale (OS UI sans + mono for IDs/config).
abstract final class AnchorTypography {
  static const String fontSans = '.SF Pro Text, Segoe UI, Roboto, Helvetica Neue, Arial, sans-serif';
  static const String fontMono = 'SF Mono, Menlo, Monaco, Consolas, Liberation Mono, monospace';

  static TextTheme get textTheme => TextTheme(
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: AnchorColors.foreground,
      letterSpacing: -0.5,
    ),
    headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: AnchorColors.foreground,
      letterSpacing: -0.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: AnchorColors.foreground,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: AnchorColors.foreground,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AnchorColors.foreground,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AnchorColors.foreground,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AnchorColors.foreground,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AnchorColors.foreground,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AnchorColors.mutedForeground,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AnchorColors.foreground,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: AnchorColors.foreground,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.8,
      color: AnchorColors.mutedForeground,
    ),
  );

  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AnchorColors.slate600,
  );

  static TextStyle get monoSmall => const TextStyle(
        fontFamily: 'monospace',
        fontSize: 10,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.5,
      ).copyWith(color: AnchorColors.mutedForeground);
}
