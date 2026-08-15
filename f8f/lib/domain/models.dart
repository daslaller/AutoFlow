import 'package:flutter/material.dart';
import 'package:autoflow/theme/anchor_colors.dart';

enum NodeKind { trigger, action, condition, transform, output }

enum RunStatus { idle, running, success, error }

enum FieldType {
  text,
  textarea,
  number,
  select,
  toggle,
  json,
  code,
  variablePicker,
  statusEnum,
  template,
}

enum CodeLanguage { expression, javascript, dartSnippet }

extension NodeKindX on NodeKind {
  String get label => switch (this) {
        NodeKind.trigger => 'TRIGGER',
        NodeKind.action => 'ACTION',
        NodeKind.condition => 'LOGIC',
        NodeKind.transform => 'TRANSFORM',
        NodeKind.output => 'OUTPUT',
      };

  Color get color => switch (this) {
        NodeKind.trigger => AnchorColors.kindTrigger,
        NodeKind.action => AnchorColors.kindAction,
        NodeKind.condition => AnchorColors.kindCondition,
        NodeKind.transform => AnchorColors.kindTransform,
        NodeKind.output => AnchorColors.kindOutput,
      };
}

extension RunStatusX on RunStatus {
  Color get color => switch (this) {
        RunStatus.idle => AnchorColors.statusIdle,
        RunStatus.running => AnchorColors.statusRunning,
        RunStatus.success => AnchorColors.statusSuccess,
        RunStatus.error => AnchorColors.statusError,
      };
}

/// Legacy lightweight def — still used by CanvasNode; maps from NodeTypeDef.
class NodeDef {
  const NodeDef({
    required this.id,
    required this.kind,
    required this.label,
    required this.sublabel,
    this.iconKey,
  });

  final String id;
  final NodeKind kind;
  final String label;
  final String sublabel;
  final String? iconKey;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'label': label,
        'sublabel': sublabel,
        if (iconKey != null) 'iconKey': iconKey,
      };

  factory NodeDef.fromJson(Map<String, dynamic> json) => NodeDef(
        id: json['id'] as String,
        kind: NodeKind.values.byName(json['kind'] as String),
        label: json['label'] as String,
        sublabel: json['sublabel'] as String? ?? '',
        iconKey: json['iconKey'] as String?,
      );

  factory NodeDef.fromType(NodeTypeDef t) => NodeDef(
        id: t.id,
        kind: t.kind,
        label: t.label,
        sublabel: t.sublabel,
        iconKey: t.iconKey,
      );
}

class ConfigField {
  const ConfigField({
    required this.label,
    required this.placeholder,
    required this.key,
  });

  final String label;
  final String placeholder;
  final String key;
}

class PortDef {
  const PortDef({
    required this.id,
    required this.label,
    this.multiple = false,
  });

  final String id;
  final String label;
  final bool multiple;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'multiple': multiple,
      };

  factory PortDef.fromJson(Map<String, dynamic> json) => PortDef(
        id: json['id'] as String,
        label: json['label'] as String? ?? json['id'] as String,
        multiple: json['multiple'] as bool? ?? false,
      );
}

class FieldOption {
  const FieldOption({required this.value, required this.label});
  final String value;
  final String label;

  Map<String, dynamic> toJson() => {'value': value, 'label': label};
  factory FieldOption.fromJson(Map<String, dynamic> json) => FieldOption(
        value: '${json['value']}',
        label: json['label'] as String? ?? '${json['value']}',
      );
}

class FieldDef {
  const FieldDef({
    required this.key,
    required this.label,
    required this.type,
    this.placeholder = '',
    this.required = false,
    this.options = const [],
    this.defaultValue,
    this.codeLanguage,
  });

