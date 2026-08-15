import 'package:autoflow/domain/models.dart';

/// A concrete shop row the editor can preview against — a ticket, PO,
/// received device, spare part, and so on. Hosts push live rows in; the
/// standalone demo ships a small catalog so Record is never an empty JSON
/// blob.
class DataRecord {
  const DataRecord({
    required this.id,
    required this.collection,
    required this.title,
    this.subtitle = '',
    required this.data,
  });

  final String id;

  /// `ticket`, `purchase_order`, `device`, `spare_part`, `message`.
  final String collection;
  final String title;
  final String subtitle;
  final Map<String, dynamic> data;

  String get collectionLabel => switch (collection) {
        'ticket' => 'Ticket',
        'purchase_order' => 'Purchase order',
        'device' => 'Device',
        'spare_part' => 'Spare part',
        'message' => 'Message',
        _ => collection,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'collection': collection,
        'title': title,
        'subtitle': subtitle,
        'data': data,
      };

  factory DataRecord.fromJson(Map<String, dynamic> json) => DataRecord(
        id: json['id'] as String,
        collection: json['collection'] as String? ?? 'ticket',
        title: json['title'] as String? ?? json['id'] as String,
        subtitle: json['subtitle'] as String? ?? '',
        data: Map<String, dynamic>.from(json['data'] as Map? ?? json),
      );
}

/// Flatten a nested record map into `{{path}}` variables, grouped by the
/// top-level key (`ticket`, `customer`, `purchase_order`, …).
VariableSchema schemaFromRecordData(Map<String, dynamic> data) {
  final groups = <VariableGroup>[];
  final loose = <VariableVar>[];

  data.forEach((key, value) {
    if (value is Map) {
      final nested = Map<String, dynamic>.from(value);
      groups.add(
        VariableGroup(
          id: key,
          label: _humanize(key),
          variables: flattenRecordFields(nested, prefix: key),
        ),
      );
    } else {
      loose.add(_varFor(key, value));
    }
  });

  if (loose.isNotEmpty) {
    groups.insert(
      0,
      VariableGroup(id: 'record', label: 'Record', variables: loose),
    );
  }
  return VariableSchema(groups: groups);
}

List<VariableVar> flattenRecordFields(
  Map<String, dynamic> data, {
  String prefix = '',
}) {
  final out = <VariableVar>[];
  data.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map) {
      out.addAll(
        flattenRecordFields(Map<String, dynamic>.from(value), prefix: path),
      );
    } else {
      out.add(_varFor(path, value));
    }
  });
  return out;
}

VariableVar _varFor(String path, dynamic value) {
  final type = switch (value) {
    num() => 'number',
    bool() => 'boolean',
    List() => 'list',
    Map() => 'object',
    _ => 'string',
  };
  return VariableVar(
    path: path,
    label: _humanize(path.split('.').last),
    type: type,
    example: value,
  );
}

