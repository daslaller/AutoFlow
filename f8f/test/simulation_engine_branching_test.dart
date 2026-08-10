// Proves the actual defect this HeidNodes-backed rewrite of SimulationEngine
// fixes: before, an if-else node's preview animated BOTH the true and false
// branches as "running" — the naive topological walk had no concept of
// "only the taken branch happens". This test builds a small if/else graph
// and asserts only the taken branch's action node ever runs, in both
// directions, matching what a real automation execution must do.
import 'package:flutter_test/flutter_test.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/run/simulation_engine.dart';

NodeCatalog _catalog() {
  const inPort = [PortDef(id: 'in', label: 'In')];
  const outPort = [PortDef(id: 'out', label: 'Out')];
  const branchOut = [PortDef(id: 'true', label: 'True'), PortDef(id: 'false', label: 'False')];

  return const NodeCatalog(
    version: '1',
    types: [
      NodeTypeDef(
        id: 'trigger',
        kind: NodeKind.trigger,
        label: 'Trigger',
        sublabel: '',
        inputs: [],
        outputs: outPort,
      ),
      NodeTypeDef(
        id: 'if-else',
        kind: NodeKind.condition,
        label: 'If / Else',
        sublabel: '',
        inputs: inPort,
        outputs: branchOut,
        fields: [FieldDef(key: 'condition', label: 'Condition', type: FieldType.text)],
      ),
      NodeTypeDef(
        id: 'action',
        kind: NodeKind.action,
        label: 'Action',
        sublabel: '',
        inputs: inPort,
        outputs: outPort,
      ),
    ],
  );
}

({List<CanvasNode> nodes, List<Wire> wires}) _branchingGraph(NodeCatalog catalog) {
  final trigger = CanvasNode(iid: 'trigger', def: catalog.find('trigger')!.asDef, x: 0, y: 0);
  final branch = CanvasNode(
    iid: 'branch',
    def: catalog.find('if-else')!.asDef,
    x: 0,
    y: 0,
    config: const {'condition': '{{pass}} == true'},
  );
  final onTrue = CanvasNode(iid: 'onTrue', def: catalog.find('action')!.asDef, x: 0, y: 0);
  final onFalse = CanvasNode(iid: 'onFalse', def: catalog.find('action')!.asDef, x: 0, y: 0);

  return (
    nodes: [trigger, branch, onTrue, onFalse],
    wires: const [
      Wire(id: 'w1', from: 'trigger', to: 'branch', fromPort: 'out', toPort: 'in'),
      Wire(id: 'w2', from: 'branch', to: 'onTrue', fromPort: 'true', toPort: 'in'),
      Wire(id: 'w3', from: 'branch', to: 'onFalse', fromPort: 'false', toPort: 'in'),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('only the true branch runs when the condition holds', () async {
    final catalog = _catalog();
    final graph = _branchingGraph(catalog);
    final statuses = <String, List<RunStatus>>{};

    await SimulationEngine().run(
      nodes: graph.nodes,
      wires: graph.wires,
      input: const {'pass': true},
      catalog: catalog,
      useRandomFailures: false,
      onStatus: (iid, status) => (statuses[iid] ??= []).add(status),
    );

    expect(statuses['onTrue'], contains(RunStatus.success));
    // onFalse only ever receives the initial idle reset — never running or
    // success/error — because its branch was never taken.
    expect(statuses['onFalse'], [RunStatus.idle]);
  });

  test('only the false branch runs when the condition fails', () async {
    final catalog = _catalog();
    final graph = _branchingGraph(catalog);
    final statuses = <String, List<RunStatus>>{};

    await SimulationEngine().run(
      nodes: graph.nodes,
      wires: graph.wires,
      input: const {'pass': false},
      catalog: catalog,
      useRandomFailures: false,
      onStatus: (iid, status) => (statuses[iid] ??= []).add(status),
    );

    expect(statuses['onFalse'], contains(RunStatus.success));
    expect(statuses['onTrue'], [RunStatus.idle]);
  });

  test('run report only contains a result for the taken branch action', () async {
    final catalog = _catalog();
    final graph = _branchingGraph(catalog);

    final report = await SimulationEngine().run(
      nodes: graph.nodes,
      wires: graph.wires,
      input: const {'pass': true},
      catalog: catalog,
      useRandomFailures: false,
      onStatus: (_, _) {},
    );

    final actionResults = report.results.where((r) => r.nodeId == 'onTrue' || r.nodeId == 'onFalse');
    expect(actionResults.length, 1);
    expect(actionResults.single.nodeId, 'onTrue');
  });
}
