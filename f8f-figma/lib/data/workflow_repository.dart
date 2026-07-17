import 'dart:convert';

import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/demo_workflow.dart';
import 'package:autoflow/domain/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kStorageKey = 'autoflow.workflow.v2';

class WorkflowRepository {
  Future<WorkflowDoc> load([NodeCatalog? catalog]) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStorageKey);
    if (raw == null || raw.isEmpty) return createDemoWorkflow();
    try {
      return decodeWorkflow(raw, catalog ?? buildDefaultCatalog());
    } catch (_) {
      return createDemoWorkflow();
    }
  }

  Future<void> save(WorkflowDoc doc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStorageKey, encodeWorkflow(doc));
  }

  String encodeWorkflow(WorkflowDoc doc) =>
      const JsonEncoder.withIndent('  ').convert(doc.toJson());

  WorkflowDoc decodeWorkflow(String raw, [NodeCatalog? catalog]) {
    final cat = catalog ?? buildDefaultCatalog();
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return workflowFromJson(map, cat);
  }

  WorkflowDoc workflowFromJson(Map<String, dynamic> map, NodeCatalog catalog) {
    final version = map['version'] as int? ?? 1;
    final nodesJson = (map['nodes'] as List? ?? const []);
    final wiresJson = (map['wires'] as List? ?? const []);

    final nodes = <CanvasNode>[];
    for (final item in nodesJson) {
      final n = item as Map<String, dynamic>;
      final typeId = n['typeId'] as String? ??
          n['defId'] as String? ??
          (n['def'] as Map?)?['id'] as String?;
      if (typeId == null) continue;
      final type = catalog.find(typeId);
      final def = type?.asDef ??
          NodeDef(
            id: typeId,
            kind: NodeKind.action,
            label: typeId,
            sublabel: 'Unknown type',
          );
      final configRaw = n['config'] as Map<String, dynamic>? ?? {};
      nodes.add(
        CanvasNode(
          iid: n['iid'] as String,
          def: def,
          x: (n['x'] as num).toDouble(),
          y: (n['y'] as num).toDouble(),
          status: RunStatus.values.byName((n['status'] as String?) ?? 'idle'),
          config: configRaw.map((k, v) => MapEntry(k, '$v')),
        ),
      );
    }

    final wires = wiresJson
        .map((w) => Wire.fromJson(w as Map<String, dynamic>))
        .toList();

    TriggerBinding? trigger;
    if (map['trigger'] != null) {
      trigger =
          TriggerBinding.fromJson(map['trigger'] as Map<String, dynamic>);
    } else {
      // Derive from first trigger node for v1 migration.
      for (final n in nodes) {
        final t = catalog.find(n.def.id)?.trigger;
        if (t != null) {
          trigger = TriggerBinding(type: t.type, filters: {
            ...t.filters,
            ...n.config,
          });
          break;
        }
      }
    }

    return WorkflowDoc(
      version: version < 2 ? 2 : version,
      id: map['id'] as String?,
      name: map['name'] as String? ?? 'Untitled Workflow',
      nodes: nodes,
      wires: wires,
      trigger: trigger,
      meta: Map<String, dynamic>.from(map['meta'] as Map? ?? {}),
    );
  }
}
