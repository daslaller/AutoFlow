import 'package:flutter/material.dart';
import 'package:autoflow/theme/anchor_colors.dart';

/// A named, shippable default look for the builder — distinct from a host
/// palette (RepairX Rail, etc.) which is assembled ad hoc from the host's
/// own tokens. These are alternatives for F8F's *own* default skin.
class AnchorThemePreset {
  const AnchorThemePreset({
    required this.id,
    required this.label,
    required this.blurb,
    required this.colors,
  });

  final String id;
  final String label;
  final String blurb;
  final AnchorColorsData colors;
}

/// Shipped default-look alternatives. [anchor] is what the package uses
/// unless a host (or the demo `?theme=` query) swaps [AnchorColors.active].
abstract final class AnchorThemePresets {
  static const anchorId = 'anchor';

  static const all = <AnchorThemePreset>[
    AnchorThemePreset(
      id: anchorId,
      label: 'Anchor',
      blurb: 'Shipped default — light slate canvas, blue→purple brand, dark node rail.',
      colors: _anchor,
    ),
    AnchorThemePreset(
      id: 'midnight',
      label: 'Midnight',
      blurb: 'Dark canvas editor — sky primary, violet accent, n8n-like density.',
      colors: _midnight,
    ),
    AnchorThemePreset(
      id: 'workshop',
      label: 'Workshop',
      blurb: 'Warm paper and copper — a shop-floor read for RepairX-shaped work.',
      colors: _workshop,
    ),
    AnchorThemePreset(
      id: 'harbor',
      label: 'Harbor',
      blurb: 'Teal / navy nautical — calmer than the blue-purple default.',
      colors: _harbor,
    ),
    AnchorThemePreset(
      id: 'studio',
      label: 'Studio',
      blurb: 'Ink and zinc, light sidebar — one accent, Linear-like restraint.',
      colors: _studio,
    ),
  ];

  static AnchorColorsData get anchor => _anchor;
  static AnchorColorsData get midnight => _midnight;
  static AnchorColorsData get workshop => _workshop;
  static AnchorColorsData get harbor => _harbor;
  static AnchorColorsData get studio => _studio;

  static AnchorThemePreset byId(String id) {
    final key = id.trim().toLowerCase();
    for (final p in all) {
      if (p.id == key) return p;
    }
    return all.first;
  }

  static AnchorColorsData named(String id) => byId(id).colors;

  static void apply(String id) {
    AnchorColors.active = named(id);
  }
}

/// Same values as [AnchorColorsData.anchor] — kept as a const here so the
/// preset table can be const without calling a factory.
const _anchor = AnchorColorsData(
  background: Color(0xFFFFFFFF),
  foreground: Color(0xFF0F172A),
  card: Color(0xFFFFFFFF),
  cardForeground: Color(0xFF0F172A),
  muted: Color(0xFFF1F5F9),
  mutedForeground: Color(0xFF64748B),
  border: Color(0xFFE2E8F0),
  input: Color(0xFFE2E8F0),
  ring: Color(0xFF3B82F6),
  primary: Color(0xFF2563EB),
  primaryForeground: Color(0xFFFFFFFF),
  secondary: Color(0xFFF1F5F9),
  secondaryForeground: Color(0xFF0F172A),
  accent: Color(0xFF9333EA),
  accentForeground: Color(0xFFFFFFFF),
  destructive: Color(0xFFDC2626),
  destructiveForeground: Color(0xFFFFFFFF),
  success: Color(0xFF16A34A),
  warning: Color(0xFFA16207),
  sidebarBg: Color(0xFF0F172A),
  sidebarBorder: Color(0xFF334155),
  sidebarFgMuted: Color(0xFF94A3B8),
  kindTrigger: Color(0xFF059669),
  kindAction: Color(0xFF2563EB),
  kindCondition: Color(0xFFEAB308),
  kindTransform: Color(0xFF9333EA),
  kindOutput: Color(0xFFF43F5E),
  statusIdle: Color(0xFF94A3B8),
  statusRunning: Color(0xFFF97316),
  statusSuccess: Color(0xFF059669),
  statusError: Color(0xFFEF4444),
  gradientBrand: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2563EB), Color(0xFF7E22CE)],
  ),
  gradientBrandSoft: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
  ),
  gradientPage: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
  ),
  gradientTitle: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0F172A), Color(0xFF334155)],
  ),
);