  final String key;
  final String label;
  final FieldType type;
  final String placeholder;
  final bool required;
  final List<FieldOption> options;
  final String? defaultValue;
  final CodeLanguage? codeLanguage;

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'type': type.name,
        'placeholder': placeholder,
        'required': required,
        'options': options.map((o) => o.toJson()).toList(),
        if (defaultValue != null) 'defaultValue': defaultValue,
        if (codeLanguage != null) 'codeLanguage': codeLanguage!.name,
      };

  factory FieldDef.fromJson(Map<String, dynamic> json) => FieldDef(
        key: json['key'] as String,
        label: json['label'] as String,
        type: FieldType.values.byName(json['type'] as String? ?? 'text'),
        placeholder: json['placeholder'] as String? ?? '',
        required: json['required'] as bool? ?? false,
        options: (json['options'] as List? ?? [])
            .map((o) => FieldOption.fromJson(o as Map<String, dynamic>))
            .toList(),
        defaultValue: json['defaultValue'] as String?,
        codeLanguage: json['codeLanguage'] != null
            ? CodeLanguage.values.byName(json['codeLanguage'] as String)
            : null,
      );
}

class TriggerBinding {
  const TriggerBinding({
    required this.type,
    this.filters = const {},
  });

  final String type;
  final Map<String, dynamic> filters;

  Map<String, dynamic> toJson() => {'type': type, 'filters': filters};

  factory TriggerBinding.fromJson(Map<String, dynamic> json) => TriggerBinding(
        type: json['type'] as String,
        filters: Map<String, dynamic>.from(json['filters'] as Map? ?? {}),
      );
}

class NodeTypeDef {
  const NodeTypeDef({
    required this.id,
    required this.kind,
    required this.label,
    required this.sublabel,
    this.iconKey,
    this.inputs = const [PortDef(id: 'in', label: 'In')],
    this.outputs = const [PortDef(id: 'out', label: 'Out')],
    this.fields = const [],
    this.produces = const [],
    this.requires = const [],
    this.trigger,
  });

  final String id;
  final NodeKind kind;
  final String label;
  final String sublabel;
  final String? iconKey;
  final List<PortDef> inputs;
  final List<PortDef> outputs;
  final List<FieldDef> fields;
  final List<String> produces;
  final List<String> requires;
  final TriggerBinding? trigger;

  NodeDef get asDef => NodeDef.fromType(this);

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'label': label,
        'sublabel': sublabel,
        if (iconKey != null) 'iconKey': iconKey,
        'inputs': inputs.map((p) => p.toJson()).toList(),
        'outputs': outputs.map((p) => p.toJson()).toList(),
        'fields': fields.map((f) => f.toJson()).toList(),
        'produces': produces,
        'requires': requires,
        if (trigger != null) 'trigger': trigger!.toJson(),
      };

  factory NodeTypeDef.fromJson(Map<String, dynamic> json) => NodeTypeDef(
        id: json['id'] as String,
        kind: NodeKind.values.byName(json['kind'] as String),
        label: json['label'] as String,
        sublabel: json['sublabel'] as String? ?? '',
        iconKey: json['iconKey'] as String?,
        inputs: (json['inputs'] as List? ?? [])
            .map((p) => PortDef.fromJson(p as Map<String, dynamic>))
            .toList()
            .ifEmpty(const [PortDef(id: 'in', label: 'In')]),
        outputs: (json['outputs'] as List? ?? [])
            .map((p) => PortDef.fromJson(p as Map<String, dynamic>))
            .toList()
            .ifEmpty(const [PortDef(id: 'out', label: 'Out')]),
        fields: (json['fields'] as List? ?? [])
            .map((f) => FieldDef.fromJson(f as Map<String, dynamic>))
            .toList(),
        produces: (json['produces'] as List? ?? []).cast<String>(),
        requires: (json['requires'] as List? ?? []).cast<String>(),
        trigger: json['trigger'] != null
            ? TriggerBinding.fromJson(json['trigger'] as Map<String, dynamic>)
            : null,
      );
}

extension _ListPortX on List<PortDef> {
  List<PortDef> ifEmpty(List<PortDef> fallback) => isEmpty ? fallback : this;
}

class NodeCatalog {
  const NodeCatalog({
    this.version = '1',
    required this.types,
  });

  final String version;
  final List<NodeTypeDef> types;

