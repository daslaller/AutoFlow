import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/demo_workflow.dart';
import 'package:autoflow/features/builder/canvas/autoflow_node.dart';
import 'package:autoflow/features/builder/canvas/heid_graph.dart';
import 'package:autoflow/features/builder/canvas/heid_prototypes.dart';
import 'package:autoflow/features/builder/canvas/heid_style.dart';
import 'package:autoflow/theme/anchor_theme.dart';
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **The editor canvas, photographed.** A link design that animates cannot be
/// reviewed from source, and the builder otherwise needs a browser and a
/// backend; this pumps the real `FlNodesWidget` with the demo graph and writes
/// PNGs to `build/canvas/`, one per phase of the beam.
///
/// Four mechanics in here are load-bearing, and each was learned by getting it
/// wrong first:
///
/// - **The editor is pumped 220px taller than the frame and clipped.**
///   HeidNodes draws a `DebugInfoWidget` at `bottom: 16, right: 16` under
///   `kDebugMode`, and a widget test is always debug — so the first shots came
///   back with a stack of red/green/blue readouts across the corner.
///   Overflowing the editor downwards puts them outside what is photographed
///   without touching the package.
/// - **A phase is reached by pumping, never by settling.** The beam runs on the
///   controller's repeating ticker, so `pumpAndSettle` has nothing to settle to
///   and hangs until the ten-minute timeout.
/// - **The graph is disposed inside the test body.** An effect keeps that
///   ticker running for as long as the graph has links, and the tree is
///   finalized before test-level teardowns run — deferring the dispose fails
///   the run with "disposed with an active Ticker" after every shot was
///   already written.
/// - **Fonts load in `setUpAll`, and the family is named in a
///   `DefaultTextStyle`.** Font loading is real async, so inside a
///   `testWidgets` body's fake async it never completes; and every text style
///   in the app leaves `fontFamily` null, which the test binding paints as
///   boxes.
void main() {
  const frame = Size(1500, 620);
  const debugGutter = 220.0;
  final boundary = GlobalKey();

  setUpAll(_loadFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => HeidStyle.beamColors = HeidStyle.kindBeam);

  testWidgets('links — the beam, kind palette', (tester) async {
    await _shootPass(tester, boundary, frame, debugGutter, 'links-beam');
  });

  testWidgets('links — the beam, the React defaults', (tester) async {
    HeidStyle.beamColors = HeidStyle.magicuiBeam;
    await _shootPass(tester, boundary, frame, debugGutter, 'links-magicui');
  });
}

/// Mounts the demo graph, frames it, and shoots one pass of the beam.
Future<void> _shootPass(
  WidgetTester tester,
  GlobalKey boundary,
  Size frame,
  double debugGutter,
  String prefix,
) async {
  tester.view.physicalSize = frame;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final catalog = buildDefaultCatalog();
  final session = PreviewSession();
  final graph = HeidGraph(catalog: catalog, session: session, snapToGrid: false);
  final base = buildAnchorTheme();

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(textTheme: base.textTheme.apply(fontFamily: 'Roboto')),
      home: RepaintBoundary(
        key: boundary,
        child: SizedBox(
          width: frame.width,
          height: frame.height,
          child: DefaultTextStyle(
            style: const TextStyle(fontFamily: 'Roboto', fontSize: 13),
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minHeight: frame.height + debugGutter,
                maxHeight: frame.height + debugGutter,
                child: SizedBox(
                  width: frame.width,
                  height: frame.height + debugGutter,
                  child: FlNodesWidget(
                    controller: graph.controller,
                    nodeBuilder: (node, heid) => AutoflowNodeWidget(
                      node: node,
                      controller: heid,
                      session: session,
                      showPortContextMenu: (_, __, ___, ____) {},
                      showNodeCreationMenu: (_, __, ___, ____, _____) {},
                      showNodeContextMenu: (_, __, ___, ____) {},
                    ),
                    showPortContextMenu: (_, __, ___, ____) {},
                    showCanvasContextMenu: (_, __, ___, ____) {},
                    showNodeCreationMenu: (_, __, ___, ____, _____) {},
                    showLinkContextMenu: (_, __, ___, ____) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  // NOT awaited before the first pump: `HeidGraph.mutate` ends on a real
  // `Future.delayed(Duration.zero)` and a `testWidgets` body runs in fake
  // async, so awaiting it here deadlocks the run silently.
  final loading = graph.loadDoc(createDemoWorkflow(), catalog);
  await _settle(tester);
  await loading;

  // The demo graph's own bounds, centred: nodes run x 60→1480, y 80→400.
  graph.controller.setViewportZoom(0.88, absolute: true, animate: false);
  graph.controller
      .setViewportOffset(const Offset(-770, -315), absolute: true, animate: false);
  graph.notifyLayout();
  await _settle(tester);

  // Phases are read off the controller's own clock rather than counted in
  // pumps. Two reasons: the ticker starts when the first link lands, i.e.
  // somewhere inside the framing pumps above, so no fixed offset is right;
  // and easeOutExpo is front-loaded — by a fifth of the duration the beam is
  // already three quarters across — so being a few hundred milliseconds out
  // yields three near-identical frames of a beam that has already arrived.
  await _pumpToPhase(tester, graph, 0.06);
  await _shoot(tester, boundary, '$prefix-1-leaving');
  await _pumpToPhase(tester, graph, 0.45);
  await _shoot(tester, boundary, '$prefix-2-crossing');
  await _pumpToPhase(tester, graph, 1.6);
  await _shoot(tester, boundary, '$prefix-3-arriving');

  graph.dispose();
  await tester.pumpWidget(const SizedBox.shrink());
}

/// Advances the fake clock to [phase] seconds into the beam's own pass.
Future<void> _pumpToPhase(
  WidgetTester tester,
  HeidGraph graph,
  double phase, {
  double cycle = 5.0,
}) async {
  final double now = graph.controller.activeLinksAnimationValue % cycle;
  var delta = phase - now;
  while (delta <= 0.001) {
    delta += cycle;
  }
  await tester.pump(Duration(microseconds: (delta * 1e6).round()));
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _shoot(
  WidgetTester tester,
  GlobalKey boundary,
  String name,
) async {
  // Both halves inside `runAsync`: `toImage` and `toByteData` complete on the
  // real event loop, and a `testWidgets` body runs in fake async — leaving
  // either outside deadlocks the run rather than failing it.
  await tester.runAsync(() async {
    final box =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await box.toImage();
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('build/canvas')..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

/// Roboto and the Material icon font both live in the SDK's own cache, which
/// `FLUTTER_ROOT` points at during `flutter test`.
Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return;
  final fonts = Directory('$root/bin/cache/artifacts/material_fonts');
  if (!fonts.existsSync()) return;

  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final file = File('${fonts.path}/$f');
      if (!file.existsSync()) continue;
      loader.addFont(
        file.readAsBytes().then(
              (b) => ByteData.view(Uint8List.fromList(b).buffer),
            ),
      );
    }
    await loader.load();
  }

  await load('Roboto', [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]);
  await load('MaterialIcons', ['MaterialIcons-Regular.otf']);
}