const _midnight = AnchorColorsData(
  background: Color(0xFF0B1220),
  foreground: Color(0xFFE8EEF7),
  card: Color(0xFF141C2C),
  cardForeground: Color(0xFFE8EEF7),
  muted: Color(0xFF1C2740),
  mutedForeground: Color(0xFF8B9BB4),
  border: Color(0xFF243049),
  input: Color(0xFF243049),
  ring: Color(0xFF38BDF8),
  primary: Color(0xFF38BDF8),
  primaryForeground: Color(0xFF082F49),
  secondary: Color(0xFF1C2740),
  secondaryForeground: Color(0xFFE8EEF7),
  accent: Color(0xFFA78BFA),
  accentForeground: Color(0xFF1E1B4B),
  destructive: Color(0xFFF87171),
  destructiveForeground: Color(0xFF450A0A),
  success: Color(0xFF34D399),
  warning: Color(0xFFFBBF24),
  sidebarBg: Color(0xFF080D18),
  sidebarBorder: Color(0xFF1E2A40),
  sidebarFgMuted: Color(0xFF7C8CA8),
  sidebarFg: Color(0xFFD7E3F4),
  sidebarInputBg: Color(0xFF121A2C),
  kindTrigger: Color(0xFF34D399),
  kindAction: Color(0xFF38BDF8),
  kindCondition: Color(0xFFFBBF24),
  kindTransform: Color(0xFFA78BFA),
  kindOutput: Color(0xFFFB7185),
  statusIdle: Color(0xFF64748B),
  statusRunning: Color(0xFFFB923C),
  statusSuccess: Color(0xFF34D399),
  statusError: Color(0xFFF87171),
  gradientBrand: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF38BDF8), Color(0xFFA78BFA)],
  ),
  gradientBrandSoft: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0EA5E9), Color(0xFF8B5CF6)],
  ),
  gradientPage: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF070B14), Color(0xFF102038)],
  ),
  gradientTitle: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE8EEF7), Color(0xFF8B9BB4)],
  ),
);

const _workshop = AnchorColorsData(
  background: Color(0xFFFBF7F2),
  foreground: Color(0xFF1C1410),
  card: Color(0xFFFFFCF8),
  cardForeground: Color(0xFF1C1410),
  muted: Color(0xFFF3E9DC),
  mutedForeground: Color(0xFF8A7464),
  border: Color(0xFFE6D5C3),
  input: Color(0xFFE6D5C3),
  ring: Color(0xFFEA580C),
  primary: Color(0xFFC2410C),
  primaryForeground: Color(0xFFFFF7ED),
  secondary: Color(0xFFF3E9DC),
  secondaryForeground: Color(0xFF1C1410),
  accent: Color(0xFFB45309),
  accentForeground: Color(0xFFFFFBEB),
  destructive: Color(0xFFB91C1C),
  destructiveForeground: Color(0xFFFFFFFF),
  success: Color(0xFF15803D),
  warning: Color(0xFFB45309),
  sidebarBg: Color(0xFF1F1612),
  sidebarBorder: Color(0xFF3F2E24),
  sidebarFgMuted: Color(0xFFB8A090),
  sidebarFg: Color(0xFFF3E9DC),
  sidebarInputBg: Color(0xFF2C211A),
  kindTrigger: Color(0xFF059669),
  kindAction: Color(0xFFC2410C),
  kindCondition: Color(0xFFD97706),
  kindTransform: Color(0xFF7C3AED),
  kindOutput: Color(0xFFBE123C),
  statusIdle: Color(0xFFA78B77),
  statusRunning: Color(0xFFEA580C),
  statusSuccess: Color(0xFF059669),
  statusError: Color(0xFFDC2626),
  gradientBrand: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFEA580C), Color(0xFFB45309)],
  ),
  gradientBrandSoft: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF97316), Color(0xFFD97706)],
  ),
  gradientPage: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBF7F2), Color(0xFFF7EDE0)],
  ),
  gradientTitle: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF1C1410), Color(0xFF6B4F3F)],
  ),
);

