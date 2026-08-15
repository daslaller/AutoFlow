import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/port_geometry.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('if-else true and false ports sit on different anchors', () {
    final type = buildDefaultCatalog().find('if-else')!;
    final node = CanvasNode(iid: 'n', def: type.asDef, x: 40, y: 80);
    final t = PortGeometry.output(node, 'true', type);
    final f = PortGeometry.output(node, 'false', type);
    expect(t.dx, f.dx);
    expect(t.dy, isNot(equals(f.dy)));
  });

  test('dragging wires both if-else outputs independently', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(workflowProvider.notifier);

    for (var i = 0; i < 20 && !container.read(workflowProvider).ready; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    final cat = buildDefaultCatalog();
    ctrl.replaceWorkflow(
      WorkflowDoc(
        name: 'branch',
        nodes: [
          CanvasNode(iid: 'branch', def: cat.find('if-else')!.asDef, x: 0, y: 0),
          CanvasNode(
            iid: 'onTrue',
            def: cat.find('send_message')!.asDef,
            x: 240,
            y: 0,
          ),
          CanvasNode(
            iid: 'onFalse',
            def: cat.find('notify')!.asDef,
            x: 240,
            y: 120,
          ),
        ],
        wires: const [],
      ),
    );

    ctrl.startDrawingWire('branch', 10, 10, fromPort: 'true');
    ctrl.finishDrawingWire('onTrue');
    ctrl.startDrawingWire('branch', 10, 40, fromPort: 'false');
    ctrl.finishDrawingWire('onFalse');

    final wires = container.read(workflowProvider).doc.wires;
    expect(
      wires.where((w) => w.fromPort == 'true' && w.to == 'onTrue'),
      hasLength(1),
    );
    expect(
      wires.where((w) => w.fromPort == 'false' && w.to == 'onFalse'),
      hasLength(1),
    );
  });
}
