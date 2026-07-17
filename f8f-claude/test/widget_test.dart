import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowstock/controller/flow_controller.dart';
import 'package:flowstock/main.dart';
import 'package:flowstock/widgets/flow_builder_page.dart';

void main() {
  testWidgets('Flow builder loads with demo workflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pumpWidget(const FlowstockApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Automations'), findsOneWidget);
    expect(find.text('Ready-for-pickup notifier'), findsOneWidget);
    expect(find.text('Run Test'), findsOneWidget);
    expect(find.text('Status Changed'), findsWidgets);
    expect(find.text('TRIGGERS'), findsOneWidget);
  });

  testWidgets('Embed dialog shows Flutter snippet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pumpWidget(const FlowstockApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Embed'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Embed this builder'), findsOneWidget);
    expect(find.textContaining('FlowBuilderPage'), findsWidgets);
    expect(find.textContaining("import 'package:flowstock"), findsWidgets);
    expect(find.textContaining('@flowstock/flow'), findsNothing);
  });

  test('Edge auto-pan updates pan while node dragging near edge', () {
    final c = FlowController();
    c.setCanvasSize(const Size(800, 600));
    c.pan = Offset.zero;
    c.zoom = 1;

    final node = c.nodes.first;
    final startX = node.x;
    c.startNodeDrag(node.id, Offset(node.x + 10, node.y + 10));
    expect(c.mode, DragMode.node);

    c.onPointerMove(local: const Offset(8, 300), global: Offset.zero);
    final panBefore = c.pan;
    c.debugEdgeTick(Duration.zero);
    c.debugEdgeTick(const Duration(milliseconds: 16));
    expect(c.pan.dx, greaterThan(panBefore.dx));
    expect(c.nodes.firstWhere((n) => n.id == node.id).x, isNot(startX));

    c.onPointerUp(
      local: const Offset(8, 300),
      global: Offset.zero,
      overCanvas: true,
    );
    expect(c.mode, DragMode.none);
  });

  test('Bring to front reorders nodes', () {
    final c = FlowController();
    final firstId = c.nodes.first.id;
    c.selectNode(firstId);
    expect(c.nodes.last.id, firstId);
  });

  test('exportGraph includes nodes and wires', () {
    final c = FlowController();
    final g = c.exportGraph();
    expect(g.name, 'Ready-for-pickup notifier');
    expect(g.nodes, isNotEmpty);
    expect(g.wires, isNotEmpty);
    expect(g.toJson()['nodes'], isA<List>());
  });

  testWidgets('Canvas clips under Material side panels', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pumpWidget(const MaterialApp(home: FlowBuilderPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(Material), findsWidgets);
    expect(find.byType(FlowBuilderPage), findsOneWidget);
    expect(find.byType(ClipRect), findsWidgets);
  });
}
