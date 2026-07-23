import 'dart:math';

import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/run/expression_evaluator.dart';

typedef CodePreviewFn = Future<Map<String, dynamic>> Function(
  CanvasNode node,
  Map<String, dynamic> ctx,
);

/// Client-side preview/simulation with optional expression evaluation.
class SimulationEngine {
  SimulationEngine({Random? random, ExpressionEvaluator? evaluator})
      : _random = random ?? Random(),
        _eval = evaluator ?? ExpressionEvaluator();

  final Random _random;
  final ExpressionEvaluator _eval;

  List<String> executionOrder(List<CanvasNode> nodes, List<Wire> wires) {
    final inbound = <String, int>{for (final n in nodes) n.iid: 0};
    for (final w in wires) {
      inbound[w.to] = (inbound[w.to] ?? 0) + 1;
    }

    final queue = nodes
        .where((n) => (inbound[n.iid] ?? 0) == 0)
        .map((n) => n.iid)
        .toList();
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
    for (final n in nodes) {
      onStatus(n.iid, RunStatus.idle);
    }
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final order = executionOrder(nodes, wires);
    final results = <NodeResult>[];
    var ctx = Map<String, dynamic>.from(input);

    for (final id in order) {
      if (shouldCancel?.call() == true) break;
      final node = nodes.firstWhere((n) => n.iid == id);
      final started = DateTime.now().toUtc();
      onStatus(id, RunStatus.running);
      onEvent?.call(
        PreviewEvent(
          nodeId: id,
          status: RunStatus.running,
          input: Map<String, dynamic>.from(ctx),
          at: started,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 280));

      var ok = true;
      String? message = 'ok';
      Map<String, dynamic>? output;

      try {
        if (node.def.id == 'if-else') {
          final cond = '${node.config['condition'] ?? ''}';
          final pass = _eval.evaluateCondition(cond, ctx);
          output = {'branch': pass ? 'true' : 'false'};
          ctx = {...ctx, 'branch': pass ? 'true' : 'false'};
        } else if (node.def.id == 'code') {
          final lang = '${node.config['lang'] ?? 'expression'}';
          final source = '${node.config['code'] ?? ''}';
          if (lang == 'expression' || lang.isEmpty) {
            output = _eval.runExpression(source, ctx);
            ctx = {...ctx, 'result': output['result']};
          } else if (codePreview != null) {
            output = await codePreview(node, ctx);
            ctx = {...ctx, ...output};
          } else {
            message = 'Host code preview not configured for $lang';
            ok = false;
          }
        } else {
          // Interpolate templates into a shallow output snapshot.
          final snap = <String, String>{};
          node.config.forEach((k, v) {
            snap[k] = _eval.interpolate('$v', ctx);
          });
          output = {'config': snap};
          if (useRandomFailures) {
            ok = _random.nextDouble() > 0.05;
            if (!ok) message = 'Simulated failure';
          }
        }
      } catch (e) {
        ok = false;
        message = '$e';
      }

      final status = ok ? RunStatus.success : RunStatus.error;
      final duration =
          DateTime.now().toUtc().difference(started).inMilliseconds;
      onStatus(id, status);
      final result = NodeResult(
        nodeId: id,
        status: status,
        message: message,
        input: Map<String, dynamic>.from(ctx),
        output: output,
        durationMs: duration,
      );
      results.add(result);
      onEvent?.call(
        PreviewEvent(
          nodeId: id,
          status: status,
          input: result.input,
          output: output,
          message: message,
          durationMs: duration,
          at: DateTime.now().toUtc(),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }

    return RunReport(
      order: order,
      results: results,
      input: input,
      finishedAt: DateTime.now().toUtc(),
    );
  }
}
