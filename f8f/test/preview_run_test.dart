import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/demo_workflow.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/run/simulation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// **The demo workflow, actually executed.**
///
/// Everything else that touches the canvas asserts about *shape* — that a
/// port exists, that an order is topological. This one runs the graph through
/// the same HeidNodes runner the editor's Preview button uses, on the same
/// prototypes the canvas paints, and asserts what came out.
///
/// It is the regression test for a class of breakage the design work made
/// possible: the styles the nodes and links are painted with are built by
/// `prototypeForType`, i.e. by the same factory that carries `onExecute`. A
/// change to the chrome that throws while building a style takes execution
/// down with it, and no other test in the suite would have noticed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the demo workflow runs end to end', () async {
    final catalog = buildDefaultCatalog();
    final doc = createDemoWorkflow();
    final statuses = <String, List<RunStatus>>{};

    final report = await SimulationEngine().run(
      nodes: doc.nodes,
      wires: doc.wires,
      input: const {'pass': true, 'ticket': {'status': 'intake'}},
      catalog: catalog,
      // The preview injects a 5% random failure so a demo looks lifelike;
      // an assertion about what ran cannot share a run with a coin flip.
      useRandomFailures: false,
      onStatus: (iid, status) => (statuses[iid] ??= []).add(status),
    );

    // ignore: avoid_print
    print('order: ${report.order}');
    for (final r in report.results) {
      // ignore: avoid_print
      print('  ${r.nodeId.padRight(4)} ${r.status.name.padRight(7)} '
          '${r.durationMs}ms  ${r.output}');
    }

    // n1 → n2 → n3 → n4, then exactly one of n4's two arms.
    expect(report.order.take(4), ['n1', 'n2', 'n3', 'n4']);
    expect(
      report.results.every((r) => r.status == RunStatus.success),
      isTrue,
      reason: report.results.map((r) => '${r.nodeId}:${r.message}').join(', '),
    );

    final taken = report.order.where((id) => id == 'n5' || id == 'n6');
    expect(taken.length, 1, reason: 'both branches ran: ${report.order}');
    expect(statuses[taken.single], contains(RunStatus.success));
  });
}
