import 'package:flutter/material.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';
import 'package:autoflow/theme/anchor_typography.dart';

ThemeData buildAnchorTheme() {
  final light = AnchorColors.surfaceIsLight;
  final colorScheme = light
      ? ColorScheme.light(
          primary: AnchorColors.primary,
          onPrimary: AnchorColors.primaryForeground,
          secondary: AnchorColors.secondary,
          onSecondary: AnchorColors.secondaryForeground,
          error: AnchorColors.destructive,
          onError: AnchorColors.destructiveForeground,
          surface: AnchorColors.card,
          onSurface: AnchorColors.foreground,
          outline: AnchorColors.border,
        )
      : ColorScheme.dark(
          primary: AnchorColors.primary,
          onPrimary: AnchorColors.primaryForeground,
          secondary: AnchorColors.secondary,
          onSecondary: AnchorColors.secondaryForeground,
          error: AnchorColors.destructive,
          onError: AnchorColors.destructiveForeground,
          surface: AnchorColors.card,
          onSurface: AnchorColors.foreground,
          outline: AnchorColors.border,
        );

  return ThemeData(
    useMaterial3: true,
    brightness: light ? Brightness.light : Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: AnchorTypography.textTheme,
    fontFamily: null,
    appBarTheme: AppBarTheme(
      backgroundColor: AnchorColors.card,
      foregroundColor: AnchorColors.foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: AnchorColors.card,
      elevation: 0,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusXl),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AnchorColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
        borderSide: BorderSide(color: AnchorColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
        borderSide: BorderSide(color: AnchorColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
        borderSide: BorderSide(color: AnchorColors.ring, width: 2),
      ),
      hintStyle: AnchorTypography.textTheme.bodySmall?.copyWith(
        color: AnchorColors.slate400,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AnchorColors.primary,
        foregroundColor: AnchorColors.primaryForeground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AnchorColors.foreground,
        side: BorderSide(color: AnchorColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AnchorColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AnchorColors.border,
      thickness: 1,
      space: 1,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AnchorColors.slate900,
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusMd),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      waitDuration: const Duration(milliseconds: 400),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AnchorColors.primary,
      linearTrackColor: AnchorColors.slate100,
    ),
  );
}
