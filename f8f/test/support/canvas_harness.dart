import 'dart:io';
import 'dart:ui' as ui;

import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/demo_workflow.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/autoflow_node.dart';
import 'package:autoflow/features/builder/canvas/heid_graph.dart';
import 'package:autoflow/features/builder/canvas/heid_prototypes.dart';
import 'package:autoflow/theme/anchor_theme.dart';
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Photographs the real editor canvas.** A link design that animates and a
/// node design that only exists on a canvas cannot be reviewed from source,
/// and the builder otherwise needs a browser and a backend. This mounts the
/// actual `FlNodesWidget` with the demo graph and writes PNGs to
/// `build/canvas/`.
///
/// Four mechanics in here are load-bearing, each learned by getting it wrong:
///
/// - **The editor is pumped [debugGutter] taller than the frame and clipped.**
///   HeidNodes draws a `DebugInfoWidget` at `bottom: 16, right: 16` under
///   `kDebugMode`, and a widget test is always debug — so the first shots came
///   back with a stack of red/green/blue readouts across the corner.
/// - **A phase is reached by pumping, never by settling.** The beam runs on a
///   repeating ticker, so `pumpAndSettle` has nothing to settle to and hangs
///   until the ten-minute timeout.
/// - **The graph is disposed inside the test body.** An effect keeps that
///   ticker running while the graph has links, and the tree is finalized
///   before test-level teardowns run — deferring the dispose fails the run
///   with "disposed with an active Ticker" after every shot was written.
/// - **Fonts load in `setUpAll`, and the family is named in a
///   `DefaultTextStyle`.** Loading is real async, so inside a `testWidgets`
///   body's fake async it never completes; and every text style in the app
///   leaves `fontFamily` null, which the test binding paints as boxes.
class CanvasHarness {
  CanvasHarness({
    this.frame = const Size(1500, 620),
    this.debugGutter = 220,
  });

  final Size frame;
  final double debugGutter;

  final GlobalKey _boundary = GlobalKey();
  late final NodeCatalog catalog;
  late final PreviewSession session;
  late final HeidGraph graph;

  /// Mounts the demo graph with [nodeBuilder] and frames it. The default
  /// builder is the app's own node chrome.
  Future<void> mount(WidgetTester tester, {NodeBuilder? nodeBuilder}) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    catalog = buildDefaultCatalog();
    session = PreviewSession();
    graph = HeidGraph(catalog: catalog, session: session, snapToGrid: false);
    final base = buildAnchorTheme();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme:
            base.copyWith(textTheme: base.textTheme.apply(fontFamily: 'Roboto')),
        home: RepaintBoundary(
          key: _boundary,
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
                      nodeBuilder: nodeBuilder ?? _defaultNodeBuilder,
                      showPortContextMenu: (_, _, _, _) {},
                      showCanvasContextMenu: (_, _, _, _) {},
                      showNodeCreationMenu: (_, _, _, _, _) {},
                      showLinkContextMenu: (_, _, _, _) {},
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
    await settle(tester);
    await loading;

    // The demo graph's own bounds, centred: nodes run x 60→1480, y 80→400.
    graph.controller.setViewportZoom(0.88, absolute: true, animate: false);
    graph.controller.setViewportOffset(
      const Offset(-770, -315),
      absolute: true,
      animate: false,
    );
    graph.notifyLayout();
    await settle(tester);
  }

  NodeBuilder get _defaultNodeBuilder => (node, heid) => AutoflowNodeWidget(
        node: node,
        controller: heid,
        session: session,
        showPortContextMenu: (_, _, _, _) {},
        showNodeCreationMenu: (_, _, _, _, _) {},
        showNodeContextMenu: (_, _, _, _) {},
      );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  /// Advances the fake clock to [phase] seconds into the beam's own pass.
  ///
  /// Phases are read off the controller's clock rather than counted in pumps:
  /// the ticker starts when the first link lands, i.e. somewhere inside the
  /// framing pumps, so no fixed offset is right — and easeOutExpo is
  /// front-loaded, so being a few hundred milliseconds out yields frame after
  /// frame of a beam that has already arrived.
  Future<void> pumpToPhase(
    WidgetTester tester,
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

  Future<void> shoot(WidgetTester tester, String name) async {
    // Both halves inside `runAsync`: `toImage` and `toByteData` complete on
    // the real event loop while a `testWidgets` body runs in fake async —
    // leaving either outside deadlocks the run rather than failing it.
    await tester.runAsync(() async {
      final box =
          _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await box.toImage();
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('build/canvas')..createSync(recursive: true);
      File('${dir.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  Future<void> teardown(WidgetTester tester) async {
    graph.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  }
}

/// Roboto and the Material icon font live in the SDK's own cache, which
/// `FLUTTER_ROOT` points at during `flutter test`.
Future<void> loadTestFonts() async {
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
