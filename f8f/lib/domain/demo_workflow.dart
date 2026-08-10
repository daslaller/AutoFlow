import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/models.dart';

CanvasNode _mk(String typeId, String iid, double x, double y) {
  final type = buildDefaultCatalog().find(typeId)!;
  return CanvasNode(iid: iid, def: type.asDef, x: x, y: y);
}

WorkflowDoc createDemoWorkflow() {
  return WorkflowDoc(
    id: 'flow_demo_onboarding',
    name: 'Customer Onboarding Flow',
    version: 2,
    trigger: const TriggerBinding(
      type: 'message.received',
      filters: {'channel': 'sms'},
    ),
    nodes: [
      _mk('message.received', 'n1', 60, 190),
      _mk('http-req', 'n2', 360, 190),
      _mk('json-map', 'n3', 660, 190),
      _mk('if-else', 'n4', 960, 190),
      _mk('send_message', 'n5', 1260, 80),
      _mk('notify', 'n6', 1260, 310),
    ],
    wires: const [
      Wire(id: 'iw1', from: 'n1', to: 'n2'),
      Wire(id: 'iw2', from: 'n2', to: 'n3'),
      Wire(id: 'iw3', from: 'n3', to: 'n4'),
      Wire(id: 'iw4', from: 'n4', to: 'n5', fromPort: 'true'),
      Wire(id: 'iw5', from: 'n4', to: 'n6', fromPort: 'false'),
    ],
  );
}
