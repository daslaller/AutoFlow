import 'package:flutter/material.dart';

/// Raw Anchor design-system palette scale (from design/Anchor Design
/// System/tokens/colors.css). These numbered shades are used directly by a
/// handful of widgets for minor accents (a badge tint, a hover background)
/// and are NOT part of the host-overridable surface — see [AnchorColorsData]
/// for the semantic tokens that are. Overriding every numbered shade to
/// match an arbitrary host palette isn't the goal here (a host palette
/// rarely has an 11-step slate/blue/green/red/yellow scale to map onto 1:1)
/// and would be a much larger, riskier sweep for comparatively little visual
/// payoff versus the semantic tokens below, which are what actually reads
/// as "this looks like Anchor" vs "this looks like Rail". Left as a
/// follow-up if a host ever needs it.
abstract final class _RawPalette {
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
}

/// The semantic Anchor tokens — the ones that actually determine whether the
/// builder reads as "Anchor" or as whatever a host reskins it to. Plain data,
/// no defaults baked into field declarations, so [AnchorColorsData.anchor]
/// is the one place the shipped default palette is defined and a host
/// palette (e.g. one built from RepairX's Rail tokens) is just another
/// instance of this same class.
class AnchorColorsData {
  const AnchorColorsData({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.muted,
    required this.mutedForeground,
    required this.border,
    required this.input,
    required this.ring,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.success,
    required this.warning,
    required this.sidebarBg,
    required this.sidebarBorder,
    required this.sidebarFgMuted,
    required this.kindTrigger,
    required this.kindAction,
    required this.kindCondition,
    required this.kindTransform,
    required this.kindOutput,
    required this.statusIdle,
    required this.statusRunning,
    required this.statusSuccess,
    required this.statusError,
    required this.gradientBrand,
    required this.gradientBrandSoft,
    required this.gradientPage,
    required this.gradientTitle,
  });

  /// The palette this package ships with — same values the original
  /// hardcoded `AnchorColors` had, now expressed as data instead of
  /// `static const`s so a host can swap the whole set.
  factory AnchorColorsData.anchor() => const AnchorColorsData(
        background: _RawPalette.white,
        foreground: _RawPalette.slate900,
        card: _RawPalette.white,
        cardForeground: _RawPalette.slate900,
        muted: _RawPalette.slate100,
        mutedForeground: _RawPalette.slate500,
        border: _RawPalette.slate200,
        input: _RawPalette.slate200,
        ring: _RawPalette.blue500,
        primary: _RawPalette.blue600,
        primaryForeground: _RawPalette.white,
        secondary: _RawPalette.slate100,
        secondaryForeground: _RawPalette.slate900,
        accent: _RawPalette.purple600,
        accentForeground: _RawPalette.white,
        destructive: _RawPalette.red600,
        destructiveForeground: _RawPalette.white,
        success: _RawPalette.green600,
        warning: _RawPalette.yellow700,
        sidebarBg: _RawPalette.white,
        sidebarBorder: _RawPalette.slate200,
        sidebarFgMuted: _RawPalette.slate400,
        kindTrigger: _RawPalette.emerald600,
        kindAction: _RawPalette.blue600,
        kindCondition: Color(0xFFEAB308),
        kindTransform: _RawPalette.purple600,
        kindOutput: Color(0xFFF43F5E),
        statusIdle: _RawPalette.slate400,
        statusRunning: _RawPalette.orange500,
        statusSuccess: _RawPalette.emerald600,
        statusError: _RawPalette.red500,
        gradientBrand: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_RawPalette.blue600, _RawPalette.purple700],
        ),
        gradientBrandSoft: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_RawPalette.blue500, _RawPalette.purple600],
        ),
        gradientPage: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_RawPalette.slate50, _RawPalette.blue50],
        ),
        gradientTitle: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_RawPalette.slate900, _RawPalette.slate700],
        ),
      );

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color muted;
  final Color mutedForeground;
  final Color border;
  final Color input;
  final Color ring;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color accent;
  final Color accentForeground;
  final Color destructive;
  final Color destructiveForeground;
  final Color success;
  final Color warning;
  final Color sidebarBg;
  final Color sidebarBorder;
  final Color sidebarFgMuted;

  /// Accent colors for the five node kinds (chips/wires only — never a
  /// card's left border, per the original design note this carries over).
  final Color kindTrigger;
  final Color kindAction;
  final Color kindCondition;
  final Color kindTransform;
  final Color kindOutput;

  final Color statusIdle;
  final Color statusRunning;
  final Color statusSuccess;
  final Color statusError;

  final LinearGradient gradientBrand;
  final LinearGradient gradientBrandSoft;
  final LinearGradient gradientPage;
  final LinearGradient gradientTitle;
}

