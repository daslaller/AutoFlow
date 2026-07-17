import 'package:flutter/material.dart';

/// Anchor design-system color tokens (from design/Anchor Design System/tokens/colors.css).
abstract final class AnchorColors {
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);
  static const slate950 = Color(0xFF020617);

  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue200 = Color(0xFFBFDBFE);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const blue950 = Color(0xFF172554);

  static const purple50 = Color(0xFFFAF5FF);
  static const purple100 = Color(0xFFF3E8FF);
  static const purple500 = Color(0xFFA855F7);
  static const purple600 = Color(0xFF9333EA);
  static const purple700 = Color(0xFF7E22CE);

  static const yellow50 = Color(0xFFFEFCE8);
  static const yellow100 = Color(0xFFFEF9C3);
  static const yellow700 = Color(0xFFA16207);

  static const orange100 = Color(0xFFFFEDD5);
  static const orange500 = Color(0xFFF97316);
  static const orange700 = Color(0xFFC2410C);

  static const green100 = Color(0xFFDCFCE7);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
  static const green700 = Color(0xFF15803D);

  static const emerald100 = Color(0xFFD1FAE5);
  static const emerald600 = Color(0xFF059669);

  static const red50 = Color(0xFFFEF2F2);
  static const red100 = Color(0xFFFEE2E2);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const red700 = Color(0xFFB91C1C);

  static const white = Color(0xFFFFFFFF);

  static const background = white;
  static const foreground = slate900;
  static const card = white;
  static const cardForeground = slate900;
  static const muted = slate100;
  static const mutedForeground = slate500;
  static const border = slate200;
  static const input = slate200;
  static const ring = blue500;
  static const primary = blue600;
  static const primaryForeground = white;
  static const secondary = slate100;
  static const secondaryForeground = slate900;
  static const accent = purple600;
  static const accentForeground = white;
  static const destructive = red600;
  static const destructiveForeground = white;
  static const success = green600;
  static const warning = yellow700;

  static const sidebarBg = slate900;
  static const sidebarBorder = slate700;
  static const sidebarFgMuted = slate400;

  /// Kind accents for workflow nodes (chips/wires only — not card left borders).
  static const kindTrigger = emerald600;
  static const kindAction = blue600;
  static const kindCondition = Color(0xFFEAB308); // amber
  static const kindTransform = purple600;
  static const kindOutput = Color(0xFFF43F5E); // rose

  static const statusIdle = slate400;
  static const statusRunning = orange500;
  static const statusSuccess = emerald600;
  static const statusError = red500;

  static const LinearGradient gradientBrand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [blue600, purple700],
  );

  static const LinearGradient gradientBrandSoft = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [blue500, purple600],
  );

  static const LinearGradient gradientPage = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [slate50, blue50],
  );

  static const LinearGradient gradientTitle = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [slate900, slate700],
  );
}
