import 'package:flutter_test/flutter_test.dart';
import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/records.dart';
import 'package:autoflow/features/builder/canvas/heid_graph.dart';
import 'package:autoflow/features/builder/canvas/heid_prototypes.dart';

void main() {
  test('demo records cover shop collections', () {
    final records = buildDefaultPreviewRecords();
    final collections = records.map((r) => r.collection).toSet();
    expect(
      collections,
      containsAll([
        'ticket',
        'purchase_order',
        'device',
        'spare_part',
        'message',
      ]),
    );
  });

  test('selecting a record flattens fields into variables', () {
    final rec = buildDefaultPreviewRecords()
        .firstWhere((r) => r.collection == 'purchase_order');
    final schema = schemaFromRecordData(rec.data);
    final paths = schema.groups.expand((g) => g.variables).map((v) => v.path);
    expect(paths, contains('purchase_order.po_number'));
    expect(paths, contains('purchase_order.status'));
    expect(paths, contains('supplier.name'));
    final poNumber = schema.groups
        .expand((g) => g.variables)
        .firstWhere((v) => v.path == 'purchase_order.po_number');
    expect(poNumber.example, 'PO-1041');
  });

  test('if-else declares separate true and false control outputs', () {
    final catalog = buildDefaultCatalog();
    final graph = HeidGraph(
      catalog: catalog,
      session: PreviewSession(),
      snapToGrid: false,
    );
    addTearDown(graph.dispose);
    final proto = graph.controller.nodePrototypes['if-else']!;
    final ids = proto.portPrototypes.map((p) => p.idName).toSet();
    expect(ids, containsAll({'true', 'false', 'in'}));
  });
}
