# RepairX integration playbook

## 1. Depend on AutoFlow

```yaml
dependencies:
  autoflow:
    path: ../f8f/f8f-figma   # or git / pub
```

## 2. Flows screen

```dart
class FlowsEditorPage extends StatefulWidget {
  const FlowsEditorPage({super.key, required this.flowId});
  final String flowId;
  @override
  State<FlowsEditorPage> createState() => _FlowsEditorPageState();
}

class _FlowsEditorPageState extends State<FlowsEditorPage> {
  final controller = AutoFlowController();
  NodeCatalog? catalog;
  VariableSchema? variables;
  WorkflowDoc? doc;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = NodeCatalog.fromJson(await api.getNodeCatalog());
    final v = VariableSchema.fromJson(await api.getVariables());
    final d = /* decode */ await api.getFlow(widget.flowId);
    setState(() {
      catalog = c;
      variables = v;
      doc = d;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (doc == null || catalog == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return AutoFlowBuilder(
      controller: controller,
      catalog: catalog!,
      variables: variables!,
      initialWorkflow: doc!,
      chrome: EmbedChrome.minimal,
      sampleRecord: lastTicketPayload,
      callbacks: AutoFlowCallbacks(
        onWorkflowChanged: (w) => api.putFlowDebounced(w.toJson()),
        onTriggerConfigured: (b) => api.reindexTrigger(widget.flowId, b),
        onRequestCodePreview: repairxCodeSandbox,
      ),
    );
  }
}
```

## 3. Event bus → runtime

```dart
bus.on<MessageReceived>((e) {
  final flows = index.match(type: 'message.received', filters: {
    'channel': e.channel,
  });
  for (final flow in flows) {
    runtime.execute(flow, payload: e.toJson());
  }
});

bus.on<TicketStatusChanged>((e) {
  final flows = index.match(type: 'ticket.status_changed', filters: {
    'statusFrom': e.from,
    'statusTo': e.to,
  });
  ...
});

bus.on<CannedSelected>((e) {
  if (e.flowId != null) runtime.executeById(e.flowId!, payload: e.toJson());
});
```

## 4. QA matrix

- [ ] Create flow from inbound SMS trigger; preview with sample record
- [ ] Status intake → in_progress updates ticket via action node
- [ ] Canned message with `flowId` opens / runs correct flow
- [ ] Host `setCatalog` adds a custom node without rebuilding AutoFlow
- [ ] Unknown `typeId` shows validation badge
- [ ] Code node preview via host callback
- [ ] Snap-to-grid toggle + undo after move
- [ ] Export/import JSON round-trip v2

## 5. Status color mapping

Reuse Anchor semantic status tokens (`backlog`, `triage`, `in_progress`, `done`, …) when rendering ticket status in RepairX so the flow builder and ops UI stay consistent.