  NodeTypeDef? find(String id) {
    for (final t in types) {
      if (t.id == id) return t;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'types': types.map((t) => t.toJson()).toList(),
      };

  factory NodeCatalog.fromJson(Map<String, dynamic> json) => NodeCatalog(
        version: '${json['version'] ?? '1'}',
        types: (json['types'] as List? ?? [])
            .map((t) => NodeTypeDef.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}

class VariableVar {
  const VariableVar({
    required this.path,
    required this.label,
    this.type = 'string',
    this.example,
  });

  final String path;
  final String label;
  final String type;
  final dynamic example;

  Map<String, dynamic> toJson() => {
        'path': path,
        'label': label,
        'type': type,
        if (example != null) 'example': example,
      };

  factory VariableVar.fromJson(Map<String, dynamic> json) => VariableVar(
        path: json['path'] as String,
        label: json['label'] as String? ?? json['path'] as String,
        type: json['type'] as String? ?? 'string',
        example: json['example'],
      );
}

class VariableGroup {
  const VariableGroup({
    required this.id,
    required this.label,
    required this.variables,
  });

  final String id;
  final String label;
  final List<VariableVar> variables;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'variables': variables.map((v) => v.toJson()).toList(),
      };

  factory VariableGroup.fromJson(Map<String, dynamic> json) => VariableGroup(
        id: json['id'] as String,
        label: json['label'] as String,
        variables: (json['variables'] as List? ?? [])
            .map((v) => VariableVar.fromJson(v as Map<String, dynamic>))
            .toList(),
      );
}

class VariableSchema {
  const VariableSchema({this.groups = const []});

  final List<VariableGroup> groups;

  Map<String, dynamic> toJson() => {
        'groups': groups.map((g) => g.toJson()).toList(),
      };

  factory VariableSchema.fromJson(Map<String, dynamic> json) => VariableSchema(
        groups: (json['groups'] as List? ?? [])
            .map((g) => VariableGroup.fromJson(g as Map<String, dynamic>))
            .toList(),
      );

  static const empty = VariableSchema();
}

class CanvasNode {
  const CanvasNode({
    required this.iid,
    required this.def,
    required this.x,
    required this.y,
    this.status = RunStatus.idle,
    this.config = const {},
  });

  final String iid;
  final NodeDef def;
  final double x;
  final double y;
  final RunStatus status;
  final Map<String, String> config;

  String get typeId => def.id;
  Offset get position => Offset(x, y);

  CanvasNode copyWith({
    String? iid,
    NodeDef? def,
    double? x,
    double? y,
    RunStatus? status,
    Map<String, String>? config,
  }) {
    return CanvasNode(
      iid: iid ?? this.iid,
      def: def ?? this.def,
      x: x ?? this.x,
      y: y ?? this.y,
      status: status ?? this.status,
      config: config ?? this.config,
    );
  }

  Map<String, dynamic> toJson() => {
        'iid': iid,
        'typeId': def.id,
        'defId': def.id, // v1 compat
        'x': x,
        'y': y,
        'status': status.name,
        'config': config,
      };
}

class Wire {
  const Wire({
    required this.id,
    required this.from,
    required this.to,
    this.fromPort = 'out',
    this.toPort = 'in',
  });

  final String id;
  final String from;
  final String to;
  final String fromPort;
  final String toPort;

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from,
        'to': to,
        'fromPort': fromPort,
        'toPort': toPort,
      };

  factory Wire.fromJson(Map<String, dynamic> json) => Wire(
        id: json['id'] as String,
        from: json['from'] as String,
        to: json['to'] as String,
        fromPort: json['fromPort'] as String? ?? 'out',
        toPort: json['toPort'] as String? ?? 'in',
      );
}

class DrawingWire {
  const DrawingWire({
    required this.fromId,
    required this.fx,
    required this.fy,
    required this.tx,
    required this.ty,
    this.fromPort = 'out',
  });

  final String fromId;
  final String fromPort;
  final double fx;
  final double fy;
  final double tx;
  final double ty;

  DrawingWire copyWith({double? tx, double? ty}) => DrawingWire(
        fromId: fromId,
        fromPort: fromPort,
        fx: fx,
        fy: fy,
        tx: tx ?? this.tx,
        ty: ty ?? this.ty,
      );
}

class WorkflowDoc {
  const WorkflowDoc({
    required this.name,
    required this.nodes,
    required this.wires,
    this.version = 2,
    this.id,
    this.trigger,
    this.meta = const {},
  });