const _harbor = AnchorColorsData(
  background: Color(0xFFF7FBFC),
  foreground: Color(0xFF0B1F2A),
  card: Color(0xFFFFFFFF),
  cardForeground: Color(0xFF0B1F2A),
  muted: Color(0xFFE7F1F4),
  mutedForeground: Color(0xFF5B7480),
  border: Color(0xFFC5D8DF),
  input: Color(0xFFC5D8DF),
  ring: Color(0xFF0D9488),
  primary: Color(0xFF0F766E),
  primaryForeground: Color(0xFFF0FDFA),
  secondary: Color(0xFFE7F1F4),
  secondaryForeground: Color(0xFF0B1F2A),
  accent: Color(0xFF0369A1),
  accentForeground: Color(0xFFF0F9FF),
  destructive: Color(0xFFBE123C),
  destructiveForeground: Color(0xFFFFFFFF),
  success: Color(0xFF0F766E),
  warning: Color(0xFFA16207),
  sidebarBg: Color(0xFF0B1F2A),
  sidebarBorder: Color(0xFF1E3A4C),
  sidebarFgMuted: Color(0xFF7FA3B2),
  sidebarFg: Color(0xFFD7EBF1),
  sidebarInputBg: Color(0xFF122A38),
  kindTrigger: Color(0xFF0D9488),
  kindAction: Color(0xFF0284C7),
  kindCondition: Color(0xFFCA8A04),
  kindTransform: Color(0xFF4F46E5),
  kindOutput: Color(0xFFE11D48),
  statusIdle: Color(0xFF7FA3B2),
  statusRunning: Color(0xFFEA580C),
  statusSuccess: Color(0xFF0D9488),
  statusError: Color(0xFFE11D48),
  gradientBrand: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0D9488), Color(0xFF0369A1)],
  ),
  gradientBrandSoft: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF14B8A6), Color(0xFF0284C7)],
  ),
  gradientPage: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF4FAFB), Color(0xFFE8F4F6)],
  ),
  gradientTitle: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0B1F2A), Color(0xFF1E3A4C)],
  ),
);

const _studio = AnchorColorsData(
  background: Color(0xFFFAFAFA),
  foreground: Color(0xFF18181B),
  card: Color(0xFFFFFFFF),
  cardForeground: Color(0xFF18181B),
  muted: Color(0xFFF4F4F5),
  mutedForeground: Color(0xFF71717A),
  border: Color(0xFFE4E4E7),
  input: Color(0xFFE4E4E7),
  ring: Color(0xFF7C3AED),
  primary: Color(0xFF18181B),
  primaryForeground: Color(0xFFFAFAFA),
  secondary: Color(0xFFF4F4F5),
  secondaryForeground: Color(0xFF18181B),
  accent: Color(0xFF7C3AED),
  accentForeground: Color(0xFFFFFFFF),
  destructive: Color(0xFFDC2626),
  destructiveForeground: Color(0xFFFFFFFF),
  success: Color(0xFF16A34A),
  warning: Color(0xFFA16207),
  sidebarBg: Color(0xFFFFFFFF),
  sidebarBorder: Color(0xFFE4E4E7),
  sidebarFgMuted: Color(0xFF71717A),
  sidebarFg: Color(0xFF18181B),
  sidebarInputBg: Color(0xFFF4F4F5),
  kindTrigger: Color(0xFF16A34A),
  kindAction: Color(0xFF18181B),
  kindCondition: Color(0xFFCA8A04),
  kindTransform: Color(0xFF7C3AED),
  kindOutput: Color(0xFFE11D48),
  statusIdle: Color(0xFFA1A1AA),
  statusRunning: Color(0xFFF97316),
  statusSuccess: Color(0xFF16A34A),
  statusError: Color(0xFFEF4444),
  gradientBrand: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF18181B), Color(0xFF3F3F46)],
  ),
  gradientBrandSoft: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF27272A), Color(0xFF7C3AED)],
  ),
  gradientPage: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF4F4F5)],
  ),
  gradientTitle: LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF18181B), Color(0xFF52525B)],
  ),
);
