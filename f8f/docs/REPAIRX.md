# RepairX integration playbook

How RepairX (or another Flutter host) embeds AutoFlow. Preview execution is
documented in `ENGINE.md`; this page is the host-side wiring.

## 1. Depend on AutoFlow

```yaml
dependencies:
  fl_nodes_visual_scripting:
    git:
      url: https://github.com/daslaller/HeidNodes
      path: packages/fl_nodes_visual_scripting
  autoflow:
    git:
      url: https://github.com/daslaller/F8F
      path: f8f

dependency_overrides:
  fl_nodes_core:
    git:
      url: https://github.com/daslaller/HeidNodes
      path: packages/fl_nodes_core
```

(`fl_nodes_core`'s `dependency_overrides` entry is needed because
`fl_nodes_visual_scripting` resolves it via HeidNodes' own pub workspace,
which only works for consumers *inside* that workspace — see this
package's own `pubspec.yaml` for the same pattern, one level up.)

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

⚠️ **Illustrative pseudocode, not real infrastructure.** `bus`, `index`, and
`runtime` below name no classes that exist anywhere in RepairX — there is no
generic event-bus abstraction to build. Read this as "the shape of what
needs to happen" (an event arrives → matching saved flows are found → each
one executes), not literal code to write. What RepairX actually built:
`fl_nodes_visual_scripting`'s `AutomationEngine` (the real per-run executor,
see `../ENGINE.md`) wrapped by a small `AutomationRuntime` service, invoked
directly from the *specific* call sites that need it (e.g.
`tickets_service.dart`'s `updateTicket`) — not a speculative pub/sub bus
wired to every possible domain event up front.

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