  final String name;
  final List<CanvasNode> nodes;
  final List<Wire> wires;
  final int version;
  final String? id;
  final TriggerBinding? trigger;
  final Map<String, dynamic> meta;

  WorkflowDoc copyWith({
    String? name,
    List<CanvasNode>? nodes,
    List<Wire>? wires,
    int? version,
    String? id,
    TriggerBinding? trigger,
    Map<String, dynamic>? meta,
  }) {
    return WorkflowDoc(
      name: name ?? this.name,
      nodes: nodes ?? this.nodes,
      wires: wires ?? this.wires,
      version: version ?? this.version,
      id: id ?? this.id,
      trigger: trigger ?? this.trigger,
      meta: meta ?? this.meta,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        if (id != null) 'id': id,
        'name': name,
        if (trigger != null) 'trigger': trigger!.toJson(),
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'wires': wires.map((w) => w.toJson()).toList(),
        'meta': meta,
      };
}

class NodeResult {
  const NodeResult({
    required this.nodeId,
    required this.status,
    this.message,
    this.input,
    this.output,
    this.durationMs,
  });

  final String nodeId;
  final RunStatus status;
  final String? message;
  final Map<String, dynamic>? input;
  final Map<String, dynamic>? output;
  final int? durationMs;

  Map<String, dynamic> toJson() => {
        'nodeId': nodeId,
        'status': status.name,
        if (message != null) 'message': message,
        if (input != null) 'input': input,
        if (output != null) 'output': output,
        if (durationMs != null) 'durationMs': durationMs,
      };
}

class RunReport {
  const RunReport({
    required this.order,
    required this.results,
    required this.input,
    required this.finishedAt,
  });

  final List<String> order;
  final List<NodeResult> results;
  final Map<String, dynamic> input;
  final DateTime finishedAt;

  Map<String, dynamic> toJson() => {
        'order': order,
        'results': results.map((r) => r.toJson()).toList(),
        'input': input,
        'finishedAt': finishedAt.toIso8601String(),
      };
}

class PreviewEvent {
  const PreviewEvent({
    required this.nodeId,
    required this.status,
    this.input,
    this.output,
    this.message,
    this.durationMs,
    required this.at,
  });

  final String nodeId;
  final RunStatus status;
  final Map<String, dynamic>? input;
  final Map<String, dynamic>? output;
  final String? message;
  final int? durationMs;
  final DateTime at;

  Map<String, dynamic> toJson() => {
        'nodeId': nodeId,
        'status': status.name,
        if (input != null) 'input': input,
        if (output != null) 'output': output,
        if (message != null) 'message': message,
        if (durationMs != null) 'durationMs': durationMs,
        'at': at.toIso8601String(),
      };
}

class PreviewRecording {
  const PreviewRecording({
    required this.events,
    required this.sampleRecord,
    required this.startedAt,
    this.finishedAt,
  });

  final List<PreviewEvent> events;
  final Map<String, dynamic> sampleRecord;
  final DateTime startedAt;
  final DateTime? finishedAt;

  Map<String, dynamic> toJson() => {
        'events': events.map((e) => e.toJson()).toList(),
        'sampleRecord': sampleRecord,
        'startedAt': startedAt.toIso8601String(),
        if (finishedAt != null) 'finishedAt': finishedAt!.toIso8601String(),
      };
}

class ValidationIssue {
  const ValidationIssue({
    required this.nodeId,
    required this.message,
    this.fieldKey,
  });

  final String nodeId;
  final String message;
  final String? fieldKey;
}

enum EmbedChrome { full, minimal }

class EmbedConfig {
  const EmbedConfig({
    this.embedChrome = EmbedChrome.full,
    this.readOnly = false,
  });

  final EmbedChrome embedChrome;
  final bool readOnly;

  EmbedConfig copyWith({EmbedChrome? embedChrome, bool? readOnly}) =>
      EmbedConfig(
        embedChrome: embedChrome ?? this.embedChrome,
        readOnly: readOnly ?? this.readOnly,
      );
}

/// Right-side inspector mode.
enum SidePanelTab { properties, records, variables, preview }
