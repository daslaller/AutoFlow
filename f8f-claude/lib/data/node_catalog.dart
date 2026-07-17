import 'package:flutter/material.dart';
import 'package:flowstock/models/models.dart';
import 'package:flowstock/theme/flowstock_colors.dart';

/// Lucide-style SVG path strings from the design handoff.
abstract final class Ic {
  static const tag =
      'M12 2H2v10l9.29 9.29a1 1 0 0 0 1.42 0l8.58-8.58a1 1 0 0 0 0-1.42L12 2z M7 7h.01';
  static const clock =
      'M12 2a10 10 0 1 1 0 20 10 10 0 0 1 0-20z M12 6v6l4 2';
  static const zap = 'M13 2 3 14h9l-1 8 10-12h-9l1-8z';
  static const pkg =
      'M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z M3.3 7 12 12l8.7-5 M12 22V12';
  static const user =
      'M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2 M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z';
  static const bell =
      'M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9 M10.3 21a1.94 1.94 0 0 0 3.4 0';
  static const mail =
      'M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z M22 6l-10 7L2 6';
  static const msg =
      'M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z';
  static const branch =
      'M6 3v12 M18 9a9 9 0 0 1-9 9 M6 21a3 3 0 1 1 0-6 3 3 0 0 1 0 6z M18 3a3 3 0 1 0 0 6 3 3 0 0 0 0-6z';
  static const filter = 'M22 3H2l8 9.46V19l4 2v-8.54L22 3z';
  static const braces =
      'M8 3H7a2 2 0 0 0-2 2v5a2 2 0 0 1-2 2 2 2 0 0 1 2 2v5c0 1.1.9 2 2 2h1 M16 21h1a2 2 0 0 0 2-2v-5c0-1.1.9-2 2-2a2 2 0 0 1-2-2V5a2 2 0 0 0-2-2h-1';
  static const spark =
      'M12 3l1.9 5.8L20 11l-6.1 2.2L12 19l-1.9-5.8L4 11l6.1-2.2L12 3z';
  static const scan =
      'M3 7V5a2 2 0 0 1 2-2h2 M17 3h2a2 2 0 0 1 2 2v2 M21 17v2a2 2 0 0 1-2 2h-2 M7 21H5a2 2 0 0 1-2-2v-2 M7 8h8 M7 12h10 M7 16h6';
  static const refresh =
      'M21 12a9 9 0 1 1-2.64-6.36L21 8 M21 3v5h-5';
  static const shuffle =
      'M2 18h1.4c1.3 0 2.5-.6 3.3-1.7l6.1-8.6c.8-1.1 2-1.7 3.3-1.7H22 M18 2l4 4-4 4 M2 6h1.9c1.5 0 2.9.9 3.6 2.2 M22 18h-5.9c-1.3 0-2.6-.7-3.3-1.8l-.5-.8 M18 14l4 4-4 4';
  static const codeBrackets =
      'm16 18 6-6-6-6 M8 6l-6 6 6 6';
  static const play = 'm6 4 14 8-14 8V4z';
  static const check = 'M20 6 9 17l-5-5';
  static const search =
      'M11 3a8 8 0 1 1 0 16 8 8 0 0 1 0-16z M21 21l-4.35-4.35';
  static const chevronLeft = 'm15 18-6-6 6-6';
  static const chevronRight = 'm9 18 6-6-6-6';
  static const plus = 'M5 12h14 M12 5v14';
  static const minus = 'M5 12h14';
  static const fit =
      'M8 3H5a2 2 0 0 0-2 2v3 M21 8V5a2 2 0 0 0-2-2h-3 M3 16v3a2 2 0 0 0 2 2h3 M16 21h3a2 2 0 0 0 2-2v-3';
  static const trash =
      'M3 6h18 M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6 M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2 M10 11v6 M14 11v6';
  static const x = 'M18 6 6 18 M6 6l12 12';
}

abstract final class NodeCatalog {
  static const statuses = [
    'any',
    'intake',
    'diagnosis',
    'waiting_parts',
    'in_repair',
    'quality_check',
    'ready',
    'collected',
    'cancelled',
  ];