/// Anchor design-system color tokens. Semantic members read from a
/// swappable [active] palette (default: [AnchorColorsData.anchor]) — the
/// same "static getter over a mutable active instance" shape as RepairX's
/// own `AppColors`/`Money.active`, so a host sets `AnchorColors.active =
/// AnchorColorsData(...)` once (e.g. built from its own design tokens)
/// before mounting the builder, and every existing `AnchorColors.primary`
/// call site elsewhere in this package keeps working unchanged — nothing
/// needed to migrate at the ~20 call sites this touches, since
/// `AnchorColors.primary` reads the same either way.
///
/// The raw numbered palette (`slate500`, `blue50`, ...) stays as plain
/// `static const` — see [_RawPalette]'s doc comment for why that's not part
/// of the override surface.
abstract final class AnchorColors {
  /// The palette every semantic `AnchorColors.*` getter below reads from.
  /// Swap it (e.g. `AnchorColors.active = myHostPalette`) before building
  /// any widget from this package — nothing caches the old value.
  static AnchorColorsData active = AnchorColorsData.anchor();

  static const slate50 = _RawPalette.slate50;
  static const slate100 = _RawPalette.slate100;
  static const slate200 = _RawPalette.slate200;
  static const slate300 = _RawPalette.slate300;
  static const slate400 = _RawPalette.slate400;
  static const slate500 = _RawPalette.slate500;
  static const slate600 = _RawPalette.slate600;
  static const slate700 = _RawPalette.slate700;
  static const slate800 = _RawPalette.slate800;
  static const slate900 = _RawPalette.slate900;
  static const slate950 = _RawPalette.slate950;

  static const blue50 = _RawPalette.blue50;
  static const blue100 = _RawPalette.blue100;
  static const blue200 = _RawPalette.blue200;
  static const blue400 = _RawPalette.blue400;
  static const blue500 = _RawPalette.blue500;
  static const blue600 = _RawPalette.blue600;
  static const blue700 = _RawPalette.blue700;
  static const blue950 = _RawPalette.blue950;

  static const purple50 = _RawPalette.purple50;
  static const purple100 = _RawPalette.purple100;
  static const purple500 = _RawPalette.purple500;
  static const purple600 = _RawPalette.purple600;
  static const purple700 = _RawPalette.purple700;

  static const yellow50 = _RawPalette.yellow50;
  static const yellow100 = _RawPalette.yellow100;
  static const yellow700 = _RawPalette.yellow700;

  static const orange100 = _RawPalette.orange100;
  static const orange500 = _RawPalette.orange500;
  static const orange700 = _RawPalette.orange700;

  static const green100 = _RawPalette.green100;
  static const green400 = _RawPalette.green400;
  static const green500 = _RawPalette.green500;
  static const green600 = _RawPalette.green600;
  static const green700 = _RawPalette.green700;

  static const emerald100 = _RawPalette.emerald100;
  static const emerald600 = _RawPalette.emerald600;

  static const red50 = _RawPalette.red50;
  static const red100 = _RawPalette.red100;
  static const red400 = _RawPalette.red400;
  static const red500 = _RawPalette.red500;
  static const red600 = _RawPalette.red600;
  static const red700 = _RawPalette.red700;

  static const white = _RawPalette.white;

  static Color get background => active.background;
  static Color get foreground => active.foreground;
  static Color get card => active.card;
  static Color get cardForeground => active.cardForeground;
  static Color get muted => active.muted;
  static Color get mutedForeground => active.mutedForeground;
  static Color get border => active.border;
  static Color get input => active.input;
  static Color get ring => active.ring;
  static Color get primary => active.primary;
  static Color get primaryForeground => active.primaryForeground;
  static Color get secondary => active.secondary;
  static Color get secondaryForeground => active.secondaryForeground;
  static Color get accent => active.accent;
  static Color get accentForeground => active.accentForeground;
  static Color get destructive => active.destructive;
  static Color get destructiveForeground => active.destructiveForeground;
  static Color get success => active.success;
  static Color get warning => active.warning;

  static Color get sidebarBg => active.sidebarBg;
  static Color get sidebarBorder => active.sidebarBorder;
  static Color get sidebarFgMuted => active.sidebarFgMuted;

  /// Kind accents for workflow nodes (chips/wires only — not card left borders).
  static Color get kindTrigger => active.kindTrigger;
  static Color get kindAction => active.kindAction;
  static Color get kindCondition => active.kindCondition;
  static Color get kindTransform => active.kindTransform;
  static Color get kindOutput => active.kindOutput;

  static Color get statusIdle => active.statusIdle;
  static Color get statusRunning => active.statusRunning;
  static Color get statusSuccess => active.statusSuccess;
  static Color get statusError => active.statusError;

  static LinearGradient get gradientBrand => active.gradientBrand;
  static LinearGradient get gradientBrandSoft => active.gradientBrandSoft;
  static LinearGradient get gradientPage => active.gradientPage;
  static LinearGradient get gradientTitle => active.gradientTitle;
}
