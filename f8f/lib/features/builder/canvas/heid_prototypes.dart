import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/heid_style.dart';
import 'package:autoflow/features/run/expression_evaluator.dart';

typedef HeidCodePreviewFn = Future<Map<String, dynamic>> Function(
  CanvasNode node,
  Map<String, dynamic> ctx,
);

/// Hidden field so a shared catalog prototype can recover the instance id
/// inside [OnNodeExecute] (HeidNodes does not pass the node id to execute).
const kHeidIidField = '_iid';

/// Live preview callbacks shared by every catalog prototype.
class PreviewSession extends ChangeNotifier {
  PreviewSession({
    Random? random,
    ExpressionEvaluator? evaluator,
  })  : random = random ?? Random(),
        eval = evaluator ?? ExpressionEvaluator();

  final Random random;
  final ExpressionEvaluator eval;

  Map<String, dynamic> ctx = {};
  NodeCatalog? catalog;
  HeidCodePreviewFn? codePreview;
  bool Function()? shouldCancel;
  void Function(String iid, RunStatus status)? onStatus;
  void Function(PreviewEvent event)? onEvent;
  bool useRandomFailures = true;

  final List<String> order = [];
  final List<NodeResult> results = [];
  final Map<String, RunStatus> statuses = {};

  RunStatus statusOf(String iid) => statuses[iid] ?? RunStatus.idle;

  NodeKind kindOf(String typeId) =>
      catalog?.find(typeId)?.kind ?? NodeKind.action;

  void reset({
    required Map<String, dynamic> input,
    required NodeCatalog catalog,
    HeidCodePreviewFn? codePreview,
    bool Function()? shouldCancel,
    void Function(String iid, RunStatus status)? onStatus,
    void Function(PreviewEvent event)? onEvent,
    bool useRandomFailures = true,
  }) {
    ctx = Map<String, dynamic>.from(input);
    this.catalog = catalog;
    this.codePreview = codePreview;
    this.shouldCancel = shouldCancel;
    this.onStatus = onStatus;
    this.onEvent = onEvent;
    this.useRandomFailures = useRandomFailures;
    order.clear();
    results.clear();
    statuses.clear();
    notifyListeners();
  }

  void _setStatus(String iid, RunStatus status) {
    statuses[iid] = status;
    onStatus?.call(iid, status);
    notifyListeners();
  }

  String iidOf(Map<String, dynamic> fields) => '${fields[kHeidIidField] ?? ''}';

  Map<String, String> configOf(Map<String, dynamic> fields) {
    final out = <String, String>{};
    for (final e in fields.entries) {
      if (e.key == kHeidIidField) continue;
      out[e.key] = '${e.value ?? ''}';
    }
    return out;
  }

  Future<void> before(String iid) async {
    order.add(iid);
    _setStatus(iid, RunStatus.running);
    onEvent?.call(
      PreviewEvent(
        nodeId: iid,
        status: RunStatus.running,
        input: Map<String, dynamic>.from(ctx),
        at: DateTime.now().toUtc(),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 280));
  }

