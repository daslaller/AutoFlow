import 'dart:math';

import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/heid_graph.dart';
import 'package:autoflow/features/builder/canvas/heid_prototypes.dart';
import 'package:autoflow/features/run/expression_evaluator.dart';

typedef CodePreviewFn = Future<Map<String, dynamic>> Function(
  CanvasNode node,
  Map<String, dynamic> ctx,
);

/// Headless Preview runner. The live editor uses the same HeidNodes
/// controller as the canvas; this class builds a throwaway [HeidGraph]
/// for tests and host `startPreview` calls that only have a WorkflowDoc.
class SimulationEngine {
  SimulationEngine({Random? random, ExpressionEvaluator? evaluator})
      : _random = random ?? Random(),
        _eval = evaluator ?? ExpressionEvaluator();

  final Random _random;
  final ExpressionEvaluator _eval;

  /// A naive topological order over [nodes]/[wires] ignoring branch
  /// semantics entirely (a node downstream of *either* side of an if-else
  /// appears once, in dependency order). This is intentionally simpler than
  /// [run]'s real branch-aware execution — it's a rough "what depends on
  /// what" ordering for callers that don't care which branch would
  /// actually be taken (e.g. a static list/minimap view), not a preview of
  /// what a real run does.
  List<String> executionOrder(List<CanvasNode> nodes, List<Wire> wires) {
    final inbound = <String, int>{for (final n in nodes) n.iid: 0};
    for (final w in wires) {
      inbound[w.to] = (inbound[w.to] ?? 0) + 1;
    }

    final queue =
        nodes.where((n) => (inbound[n.iid] ?? 0) == 0).map((n) => n.iid).toList();
    final seen = <String>{};
    final order = <String>[];

    while (queue.isNotEmpty) {
      final id = queue.removeAt(0);
      if (seen.contains(id)) continue;
      seen.add(id);
      order.add(id);
      for (final w in wires.where((w) => w.from == id)) {
        queue.add(w.to);
      }
    }

    for (final n in nodes) {
      if (!seen.contains(n.iid)) order.add(n.iid);
    }
    return order;
  }

  Future<RunReport> run({
    required List<CanvasNode> nodes,
    required List<Wire> wires,
    required Map<String, dynamic> input,
    required void Function(String iid, RunStatus status) onStatus,
    void Function(PreviewEvent event)? onEvent,
    CodePreviewFn? codePreview,
    NodeCatalog? catalog,
    bool Function()? shouldCancel,
    bool useRandomFailures = true,
  }) async {
    if (catalog == null) {
      throw ArgumentError('catalog is required so HeidNodes can register ports');
    }

    final session = PreviewSession(random: _random, evaluator: _eval);
    final graph = HeidGraph(
      catalog: catalog,
      session: session,
      snapToGrid: false,
    );
    try {
      session.reset(
        input: input,
        catalog: catalog,
        codePreview: codePreview,
        shouldCancel: shouldCancel,
        onStatus: onStatus,
        onEvent: onEvent,
        useRandomFailures: useRandomFailures,
      );
      await graph.loadDoc(
        WorkflowDoc(name: 'preview', nodes: nodes, wires: wires),
        catalog,
      );
      for (final n in nodes) {
        onStatus(n.iid, RunStatus.idle);
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
      graph.controller.runner.buildGraph();
      await graph.controller.runner.executeGraph();
      return RunReport(
        order: List.of(session.order),
        results: List.of(session.results),
        input: input,
        finishedAt: DateTime.now().toUtc(),
      );
    } finally {
      graph.dispose();
    }
  }
}
