import 'package:flutter_test/flutter_test.dart';
import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/domain/records.dart';
import 'package:autoflow/features/builder/canvas/port_geometry.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

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

  test('if-else output ports sit on different Y', () {
    final type = buildDefaultCatalog().find('if-else')!;
    final node = CanvasNode(iid: 'n', def: type.asDef, x: 100, y: 80);
    final t = PortGeometry.output(node, 'true', type);
    final f = PortGeometry.output(node, 'false', type);
    expect(t.dx, f.dx);
    expect(t.dy, isNot(f.dy));
    expect(PortGeometry.nodeHeight(type), greaterThan(AnchorSpacing.nodeHeight));
  });
}