  Future<void> after(
    String iid,
    DateTime started, {
    required bool ok,
    String? message,
    Map<String, dynamic>? output,
  }) async {
    final status = ok ? RunStatus.success : RunStatus.error;
    final duration = DateTime.now().toUtc().difference(started).inMilliseconds;
    _setStatus(iid, status);
    results.add(
      NodeResult(
        nodeId: iid,
        status: status,
        message: message,
        input: Map<String, dynamic>.from(ctx),
        output: output,
        durationMs: duration,
      ),
    );
    onEvent?.call(
      PreviewEvent(
        nodeId: iid,
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

  String takenBranch(String typeId, Map<String, String> config, List<String> outs) {
    if (typeId == 'if-else') {
      final pass = eval.evaluateCondition(config['condition'] ?? '', ctx);
      final branch = pass ? 'true' : 'false';
      return outs.contains(branch) ? branch : outs.first;
    }
    if (typeId == 'switch') {
      final value = eval.interpolate(config['expr'] ?? '', ctx);
      for (final key in const ['case1', 'case2', 'case3']) {
        final expected = (config[key] ?? '').trim();
        if (expected.isNotEmpty && value == expected) {
          return outs.contains(key) ? key : outs.first;
        }
      }
      return outs.contains('default') ? 'default' : outs.last;
    }
    return outs.first;
  }
}

FlFieldPrototype _hiddenStringField(String id, {String defaultValue = ''}) {
  return FlFieldPrototype(
    idName: id,
    displayName: (_) => id,
    dataType: String,
    defaultData: defaultValue,
    visualizerBuilder: (_) => const SizedBox.shrink(),
    onVisualizerTap: (data, setData) {},
  );
}

FlControlOutputPortPrototype _controlOut(String id, String label, Color color) {
  return FlControlOutputPortPrototype(
    idName: id,
    displayName: (_) => label,
    geometricOrientation: FlPortGeometricOrientation.right,
    styleBuilder: (s) => HeidStyle.portStyle(color, s),
  );
}

FlControlInputPortPrototype _controlIn(String id, String label, Color color) {
  return FlControlInputPortPrototype(
    idName: id,
    displayName: (_) => label,
    geometricOrientation: FlPortGeometricOrientation.left,
    styleBuilder: (s) => HeidStyle.portStyle(color, s),
  );
}

/// One HeidNodes prototype per catalog type. Instances share this blueprint;
/// per-node config lives in fields (`_iid` + each [FieldDef.key]).
FlNodePrototype prototypeForType(NodeTypeDef type, PreviewSession session) {
  final color = type.kind.color;
  final outs = type.outputs.isEmpty
      ? const [PortDef(id: 'out', label: 'Out')]
      : type.outputs;
  final ins = type.inputs;
  final fields = <FlFieldPrototype>[
    _hiddenStringField(kHeidIidField),
    for (final f in type.fields)
      _hiddenStringField(f.key, defaultValue: f.defaultValue ?? ''),
  ];

  final ports = <FlPortPrototype>[
    for (final p in ins) _controlIn(p.id, p.label, color),
    for (final p in outs) _controlOut(p.id, p.label, color),
  ];

  return automationNode(
    idName: type.id,
    displayName: (_) => type.label,
    description: (_) => type.sublabel,
    ports: ports,
    fields: fields,
    styleBuilder: HeidStyle.nodeStyle,
    headerStyleBuilder: (s) => HeidStyle.headerStyle(type.kind, s),
    getRun: () {
      // Preview never reads AutomationRunContext; AutomationEngine still
      // requires the callback. Headless runs construct a throwaway context.
      return AutomationRunContext(record: session.ctx);
    },
    onExecute: (exec) async {
      if (session.shouldCancel?.call() == true) return;
      final fieldsMap = exec.fields;
      final iid = session.iidOf(fieldsMap);
      final config = session.configOf(fieldsMap);
      final outIds = outs.map((p) => p.id).toList();

      if (ins.isEmpty) {
        await session.before(iid);
        final started = DateTime.now().toUtc();
        await session.after(iid, started, ok: true, output: {'trigger': type.id});
        exec.forward(outIds.first);
        return;
      }

      if (outIds.length > 1) {
        await session.before(iid);
        final started = DateTime.now().toUtc();
        final branch = session.takenBranch(type.id, config, outIds);
        session.ctx = {...session.ctx, 'branch': branch};
        await session.after(iid, started, ok: true, output: {'branch': branch});
        exec.forward(branch);
        return;
      }

      await session.before(iid);
      final started = DateTime.now().toUtc();
      var ok = true;
      String? message = 'ok';
      Map<String, dynamic>? output;

      try {
        if (type.id == 'code') {
          final lang = config['lang'] ?? 'expression';
          final source = config['code'] ?? '';
          if (lang == 'expression' || lang.isEmpty) {
            output = session.eval.runExpression(source, session.ctx);
            session.ctx = {...session.ctx, 'result': output['result']};
          } else if (session.codePreview != null) {
            final node = CanvasNode(
              iid: iid,
              def: type.asDef,
              x: 0,
              y: 0,
              config: config,
            );
            output = await session.codePreview!(node, session.ctx);
            session.ctx = {...session.ctx, ...output};
          } else {
            message = 'Host code preview not configured for $lang';
            ok = false;
          }
        } else {
          final snap = <String, String>{};
          config.forEach((k, v) {
            snap[k] = session.eval.interpolate(v, session.ctx);
          });
          output = {'config': snap};
          if (session.useRandomFailures) {
            ok = session.random.nextDouble() > 0.05;
            if (!ok) message = 'Simulated failure';
          }
        }
      } catch (e) {
        ok = false;
        message = '$e';
      }

      await session.after(iid, started, ok: ok, message: message, output: output);
      if (!ok) throw StateError(message ?? 'error');
      exec.forward(outIds.first);
    },
  );
}

void registerCatalogPrototypes(
  FlNodesController controller,
  NodeCatalog catalog,
  PreviewSession session,
) {
  controller.nodePrototypes
    ..clear()
    ..addAll({
      for (final t in catalog.types) t.id: prototypeForType(t, session),
    });
}