  static const nodeWidth = 224.0;

  static final categories = <NodeCategory, CategoryStyle>{
    NodeCategory.trigger: const CategoryStyle(
      label: 'Trigger',
      color: FsColors.blue600,
    ),
    NodeCategory.ops: const CategoryStyle(
      label: 'Repair Op',
      color: FsColors.orange500,
    ),
    NodeCategory.msg: const CategoryStyle(
      label: 'Message',
      color: FsColors.green600,
    ),
    NodeCategory.ai: const CategoryStyle(
      label: 'AI Step',
      gradient: FsColors.aiChipGradient,
    ),
    NodeCategory.logic: const CategoryStyle(
      label: 'Logic',
      color: FsColors.slate600,
    ),
  };

  static final types = <String, NodeTypeDef>{
    'status_changed': NodeTypeDef(
      id: 'status_changed',
      name: 'Status Changed',
      category: NodeCategory.trigger,
      iconPath: Ic.tag,
      description: 'Fires when a job changes status',
      fields: const [
        FieldDef(
          key: 'from',
          label: 'From status',
          type: FieldType.select,
          options: statuses,
        ),
        FieldDef(
          key: 'to',
          label: 'To status',
          type: FieldType.select,
          options: statuses,
        ),
      ],
      summary: (c) => '${c['from'] ?? 'any'} → ${c['to'] ?? 'any'}',
    ),
    'schedule': NodeTypeDef(
      id: 'schedule',
      name: 'Schedule',
      category: NodeCategory.trigger,
      iconPath: Ic.clock,
      description: 'Runs on a timer',
      fields: const [
        FieldDef(
          key: 'every',
          label: 'Repeat',
          type: FieldType.select,
          options: ['every 15 min', 'hourly', 'daily 9:00', 'weekly Mon'],
        ),
      ],
      summary: (c) => c['every'] ?? '',
    ),
    'api_event': NodeTypeDef(
      id: 'api_event',
      name: 'API Event',
      category: NodeCategory.trigger,
      iconPath: Ic.zap,
      description: 'Fires on a custom webhook',
      fields: const [
        FieldDef(key: 'event', label: 'Event name', type: FieldType.text),
      ],
      summary: (c) => c['event'] ?? '',
    ),
    'update_status': NodeTypeDef(
      id: 'update_status',
      name: 'Update Status',
      category: NodeCategory.ops,
      iconPath: Ic.refresh,
      description: 'Move the job in the pipeline',
      fields: [
        FieldDef(
          key: 'to',
          label: 'Set status to',
          type: FieldType.select,
          options: statuses.sublist(1),
        ),
      ],
      summary: (c) => c['to'] != null && c['to']!.isNotEmpty
          ? 'status → ${c['to']}'
          : '',
    ),
    'order_part': NodeTypeDef(
      id: 'order_part',
      name: 'Order Part',
      category: NodeCategory.ops,
      iconPath: Ic.pkg,
      description: 'Create a purchase order',
      fields: const [
        FieldDef(key: 'part', label: 'Part / SKU', type: FieldType.text),
        FieldDef(
          key: 'supplier',
          label: 'Supplier',
          type: FieldType.select,
          options: [
            'MobileSentrix',
            'Injured Gadgets',
            'iFixit Pro',
            'Local stock',
          ],
        ),
      ],
      summary: (c) => c['part'] ?? '',
    ),
    'assign_tech': NodeTypeDef(
      id: 'assign_tech',
      name: 'Assign Tech',
      category: NodeCategory.ops,
      iconPath: Ic.user,
      description: 'Route the job to a technician',
      fields: const [
        FieldDef(
          key: 'tech',
          label: 'Technician',
          type: FieldType.select,
          options: ['Auto (least busy)', 'Maya K.', 'Jonas F.', 'Priya S.'],
        ),
      ],
      summary: (c) => c['tech'] ?? '',
    ),
    'notify_customer': NodeTypeDef(
      id: 'notify_customer',
      name: 'Notify Customer',
      category: NodeCategory.msg,
      iconPath: Ic.bell,
      description: 'SMS, email or push',
      fields: const [
        FieldDef(
          key: 'channel',
          label: 'Channel',
          type: FieldType.select,
          options: ['SMS', 'Email', 'Push'],
        ),
        FieldDef(
          key: 'template',
          label: 'Message template',
          type: FieldType.textarea,
        ),
      ],
      summary: (c) =>
          c['channel'] != null && c['channel']!.isNotEmpty
              ? 'via ${c['channel']}'
              : '',
    ),
    'send_email': NodeTypeDef(
      id: 'send_email',
      name: 'Send Email',
      category: NodeCategory.msg,
      iconPath: Ic.mail,
      description: 'Templated email to anyone',
      fields: const [
        FieldDef(key: 'to', label: 'To', type: FieldType.text),
        FieldDef(key: 'subject', label: 'Subject', type: FieldType.text),
        FieldDef(key: 'body', label: 'Body', type: FieldType.textarea),
      ],
      summary: (c) => c['subject'] ?? '',
    ),
    'canned_message': NodeTypeDef(
      id: 'canned_message',
      name: 'Canned Message',
      category: NodeCategory.msg,
      iconPath: Ic.msg,
      description: 'Reusable saved reply',
      fields: const [
        FieldDef(
          key: 'msg',
          label: 'Canned message',
          type: FieldType.select,
          options: [
            'Ready for pickup',
            'Part delayed',
            'Quote approval needed',
            'Thanks & review',
          ],
        ),
      ],
      summary: (c) => c['msg'] ?? '',
    ),
    'ai_parse': NodeTypeDef(
      id: 'ai_parse',
      name: 'AI Parse',
      category: NodeCategory.ai,
      iconPath: Ic.scan,
      description: 'Extract fields from free text',
      ai: true,
      fields: const [
        FieldDef(
          key: 'inst',
          label: 'What to extract',
          type: FieldType.textarea,
        ),
      ],
      summary: (_) => 'extract fields',
    ),
    'ai_classify': NodeTypeDef(
      id: 'ai_classify',
      name: 'AI Classify',
      category: NodeCategory.ai,
      iconPath: Ic.shuffle,
      description: 'Route by predicted label',
      ai: true,
      fields: const [
        FieldDef(
          key: 'classes',
          label: 'Classes (comma-separated)',
          type: FieldType.text,
        ),
      ],
      summary: (c) => c['classes'] ?? '',
    ),
    'ai_generate': NodeTypeDef(
      id: 'ai_generate',
      name: 'AI Generate',
      category: NodeCategory.ai,
      iconPath: Ic.spark,
      description: 'Draft a message with AI',
      ai: true,
      fields: const [
        FieldDef(key: 'prompt', label: 'Prompt', type: FieldType.textarea),
        FieldDef(
          key: 'tone',
          label: 'Tone',
          type: FieldType.select,
          options: ['Friendly', 'Neutral', 'Formal'],
        ),
      ],
      summary: (c) => '${c['tone'] ?? 'Friendly'} tone',
    ),
    'condition': NodeTypeDef(
      id: 'condition',
      name: 'Condition',
      category: NodeCategory.logic,
      iconPath: Ic.branch,
      description: 'Branch on an expression',
      outs: const ['true', 'false'],
      fields: const [
        FieldDef(key: 'expr', label: 'Expression', type: FieldType.code),
      ],
      summary: (c) => c['expr'] ?? '',
    ),
    'filter': NodeTypeDef(
      id: 'filter',
      name: 'Filter',
      category: NodeCategory.logic,
      iconPath: Ic.filter,
      description: 'Continue only when true',
      fields: const [
        FieldDef(key: 'expr', label: 'Keep when', type: FieldType.code),
      ],
      summary: (c) => c['expr'] ?? '',
    ),
    'delay': NodeTypeDef(
      id: 'delay',
      name: 'Delay',
      category: NodeCategory.logic,
      iconPath: Ic.clock,
      description: 'Wait before the next step',
      fields: const [
        FieldDef(key: 'amount', label: 'Wait', type: FieldType.text),
        FieldDef(
          key: 'unit',
          label: 'Unit',
          type: FieldType.select,
          options: ['minutes', 'hours', 'days'],
        ),
      ],
      summary: (c) => '${c['amount'] ?? ''} ${c['unit'] ?? ''}'.trim(),
    ),
    'json_formula': NodeTypeDef(
      id: 'json_formula',
      name: 'JSON Formula',
      category: NodeCategory.logic,
      iconPath: Ic.braces,
      description: 'Transform data with a formula',
      fields: const [
        FieldDef(
          key: 'formula',
          label: 'Formula (JSON)',
          type: FieldType.code,
        ),
      ],
      summary: (_) => '{ … }',
    ),
  };

