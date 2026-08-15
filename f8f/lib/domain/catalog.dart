import 'package:autoflow/domain/models.dart';

FieldDef _text(String key, String label, String ph, {bool required = false}) =>
    FieldDef(
      key: key,
      label: label,
      type: FieldType.text,
      placeholder: ph,
      required: required,
    );

FieldDef _area(String key, String label, String ph) => FieldDef(
      key: key,
      label: label,
      type: FieldType.textarea,
      placeholder: ph,
    );

FieldDef _code(String key, String label) => FieldDef(
      key: key,
      label: label,
      type: FieldType.code,
      placeholder: 'return data;',
      codeLanguage: CodeLanguage.expression,
    );

FieldDef _select(
  String key,
  String label,
  List<FieldOption> options,
) =>
    FieldDef(
      key: key,
      label: label,
      type: FieldType.select,
      options: options,
    );

/// Default generic + RepairX-oriented catalog.
NodeCatalog buildDefaultCatalog() {
  const inPort = [PortDef(id: 'in', label: 'In')];
  const outPort = [PortDef(id: 'out', label: 'Out')];
  const branchOut = [
    PortDef(id: 'true', label: 'True'),
    PortDef(id: 'false', label: 'False'),
  ];

  return NodeCatalog(
    version: '2',
    types: [
      // Generic triggers
      NodeTypeDef(
        id: 'webhook',
        kind: NodeKind.trigger,
        label: 'Webhook',
        sublabel: 'Receive HTTP requests',
        iconKey: 'zap',
        inputs: const [],
        outputs: outPort,
        fields: [
          _text('path', 'Path', '/webhook/trigger', required: true),
          _text('method', 'Method', 'POST'),
        ],
        trigger: const TriggerBinding(type: 'webhook'),
        produces: ['request.body', 'request.headers'],
      ),
      NodeTypeDef(
        id: 'schedule',
        kind: NodeKind.trigger,
        label: 'Schedule',
        sublabel: 'Cron-based timing',
        iconKey: 'zap',
        inputs: const [],
        outputs: outPort,
        fields: [
          _text('cron', 'Cron Expression', '0 */5 * * *', required: true),
          _text('tz', 'Timezone', 'UTC'),
        ],
        trigger: const TriggerBinding(type: 'schedule'),
      ),
      NodeTypeDef(
        id: 'api-poll',
        kind: NodeKind.trigger,
        label: 'API Poll',
        sublabel: 'Watch external endpoint',
        iconKey: 'zap',
        inputs: const [],
        outputs: outPort,
        fields: [
          _text('url', 'URL', 'https://api.example.com/status', required: true),
          _text('interval', 'Interval', '30s'),
        ],
        trigger: const TriggerBinding(type: 'api.poll'),
      ),
      NodeTypeDef(
        id: 'manual',
        kind: NodeKind.trigger,
        label: 'Manual',
        sublabel: 'Preview / test only',
        iconKey: 'zap',
        inputs: const [],
        outputs: outPort,
        fields: const [],
        trigger: const TriggerBinding(type: 'manual'),
      ),
      // RepairX triggers
      NodeTypeDef(
        id: 'message.received',
        kind: NodeKind.trigger,
        label: 'Message Received',
        sublabel: 'Inbound SMS / chat / email',
        iconKey: 'zap',
        inputs: const [],
        outputs: outPort,
        fields: [
          _select('channel', 'Channel', [
            FieldOption(value: 'any', label: 'Any'),
            FieldOption(value: 'sms', label: 'SMS'),
            FieldOption(value: 'chat', label: 'Chat'),
            FieldOption(value: 'email', label: 'Email'),
          ]),
        ],
        trigger: const TriggerBinding(type: 'message.received'),
        produces: ['message', 'ticket', 'customer'],
      ),
      NodeTypeDef(
        id: 'canned_message.selected',
        kind: NodeKind.trigger,
        label: 'Canned Message',
        sublabel: 'When a canned reply is chosen',
        iconKey: 'zap',
        inputs: const [],
        outputs: outPort,
        fields: [
          _text('cannedId', 'Canned ID', 'canned_welcome'),
          FieldDef(
            key: 'anyLinked',
            label: 'Any flow-linked canned',
            type: FieldType.toggle,
            defaultValue: 'false',
          ),
        ],
        trigger: const TriggerBinding(type: 'canned_message.selected'),
        produces: ['canned', 'ticket', 'message'],
      ),
      NodeTypeDef(
        id: 'ticket.status_changed',
        kind: NodeKind.trigger,
        label: 'Status Changed',
        sublabel: 'Ticket status transition',
        iconKey: 'zap',
        inputs: const [],
        outputs: outPort,
        fields: [
          FieldDef(
            key: 'statusFrom',
            label: 'From status',
            type: FieldType.statusEnum,
            placeholder: 'intake',
          ),
          FieldDef(
            key: 'statusTo',
            label: 'To status',
            type: FieldType.statusEnum,
            placeholder: 'in_progress',
            required: true,
          ),
        ],
        trigger: const TriggerBinding(type: 'ticket.status_changed'),
        produces: ['ticket', 'status.from', 'status.to'],
      ),
      NodeTypeDef(
        id: 'ticket.created',
        kind: NodeKind.trigger,
        label: 'Ticket Created',
        sublabel: 'New repair ticket opened',
        iconKey: 'zap',
        inputs: const [],
        outputs: outPort,
        fields: [
          _select('priority', 'Priority', [
            FieldOption(value: 'any', label: 'Any'),
            FieldOption(value: 'low', label: 'Low'),
            FieldOption(value: 'normal', label: 'Normal'),
            FieldOption(value: 'high', label: 'High'),
          ]),
        ],
        trigger: const TriggerBinding(type: 'ticket.created'),
        produces: ['ticket', 'customer', 'device'],
      ),
      NodeTypeDef(
        id: 'purchase_order.received',
        kind: NodeKind.trigger,
        label: 'Received Purchase Order',
        sublabel: 'Supplier delivery booked in',
        iconKey: 'zap',
        inputs: const [],
        outputs: outPort,
        fields: [
          _text('supplierId', 'Supplier ID', 'any'),
          FieldDef(
            key: 'partialOk',
            label: 'Include partial receipts',
            type: FieldType.toggle,
            defaultValue: 'true',
          ),
        ],
        trigger: const TriggerBinding(type: 'purchase_order.received'),
        produces: ['purchase_order', 'supplier'],
      ),
      NodeTypeDef(
        id: 'device.received',
        kind: NodeKind.trigger,
        label: 'Received Device',
        sublabel: 'Customer device at intake',
        iconKey: 'zap',
        inputs: const [],
        outputs: outPort,
        fields: [
          _text('brand', 'Brand filter', 'any'),
        ],
        trigger: const TriggerBinding(type: 'device.received'),
        produces: ['device', 'customer', 'ticket'],
      ),
      NodeTypeDef(
        id: 'spare_part.received',
        kind: NodeKind.trigger,
        label: 'Received Spare Part',
        sublabel: 'Stock unit arrived',
        iconKey: 'zap',
        inputs: const [],
        outputs: outPort,
        fields: [
          _text('sku', 'SKU filter', 'any'),
        ],
        trigger: const TriggerBinding(type: 'spare_part.received'),
        produces: ['spare_part', 'purchase_order'],
      ),
      NodeTypeDef(
        id: 'inventory.low_stock',
        kind: NodeKind.trigger,
        label: 'Low Stock',
        sublabel: 'Part below reorder point',
        iconKey: 'zap',
        inputs: const [],
        outputs: outPort,
        fields: [
          _text('sku', 'SKU filter', 'any'),
        ],
        trigger: const TriggerBinding(type: 'inventory.low_stock'),
        produces: ['spare_part'],
      ),
      // Actions
      NodeTypeDef(
        id: 'http-req',
        kind: NodeKind.action,
        label: 'HTTP Request',
        sublabel: 'Outbound API call',
        inputs: inPort,
        outputs: outPort,
        fields: [
          _text('url', 'URL', 'https://api.example.com/data', required: true),
          _text('method', 'Method', 'GET'),
          _area('body', 'Body', '{ "key": "{{value}}" }'),
        ],
        produces: ['http.response'],
      ),
      NodeTypeDef(
        id: 'db-query',
        kind: NodeKind.action,
        label: 'Database',
        sublabel: 'SQL / NoSQL query',
        inputs: inPort,
        outputs: outPort,
        fields: [
          _text('conn', 'Connection', 'postgres://user:pass@host/db'),
          _area('query', 'Query', 'SELECT * FROM users WHERE active = true'),
        ],
      ),
      NodeTypeDef(
        id: 'send-email',
        kind: NodeKind.action,
        label: 'Send Email',
        sublabel: 'SMTP delivery',
        inputs: inPort,
        outputs: outPort,
        fields: [
          _text('to', 'To', 'user@example.com', required: true),
          _text('subject', 'Subject', 'Automated Report — {{date}}'),
        ],
      ),
      NodeTypeDef(
        id: 'slack',
        kind: NodeKind.action,
        label: 'Slack',
        sublabel: 'Post to channel',
        inputs: inPort,
        outputs: outPort,
        fields: [
          _text('channel', 'Channel', '#alerts'),
          _area('message', 'Message', '{{data.summary}}'),
        ],
      ),
      NodeTypeDef(
        id: 'send_message',
        kind: NodeKind.action,
        label: 'Send Message',
        sublabel: 'Reply on ticket channel',
        inputs: inPort,
        outputs: outPort,
        fields: [
          FieldDef(
            key: 'body',
            label: 'Message',
            type: FieldType.template,
            placeholder: 'Thanks {{customer.name}}!',
            required: true,
          ),
          _select('channel', 'Channel', [
            FieldOption(value: 'same', label: 'Same as inbound'),
            FieldOption(value: 'sms', label: 'SMS'),
            FieldOption(value: 'email', label: 'Email'),
          ]),
        ],
      ),
      NodeTypeDef(
        id: 'send_canned_message',
        kind: NodeKind.action,
        label: 'Send Canned',
        sublabel: 'Send a canned reply',
        inputs: inPort,
        outputs: outPort,
        fields: [
          _text('cannedId', 'Canned ID', 'canned_eta', required: true),
        ],
      ),
      NodeTypeDef(
        id: 'update_ticket_status',
        kind: NodeKind.action,
        label: 'Update Status',
        sublabel: 'Set ticket status',
        inputs: inPort,
        outputs: outPort,
        fields: [
          FieldDef(
            key: 'status',
            label: 'Status',
            type: FieldType.statusEnum,
            placeholder: 'in_progress',
            required: true,
          ),
        ],
        produces: ['ticket.status'],
      ),
      NodeTypeDef(
        id: 'assign_tech',
        kind: NodeKind.action,
        label: 'Assign Tech',
        sublabel: 'Assign technician',
        inputs: inPort,
        outputs: outPort,
        fields: [
          _text('techId', 'Tech ID', 'tech_12'),
          FieldDef(
            key: 'techVar',
            label: 'Or variable',
            type: FieldType.variablePicker,
            placeholder: 'ticket.assignee',
          ),
        ],
      ),
      NodeTypeDef(
        id: 'add_note',
        kind: NodeKind.action,
        label: 'Add Note',
        sublabel: 'Internal ticket note',
        inputs: inPort,
        outputs: outPort,
        fields: [
          _area('note', 'Note', 'Customer reported…'),
        ],
      ),
      // Logic
      NodeTypeDef(
        id: 'if-else',
        kind: NodeKind.condition,
        label: 'If / Else',
        sublabel: 'Conditional branch',
        inputs: inPort,
        outputs: branchOut,
        fields: [
          FieldDef(
            key: 'condition',
            label: 'Condition',
            type: FieldType.text,
            placeholder: '{{ticket.status}} == "intake"',
          ),
        ],
      ),
      NodeTypeDef(
        id: 'switch',
        kind: NodeKind.condition,
        label: 'Switch',
        sublabel: 'Multi-case routing',
        inputs: inPort,
        outputs: outPort,
        fields: [
          _text('expr', 'Expression', '{{data.type}}'),
        ],
      ),
      NodeTypeDef(
        id: 'loop',
        kind: NodeKind.condition,
        label: 'Loop',
        sublabel: 'Iterate over list',
        inputs: inPort,
        outputs: outPort,
        fields: [
          FieldDef(
            key: 'items',
            label: 'Items',
            type: FieldType.variablePicker,
            placeholder: '{{data.records}}',
          ),
        ],
      ),
      NodeTypeDef(
        id: 'delay',
        kind: NodeKind.condition,
        label: 'Delay',
        sublabel: 'Wait before continuing',
        inputs: inPort,
        outputs: outPort,
        fields: [
          _text('duration', 'Duration', '5m', required: true),
        ],
      ),
      // Transform
      NodeTypeDef(
        id: 'json-map',
        kind: NodeKind.transform,
        label: 'JSON Map',
        sublabel: 'Reshape data structure',
        inputs: inPort,
        outputs: outPort,
        fields: [
          _area('template', 'Template', '{ "id": "{{id}}", "name": "{{name}}" }'),
        ],
      ),
      NodeTypeDef(
        id: 'field-map',
        kind: NodeKind.transform,
        label: 'Field Mapper',
        sublabel: 'Map input fields',
        inputs: inPort,
        outputs: outPort,
        fields: [
          _area('mapping', 'Mapping', 'source.field → target.field'),
        ],
      ),
      NodeTypeDef(
        id: 'code',
        kind: NodeKind.transform,
        label: 'Code',
        sublabel: 'Expression / JS / Dart snippet',
        inputs: inPort,
        outputs: outPort,
        fields: [
          _select('lang', 'Language', [
            FieldOption(value: 'expression', label: 'Expression'),
            FieldOption(value: 'javascript', label: 'JavaScript'),
            FieldOption(value: 'dart_snippet', label: 'Dart snippet'),
          ]),
          _code('code', 'Script'),
          _text('timeoutMs', 'Timeout (ms)', '2000'),
        ],
        produces: ['result'],
      ),
      // Outputs
      NodeTypeDef(
        id: 'http-resp',
        kind: NodeKind.output,
        label: 'HTTP Response',
        sublabel: 'Return API response',
        inputs: inPort,
        outputs: const [],
        fields: [
          _text('status', 'Status Code', '200'),
          _area('body', 'Body', '{{data}}'),
        ],
      ),
      NodeTypeDef(
        id: 'file-write',
        kind: NodeKind.output,
        label: 'File Write',
        sublabel: 'Write to storage',
        inputs: inPort,
        outputs: const [],
        fields: [
          _text('path', 'Path', '/output/{{date}}.json'),
        ],
      ),
      NodeTypeDef(
        id: 'notify',
        kind: NodeKind.output,
        label: 'Notify',
        sublabel: 'Push notification',
        inputs: inPort,
        outputs: const [],
        fields: [
          _text('title', 'Title', 'Workflow Complete'),
          _area('message', 'Message', '{{data.summary}}'),
        ],
      ),
    ],
  );
}

/// Alias used by RepairX demos.
NodeCatalog get repairxDemoCatalog => buildDefaultCatalog();
