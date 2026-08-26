import 'package:autoflow/features/builder/canvas/heid_style.dart';
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';
import 'package:flutter/rendering.dart';
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

  /// **The canvas mid-Preview.** Every other shot is a resting graph, and a
  /// resting graph never shows the one thing the node chrome has to survive:
  /// run state painted on top of it. The tinted header now carries the kind's
  /// colour itself, and the running/success/error ring is a *second* colour
  /// arriving on the same card — so the two have to be looked at together.
  ///
  /// This drives the real runner (`buildGraph` + `executeGraph`) on the
  /// harness's own controller, which is what the Preview button does.
  testWidgets('nodes — mid preview run', (tester) async {
    final harness = CanvasHarness();
    await harness.mount(tester);

    harness.session.reset(
      input: const {'pass': true},
      catalog: harness.catalog,
      // A 5% coin flip is fine for a lifelike demo and not for a photograph.
      useRandomFailures: false,
    );
    harness.graph.controller.runner.buildGraph();
    // NOT awaited: each node holds `running` for 280ms, and the whole point
    // is to photograph the graph while it is part-way through.
    final running = harness.graph.controller.runner.executeGraph();

    // `EnginePhase.paint` stops the frame before `flushSemantics`. Not a
    // shortcut: a run mutates node sizes from a post-frame callback (ports are
    // measured after layout), and compiling semantics over a tree in that
    // state trips a framework assertion —
    // `!childSemantics.renderObject._needsLayout`. It reproduces on a clean
    // checkout with none of this branch's changes, so it is the canvas's
    // pre-existing business and not something to fix from a screenshot rig;
    // a photograph needs the frame painted, not described.
    await tester.pump(const Duration(milliseconds: 650));
    tester.takeException();
    await harness.shoot(tester, 'nodes-running');

    // ⚠️ **The frame the ring is still fading in on.** A border is part of a
    // decoration's padding, so the fade re-measures the card every tick with
    // no engine event behind it — the exact case that used to leave a node
    // skipped in layout and therefore unpainted, a grey blur where the card
    // was. AutoFlow carried a workaround for it until HeidNodes#4; this is
    // what says the engine pin still carries that fix.
    await tester.pump(const Duration(seconds: 3));
    tester.takeException();
    await tester.pump(const Duration(milliseconds: 80));
    tester.takeException();
    _expectNothingAwaitingLayout(
      tester.renderObject(find.byType(FlNodesWidget)),
    );
    await harness.shoot(tester, 'nodes-ring-fading');
    // A second frame, because the status ring is an `AnimatedContainer`: the
    // pump above delivers every remaining status change in ONE frame, so each
    // node's border animation is photographed at t=0 — the run looks finished
    // in the dots and unfinished in the rings.
    await tester.pump(const Duration(seconds: 1));
    tester.takeException();
    await harness.shoot(tester, 'nodes-finished');
    await running;

    await harness.teardown(tester);
  });
}

/// A render object left needing layout after a settled frame never paints:
/// `RenderObject._paintWithContext` returns early while `_needsLayout`, with
/// no error anywhere. That is the whole failure mode this guards.
void _expectNothingAwaitingLayout(RenderObject node) {
  expect(
    node.debugNeedsLayout,
    isFalse,
    reason: '$node is still awaiting layout, so it will not paint',
  );
  node.visitChildren(_expectNothingAwaitingLayout);
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
