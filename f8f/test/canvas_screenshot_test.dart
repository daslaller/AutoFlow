import 'package:autoflow/features/builder/canvas/heid_style.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/canvas_harness.dart';

/// One pass of the beam, photographed at three points, in both palettes.
/// See [CanvasHarness] for the mechanics.
void main() {
  setUpAll(loadTestFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => HeidStyle.beamColors = HeidStyle.kindBeam);

  testWidgets('links — the beam, kind palette', (tester) async {
    await _pass(tester, 'links-beam');
  });

  testWidgets('links — the beam, the React defaults', (tester) async {
    HeidStyle.beamColors = HeidStyle.magicuiBeam;
    await _pass(tester, 'links-magicui');
  });
}

Future<void> _pass(WidgetTester tester, String prefix) async {
  final harness = CanvasHarness();
  await harness.mount(tester);

  await harness.pumpToPhase(tester, 0.06);
  await harness.shoot(tester, '$prefix-1-leaving');
  await harness.pumpToPhase(tester, 0.45);
  await harness.shoot(tester, '$prefix-2-crossing');
  await harness.pumpToPhase(tester, 1.6);
  await harness.shoot(tester, '$prefix-3-arriving');

  await harness.teardown(tester);
}
