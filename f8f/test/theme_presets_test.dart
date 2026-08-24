import 'package:flutter_test/flutter_test.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_theme_presets.dart';

void main() {
  tearDown(() {
    AnchorColors.active = AnchorColorsData.anchor();
  });

  test('preset table includes the shipped default id', () {
    expect(AnchorThemePresets.all.map((p) => p.id), contains('anchor'));
    expect(AnchorThemePresets.all.length, 5);
  });

  test('anchor preset matches AnchorColorsData.anchor()', () {
    final a = AnchorColorsData.anchor();
    final p = AnchorThemePresets.anchor;
    expect(p.primary, a.primary);
    expect(p.accent, a.accent);
    expect(p.sidebarBg, a.sidebarBg);
    expect(p.kindAction, a.kindAction);
    expect(p.kindTrigger, a.kindTrigger);
    expect(p.border, a.border);
    expect(p.gradientBrand.colors, a.gradientBrand.colors);
    expect(p.gradientPage.colors, a.gradientPage.colors);
  });

  test('named lookup is case-insensitive and falls back to anchor', () {
    expect(AnchorThemePresets.named('Midnight').primary,
        AnchorThemePresets.midnight.primary);
    expect(AnchorThemePresets.named('nope').primary,
        AnchorThemePresets.anchor.primary);
  });

  test('apply swaps AnchorColors.active', () {
    AnchorThemePresets.apply('workshop');
    expect(AnchorColors.primary, AnchorThemePresets.workshop.primary);
    expect(AnchorColors.kindAction, AnchorThemePresets.workshop.kindAction);
  });

  test('midnight is a dark surface; studio keeps a light sidebar', () {
    expect(AnchorThemePresets.midnight.card.computeLuminance(), lessThan(0.45));
    expect(AnchorThemePresets.studio.sidebarBg.computeLuminance(),
        greaterThan(0.5));
    expect(AnchorThemePresets.studio.sidebarFg, isNotNull);
  });

  test('each alternative is visually distinct from the default primary', () {
    // `.all` holds presets (id + label + blurb + colors); the palette itself
    // is `.colors`. This read `p.primary` and had not compiled since the
    // presets grew their metadata — so the whole file stopped loading and
    // every test in it was absent rather than failing.
    final def = AnchorThemePresets.anchor.primary;
    for (final p in AnchorThemePresets.all.skip(1)) {
      expect(p.colors.primary, isNot(def), reason: p.id);
    }
  });
}