String _humanize(String raw) {
  return raw
      .replaceAll('_', ' ')
      .replaceAll('.', ' ')
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// Demo rows shaped like RepairX tickets / POs / assets / part units.
List<DataRecord> buildDefaultPreviewRecords() => [
      DataRecord(
        id: 'rec_ticket_t102',
        collection: 'ticket',
        title: 'T-102 · Screen cracked',
        subtitle: 'iPhone 14 · Alex Kim · intake',
        data: {
          'ticket': {
            'id': 'T-102',
            'status': 'intake',
            'stage': 'intake',
            'assignee': null,
            'title': 'Screen cracked',
            'priority': 'high',
            'device_brand': 'Apple',
            'device_model': 'iPhone 14',
          },
          'customer': {
            'id': 'cust_9',
            'name': 'Alex Kim',
            'email': 'alex@example.com',
            'phone': '+15551212',
          },
          'device': {
            'id': 'ast_14_alex',
            'brand': 'Apple',
            'model': 'iPhone 14',
            'imei': '356938035643809',
          },
          'flow': {'id': 'flow_demo', 'name': 'Customer Onboarding Flow'},
        },
      ),
      DataRecord(
        id: 'rec_ticket_t88',
        collection: 'ticket',
        title: 'T-88 · Battery swelling',
        subtitle: 'Pixel 8 · Sam Ortega · in_progress',
        data: {
          'ticket': {
            'id': 'T-88',
            'status': 'in_progress',
            'stage': 'repair',
            'assignee': 'tech_12',
            'title': 'Battery swelling',
            'priority': 'normal',
            'device_brand': 'Google',
            'device_model': 'Pixel 8',
          },
          'customer': {
            'id': 'cust_4',
            'name': 'Sam Ortega',
            'email': 'sam@example.com',
            'phone': '+15553300',
          },
          'device': {
            'id': 'ast_pixel8_sam',
            'brand': 'Google',
            'model': 'Pixel 8',
            'imei': '353447851234567',
          },
          'flow': {'id': 'flow_demo', 'name': 'Customer Onboarding Flow'},
        },
      ),
      DataRecord(
        id: 'rec_po_1041',
        collection: 'purchase_order',
        title: 'PO-1041 · MobileParts Nordic',
        subtitle: 'Received · 12 lines · 4 820 kr',
        data: {
          'purchase_order': {
            'id': 'po_1041',
            'po_number': 'PO-1041',
            'status': 'received',
            'supplier': 'MobileParts Nordic',
            'supplier_id': 'sup_mpn',
            'total_cost': 4820,
            'line_count': 12,
            'received_at': '2026-08-14T09:12:00Z',
          },
          'supplier': {
            'id': 'sup_mpn',
            'name': 'MobileParts Nordic',
            'email': 'orders@mobileparts.example',
          },
        },
      ),
      DataRecord(
        id: 'rec_po_1033',
        collection: 'purchase_order',
        title: 'PO-1033 · FixHub EU',
        subtitle: 'Partial · 4 of 9 lines in',
        data: {
          'purchase_order': {
            'id': 'po_1033',
            'po_number': 'PO-1033',
            'status': 'partial',
            'supplier': 'FixHub EU',
            'supplier_id': 'sup_fixhub',
            'total_cost': 1910,
            'line_count': 9,
            'received_qty': 4,
          },
          'supplier': {
            'id': 'sup_fixhub',
            'name': 'FixHub EU',
            'email': 'desk@fixhub.example',
          },
        },
      ),
      DataRecord(
        id: 'rec_device_iphone13',
        collection: 'device',
        title: 'iPhone 13 · midnight',
        subtitle: 'Received at intake · IMEI …4401',
        data: {
          'device': {
            'id': 'ast_13_lee',
            'brand': 'Apple',
            'model': 'iPhone 13',
            'colour': 'midnight',
            'imei': '353260071234401',
            'serial': 'F17D4K8JQ1',
            'location': 'store',
            'received_at': '2026-08-15T08:40:00Z',
          },
          'customer': {
            'id': 'cust_21',
            'name': 'Lee Nguyen',
            'phone': '+15557701',
          },
          'ticket': {
            'id': 'T-141',
            'status': 'intake',
            'title': 'No power',
          },
        },
      ),
      DataRecord(
        id: 'rec_device_s23',
        collection: 'device',
        title: 'Galaxy S23 · phantom black',
        subtitle: 'Returning asset · 3 prior repairs',
        data: {
          'device': {
            'id': 'ast_s23_mira',
            'brand': 'Samsung',
            'model': 'Galaxy S23',
            'colour': 'phantom black',
            'imei': '359827105598210',
            'serial': 'R58M30ABCDE',
            'location': 'store',
            'repair_count': 3,
            'received_at': '2026-08-15T10:05:00Z',
          },
          'customer': {
            'id': 'cust_7',
            'name': 'Mira Patel',
            'phone': '+15559012',
          },
          'ticket': {
            'id': 'T-150',
            'status': 'intake',
            'title': 'Charging port loose',
          },
        },
      ),
      DataRecord(
        id: 'rec_part_screen14',
        collection: 'spare_part',
        title: 'OEM iPhone 14 screen',
        subtitle: 'SKU SCR-14-OEM · qty 8 received',
        data: {
          'spare_part': {
            'id': 'part_scr14',
            'sku': 'SCR-14-OEM',
            'name': 'OEM iPhone 14 screen',
            'qty_received': 8,
            'on_hand': 14,
            'min_stock': 4,
            'unit_cost': 890,
            'received_at': '2026-08-14T09:20:00Z',
          },
          'purchase_order': {
            'id': 'po_1041',
            'po_number': 'PO-1041',
            'supplier': 'MobileParts Nordic',
          },
        },
      ),
      DataRecord(
        id: 'rec_part_batt_pixel',
        collection: 'spare_part',
        title: 'Pixel 8 battery',
        subtitle: 'SKU BAT-P8 · serialised unit in stock',
        data: {
          'spare_part': {
            'id': 'part_batp8',
            'sku': 'BAT-P8',
            'name': 'Pixel 8 battery',
            'qty_received': 1,
            'on_hand': 3,
            'min_stock': 2,
            'serial': 'BAT-P8-00412',
            'unit_cost': 340,
            'received_at': '2026-08-13T16:02:00Z',
          },
          'purchase_order': {
            'id': 'po_1033',
            'po_number': 'PO-1033',
            'supplier': 'FixHub EU',
          },
        },
      ),
      DataRecord(
        id: 'rec_msg_sms',
        collection: 'message',
        title: 'SMS from +15551212',
        subtitle: 'My screen is cracked',
        data: {
          'message': {
            'body': 'My screen is cracked',
            'channel': 'sms',
            'from': '+15551212',
          },
          'ticket': {
            'id': 'T-102',
            'status': 'intake',
            'title': 'Screen cracked',
          },
          'customer': {
            'id': 'cust_9',
            'name': 'Alex Kim',
            'phone': '+15551212',
          },
        },
      ),
    ];