  static const groups = <({String label, List<String> items})>[
    (label: 'Triggers', items: ['status_changed', 'schedule', 'api_event']),
    (
      label: 'Repair Ops',
      items: ['update_status', 'order_part', 'assign_tech'],
    ),
    (
      label: 'Messaging',
      items: ['notify_customer', 'send_email', 'canned_message'],
    ),
    (label: 'AI Steps', items: ['ai_parse', 'ai_classify', 'ai_generate']),
    (
      label: 'Logic & Control',
      items: ['condition', 'filter', 'delay', 'json_formula'],
    ),
  ];

  static NodeTypeDef typeOf(String id) => types[id]!;

  static CategoryStyle categoryOf(NodeCategory cat) => categories[cat]!;

  static List<OutSpec> outSpecs(String typeId) {
    final outs = types[typeId]!.outs;
    if (outs == null || outs.isEmpty) {
      return const [OutSpec(cy: 42)];
    }
    final centers = outs.length == 2 ? const [33.0, 59.0] : [42.0];
    return [
      for (var i = 0; i < outs.length; i++)
        OutSpec(label: outs[i], cy: centers[i.clamp(0, centers.length - 1)]),
    ];
  }

  static Offset outPos(FlowNode n, int i) =>
      Offset(n.x + nodeWidth, n.y + outSpecs(n.type)[i].cy);

