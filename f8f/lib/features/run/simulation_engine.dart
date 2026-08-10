import 'dart:async';
import 'dart:math';

import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/run/expression_evaluator.dart';
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';

typedef CodePreviewFn = Future<Map<String, dynamic>> Function(
  CanvasNode node,
  Map<String, dynamic> ctx,
);

/// Preview execution, backed by `fl_nodes_visual_scripting` (HeidNodes'
/// `fl_nodes_core` engine underneath).
///
/// This class's public shape — [run]'s parameter list, [RunReport]/
/// [NodeResult]/[PreviewEvent] — is unchanged from before this was
/// HeidNodes-backed, so `WorkflowController`'s call site needed no changes.
/// What changed is [run]'s *correctness*: the previous implementation walked
/// every node in a flat topological order regardless of which branch an
/// `if-else` node actually took (both the true and false branch always
/// "ran" in preview). This one builds a real fl_nodes_core graph — with the
/// same `true`/`false`-named control ports the catalog already declares —
/// and lets its runner decide which branch to walk, the same engine that's
/// wired to run production automations host-side. See
/// `docs/ENGINE.md` for the full rationale and what didn't change.
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

    final queue = nodes.where((n) => (inbound[n.iid] ?? 0) == 0).map((n) => n.iid).toList();
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

    final results = <NodeResult>[];
    final order = <String>[];
    var ctx = Map<String, dynamic>.from(input);

    Future<void> beforeNode(CanvasNode node) async {
      order.add(node.iid);
      onStatus(node.iid, RunStatus.running);
      onEvent?.call(
        PreviewEvent(
          nodeId: node.iid,
          status: RunStatus.running,
          input: Map<String, dynamic>.from(ctx),
          at: DateTime.now().toUtc(),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 280));
    }

    Future<void> afterNode(
      CanvasNode node,
      DateTime started, {
      required bool ok,
      String? message,
      Map<String, dynamic>? output,
    }) async {
      final status = ok ? RunStatus.success : RunStatus.error;
      final duration = DateTime.now().toUtc().difference(started).inMilliseconds;
      onStatus(node.iid, status);
      results.add(
        NodeResult(
          nodeId: node.iid,
          status: status,
          message: message,
          input: Map<String, dynamic>.from(ctx),
          output: output,
          durationMs: duration,
        ),
      );
      onEvent?.call(
        PreviewEvent(
          nodeId: node.iid,
          status: status,
          input: Map<String, dynamic>.from(ctx),
          output: output,
          message: message,
          durationMs: duration,
          at: DateTime.now().toUtc(),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }

    List<String> outputsFor(CanvasNode node) =>
        catalog?.find(node.typeId)?.outputs.map((p) => p.id).toList() ?? const ['out'];
    List<String> inputsFor(CanvasNode node) =>
        catalog?.find(node.typeId)?.inputs.map((p) => p.id).toList() ?? const ['in'];

    late final AutomationEngine engine;
    AutomationRunContext run() => engine.currentRun!;

    FlNodePrototype prototypeFor(CanvasNode node) {
      final outs = outputsFor(node);
      final ins = inputsFor(node);

      if (ins.isEmpty) {
        // Trigger node: no inputs, matches fl_nodes_core's own "starting
        // node" definition — see fl_nodes_visual_scripting's triggerNode doc.
        return triggerNode(
          idName: node.iid,
          displayName: (_) => node.def.label,
          outPort: outs.first,
          getRun: run,
        );
      }

      if (node.def.id == 'if-else' && outs.length > 1) {
        return conditionNode(
          idName: node.iid,
          displayName: (_) => node.def.label,
          inPort: ins.first,
          outPorts: outs,
          getRun: run,
          evaluate: (execCtx) async {
            if (shouldCancel?.call() == true) return outs.first;
            await beforeNode(node);
            final started = DateTime.now().toUtc();
            final cond = node.config['condition'] ?? '';
            final pass = _eval.evaluateCondition(cond, ctx);
            final branch = pass ? 'true' : 'false';
            final output = {'branch': branch};
            ctx = {...ctx, 'branch': branch};
            await afterNode(node, started, ok: true, output: output);
            return outs.contains(branch) ? branch : outs.first;
          },
        );
      }

      // Generic action/transform/output node, and the 'code' expression
      // node — same behavior the original preview had per node type.
      return actionNode(
        idName: node.iid,
        displayName: (_) => node.def.label,
        inPort: ins.first,
        outPort: outs.first,
        getRun: run,
        perform: (execCtx) async {
          if (shouldCancel?.call() == true) return;
          await beforeNode(node);
          final started = DateTime.now().toUtc();
          var ok = true;
          String? message = 'ok';
          Map<String, dynamic>? output;

          try {
            if (node.def.id == 'code') {
              final lang = node.config['lang'] ?? 'expression';
              final source = node.config['code'] ?? '';
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
              final snap = <String, String>{};
              node.config.forEach((k, v) {
                snap[k] = _eval.interpolate(v, ctx);
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

          await afterNode(node, started, ok: ok, message: message, output: output);
          if (!ok) throw StateError(message);
        },
      );
    }

    engine = AutomationEngine(
      appVersion: '1.0.0',
      nodePrototypes: [for (final n in nodes) prototypeFor(n)],
    );
    try {
      // addNode(prototypeIdName) creates an instance with its OWN generated
      // id — distinct from AutoFlow's CanvasNode.iid used as the prototype
      // name — so links must be built against that generated id, not iid.
      final flNodeIdByIid = <String, String>{};
      for (final n in nodes) {
        flNodeIdByIid[n.iid] = engine.controller.addNode(n.iid).id;
      }
      for (final w in wires) {
        final fromId = flNodeIdByIid[w.from];
        final toId = flNodeIdByIid[w.to];
        if (fromId == null || toId == null) continue;
        engine.controller.addLink(fromId, w.fromPort, toId, w.toPort);
      }

      await engine.run(record: input);
    } finally {
      engine.dispose();
    }

    return RunReport(
      order: order,
      results: results,
      input: input,
      finishedAt: DateTime.now().toUtc(),
    );
  }
}
