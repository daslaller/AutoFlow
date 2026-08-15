import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/heid_graph.dart';
import 'package:autoflow/features/builder/canvas/heid_prototypes.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('if-else true and false are distinct HeidNodes control outputs', () {
    final catalog = buildDefaultCatalog();
    final session = PreviewSession();
    final graph = HeidGraph(
      catalog: catalog,
      session: session,
      snapToGrid: false,
    );
    addTearDown(graph.dispose);
    final proto = graph.controller.nodePrototypes['if-else']!;
    final ids = proto.portPrototypes.map((p) => p.idName).toSet();
    expect(ids, containsAll({'true', 'false', 'in'}));
  });

  test('dragging wires both if-else outputs independently', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(workflowProvider.notifier);

    for (var i = 0; i < 40 && !container.read(workflowProvider).ready; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    final cat = buildDefaultCatalog();
    await ctrl.replaceWorkflow(
      WorkflowDoc(
        name: 'branch',
        nodes: [
          CanvasNode(iid: 'branch', def: cat.find('if-else')!.asDef, x: 0, y: 0),
          CanvasNode(
            iid: 'onTrue',
            def: cat.find('send_message')!.asDef,
            x: 240,
            y: 0,
          ),
          CanvasNode(
            iid: 'onFalse',
            def: cat.find('notify')!.asDef,
            x: 240,
            y: 120,
          ),
        ],
        wires: const [],
      ),
    );

    ctrl.graph.controller.addLink('branch', 'true', 'onTrue', 'in');
    ctrl.graph.controller.addLink('branch', 'false', 'onFalse', 'in');
    await Future<void>.delayed(Duration.zero);

    final wires = container.read(workflowProvider).doc.wires;
    expect(
      wires.where((w) => w.fromPort == 'true' && w.to == 'onTrue'),
      hasLength(1),
    );
    expect(
      wires.where((w) => w.fromPort == 'false' && w.to == 'onFalse'),
      hasLength(1),
    );
  });

  test('HeidGraph load/export keeps instance ids and wire ids', () async {
    final catalog = buildDefaultCatalog();
    final session = PreviewSession();
    final graph = HeidGraph(
      catalog: catalog,
      session: session,
      snapToGrid: false,
    );
    addTearDown(graph.dispose);

    final doc = WorkflowDoc(
      name: 'roundtrip',
      nodes: [
        CanvasNode(
          iid: 'n_trigger',
          def: catalog.find('message.received')!.asDef,
          x: 40,
          y: 80,
        ),
        CanvasNode(
          iid: 'n_branch',
          def: catalog.find('if-else')!.asDef,
          x: 280,
          y: 80,
          config: const {'condition': '{{ok}} == true'},
        ),
      ],
      wires: const [
        Wire(
          id: 'wire_keep',
          from: 'n_trigger',
          fromPort: 'out',
          to: 'n_branch',
          toPort: 'in',
        ),
      ],
    );

    await graph.loadDoc(doc, catalog);
    final exported = graph.exportDoc(doc, catalog);

    expect(exported.nodes.map((n) => n.iid).toSet(), {'n_trigger', 'n_branch'});
    expect(exported.wires, hasLength(1));
    expect(exported.wires.single.id, 'wire_keep');
    expect(exported.wires.single.from, 'n_trigger');
    expect(exported.wires.single.fromPort, 'out');
    expect(exported.wires.single.to, 'n_branch');
    expect(exported.wires.single.toPort, 'in');
    expect(exported.nodes.firstWhere((n) => n.iid == 'n_trigger').x, 40);
    expect(
      exported.nodes.firstWhere((n) => n.iid == 'n_branch').config['condition'],
      '{{ok}} == true',
    );
  });
}