  static Offset inPos(FlowNode n) => Offset(n.x, n.y + 42);

  static Map<String, String> defaultConfig(String typeId) {
    final cfg = <String, String>{};
    for (final f in types[typeId]!.fields) {
      if (f.type == FieldType.select && f.options.isNotEmpty) {
        cfg[f.key] = f.options.first;
      }
    }
    return cfg;
  }

  static List<FlowNode> demoNodes() => [
        FlowNode(
          id: 'n1',
          type: 'status_changed',
          x: 70,
          y: 170,
          config: {'from': 'any', 'to': 'ready'},
        ),
        FlowNode(
          id: 'n2',
          type: 'condition',
          x: 370,
          y: 170,
          config: {'expr': 'job.balance_due == 0'},
        ),
        FlowNode(
          id: 'n3',
          type: 'ai_generate',
          x: 680,
          y: 60,
          config: {
            'prompt': 'Write a short pickup message with shop hours.',
            'tone': 'Friendly',
          },
        ),
        FlowNode(
          id: 'n4',
          type: 'notify_customer',
          x: 990,
          y: 60,
          config: {
            'channel': 'SMS',
            'template':
                'Hi {customer.first_name}, your {job.device} is ready for pickup!',
          },
        ),
        FlowNode(
          id: 'n5',
          type: 'delay',
          x: 680,
          y: 300,
          config: {'amount': '24', 'unit': 'hours'},
        ),
        FlowNode(
          id: 'n6',
          type: 'send_email',
          x: 990,
          y: 300,
          config: {
            'to': '{customer.email}',
            'subject': 'Balance due before pickup',
            'body': '',
          },
        ),
      ];

  static List<FlowWire> demoWires() => [
        FlowWire(id: 'w1', from: 'n1', port: 0, to: 'n2'),
        FlowWire(id: 'w2', from: 'n2', port: 0, to: 'n3'),
        FlowWire(id: 'w3', from: 'n3', port: 0, to: 'n4'),
        FlowWire(id: 'w4', from: 'n2', port: 1, to: 'n5'),
        FlowWire(id: 'w5', from: 'n5', port: 0, to: 'n6'),
      ];
}
