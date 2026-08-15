import 'package:flutter_test/flutter_test.dart';
import 'package:autoflow/data/workflow_repository.dart';
import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/demo_workflow.dart';
import 'package:autoflow/domain/palette.dart';
import 'package:autoflow/features/run/expression_evaluator.dart';
import 'package:autoflow/features/run/simulation_engine.dart';

void main() {
  test('default catalog covers triggers actions and code node', () {
    final cat = buildDefaultCatalog();
    expect(cat.types.length, greaterThan(16));
    expect(cat.find('message.received'), isNotNull);
    expect(cat.find('ticket.status_changed'), isNotNull);
    expect(cat.find('code'), isNotNull);
    expect(cat.find('canned_message.selected'), isNotNull);
    expect(cat.find('purchase_order.received'), isNotNull);
    expect(cat.find('device.received'), isNotNull);
    expect(cat.find('spare_part.received'), isNotNull);
    expect(cat.find('ticket.created'), isNotNull);
    expect(cat.find('inventory.low_stock'), isNotNull);
  });

  test('palette derived from catalog', () {
    expect(kPalette.length, buildDefaultCatalog().types.length);
    expect(findPaletteDef('webhook'), isNotNull);
  });

  test('demo workflow wires reference existing nodes', () {
    final doc = createDemoWorkflow();
    expect(doc.version, 2);
    expect(doc.trigger?.type, 'message.received');
    final ids = doc.nodes.map((n) => n.iid).toSet();
    for (final w in doc.wires) {
      expect(ids.contains(w.from), isTrue);
      expect(ids.contains(w.to), isTrue);
    }
  });

  test('simulation engine order for demo graph', () {
    final doc = createDemoWorkflow();
    final order = SimulationEngine().executionOrder(doc.nodes, doc.wires);
    expect(order.first, 'n1');
    expect(order.indexOf('n2'), lessThan(order.indexOf('n3')));
  });

  test('workflow JSON round-trip migrates to v2', () {
    final repo = WorkflowRepository();
    final original = createDemoWorkflow();
    final encoded = repo.encodeWorkflow(original);
    final decoded = repo.decodeWorkflow(encoded);
    expect(decoded.version, 2);
    expect(decoded.name, original.name);
    expect(decoded.nodes.first.typeId, isNotEmpty);
  });

  test('expression evaluator handles comparisons and interpolation', () {
    final ev = ExpressionEvaluator();
    final ctx = {
      'ticket': {'status': 'intake'},
      'customer': {'name': 'Alex'},
    };
    expect(ev.evaluateCondition('{{ticket.status}} == "intake"', ctx), isTrue);
    expect(ev.evaluateCondition('{{ticket.status}} == "done"', ctx), isFalse);
    expect(
      ev.interpolate('Hi {{customer.name}}', ctx),
      'Hi Alex',
    );
  });
}
