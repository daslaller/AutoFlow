# AutoFlow Host API

AutoFlow is an **embeddable workflow designer**. RepairX (or any host) owns production execution; AutoFlow owns design, validation, and in-editor **Preview**.

> ⚠️ **2026-08-10 update — read `../ENGINE.md` first.** Preview's execution
> is now backed by `daslaller/HeidNodes`' `fl_nodes_core`, not a hand-rolled
> topological walk — the practical effect is that an `if-else` node's
> untaken branch genuinely never runs in Preview anymore (it used to). The
> canvas below is unchanged. `../ENGINE.md` also documents a new host-theme
> injection point (`AnchorColors.active`) — see "Theming" below.

## Engine (canvas)

Custom Flutter canvas (no Flame / React Flow) — **rendering/interaction
only**; see `../ENGINE.md` for the execution engine underneath Preview:

- Viewport: matrix pan/zoom + pointer hit-testing
- Wires: antialiased `CustomPainter` Beziers
- Nodes: positioned widgets
- State: Riverpod + `AutoFlowController`

## Theming

`lib/theme/anchor_colors.dart`'s semantic tokens (`AnchorColors.primary`,
`.accent`, `.success`, the five node-kind accents, status colors, brand
gradients, ...) read from a swappable `AnchorColors.active`
(`AnchorColorsData`) instead of being hardcoded. Set it once, before
mounting `AutoFlowBuilder`:

```dart
AnchorColors.active = AnchorColorsData(
  primary: myHostBrandColor,
  accent: myHostAccentColor,
  // ...every field is required; build from your own design tokens.
);
```

The raw numbered palette (`AnchorColors.slate500`, `.blue50`, ...) stays
fixed — see the doc comment on `_RawPalette` in that file for why.

## Flutter package embed

```dart
import 'package:autoflow/autoflow.dart';

final controller = AutoFlowController();

AutoFlowBuilder(
  controller: controller,
  catalog: catalogFromApi,          // NodeCatalog
  variables: variablesFromApi,      // VariableSchema
  sampleRecord: sampleTicketJson,
  chrome: EmbedChrome.minimal,
  callbacks: AutoFlowCallbacks(
    onWorkflowChanged: (doc) => api.putFlow(doc.toJson()),
    onTriggerConfigured: (binding) => api.indexTrigger(binding.toJson()),
    onRequestCodePreview: (node, ctx) => hostEvalCode(node, ctx),
    onSaveRequested: () => api.flush(),
  ),
)
```

### Controller methods

| Method | Purpose |
|--------|---------|
| `setCatalog(NodeCatalog)` | Hot-swap node shapes from your API |
| `setVariables(VariableSchema)` | Bind variable dictionary |
| `setWorkflow` / `getWorkflow` | Load/save graph |
| `setSampleRecord` | Record used by Preview |
| `startPreview` / `stopPreview` | In-editor simulation |
| `submitInput(payload)` | Set record + optionally preview |
| `configure(embedChrome, readOnly)` | Chrome / lock |
| `workflowStream` / `selectionStream` / `previewStream` / `validationStream` | Observe |

## WorkflowDoc v2

```json
{
  "version": 2,
  "id": "flow_onboard_sms",
  "name": "On SMS received → triage",
  "trigger": {
    "type": "message.received",
    "filters": { "channel": "sms" }
  },
  "nodes": [
    {
      "iid": "n1",
      "typeId": "message.received",
      "x": 60,
      "y": 190,
      "config": { "channel": "sms" }
    }
  ],
  "wires": [
    { "id": "w1", "from": "n1", "fromPort": "out", "to": "n2", "toPort": "in" }
  ],
  "meta": { "updatedAt": "2026-07-17T00:00:00Z" }
}
```

v1 docs (`defId`) still import; repository migrates to v2.

## NodeCatalog

Host ships types (or use `buildDefaultCatalog()` / `repairxDemoCatalog`):

```json
{
  "version": "2",
  "types": [
    {
      "id": "ticket.status_changed",
      "kind": "trigger",
      "label": "Status Changed",
      "sublabel": "Ticket status transition",
      "inputs": [],
      "outputs": [{ "id": "out", "label": "Out" }],
      "fields": [
        { "key": "statusTo", "label": "To status", "type": "statusEnum", "required": true }
      ],
      "trigger": { "type": "ticket.status_changed", "filters": {} },
      "produces": ["ticket", "status.to"]
    }
  ]
}
```

Field types: `text`, `textarea`, `number`, `select`, `toggle`, `json`, `code`, `variablePicker`, `statusEnum`, `template`.

## Suggested host REST

```
GET  /flows/node-catalog
GET  /flows/variables?context=ticket
GET  /flows/{id}
PUT  /flows/{id}
```

AutoFlow does not call HTTP; RepairX fetches and pushes into the controller.

⚠️ **Illustrative, not a real API contract for RepairX specifically.**
RepairX has no REST/custom backend of its own to hang routes like these on —
it talks directly to Appwrite (Databases/Teams API via the Dart SDK). Its
actual adapter is a plain Dart service class
(`AutomationFlowsService`/`AutomationRuntime`, mirroring every other
`*_service.dart` in that codebase), not routes matching this shape. Read
this section as "here's the data a host needs to fetch/push, however it
does that" rather than an API RepairX implements literally.

## Production runtime (RepairX)

```
event (message | status | canned)
  → match flows by doc.trigger / trigger node config
  → load WorkflowDoc
  → execute connectors
  → code nodes → host CodeExecutor
```

AutoFlow does **not** need to be on screen for production runs.

### Trigger types (starter)

| type | When |
|------|------|
| `message.received` | Inbound SMS/chat/email |
| `canned_message.selected` | Canned reply chosen / flow-linked |
| `ticket.status_changed` | Status from→to |
| `webhook` / `schedule` / `manual` | Generic |

### Canned message ↔ flow

- Store `flowId` on canned message entity.
- Emit `canned_message.selected` with `{ cannedId, flowId, ticketId }`.
- Open builder with that flow for editing.

## Preview vs production

| | Preview (AutoFlow) | Production (RepairX) |
|--|--------------------|----------------------|
| Data | Sample **Record** | Live event payload |
| Code nodes | Host `onRequestCodePreview` or expression eval | Host `CodeExecutor` |
| Failures | Soft / evaluated | Real connector errors |

## Web / JS bridge

```js
window.AutoFlow.setCatalog(catalog)
window.AutoFlow.setVariables(schema)
window.AutoFlow.setSampleRecord(record)
window.AutoFlow.setWorkflow(doc)
window.AutoFlow.startPreview()
window.AutoFlow.submitInput({ payload, run: true })
window.AutoFlow.snapshot()
```

postMessage: `{ target: 'autoflow', method, requestId, args }`.

Events: `ready`, `runComplete`, `response`, `workflowSet`.

## Canvas shortcuts

| Key | Action |
|-----|--------|
| G | Toggle snap to grid |
| Ctrl/Cmd+Z / Y | Undo / redo |
| Ctrl/Cmd+C / V | Copy / paste nodes |
| Arrows | Nudge selection |
| Del | Delete selection / hovered wire |
| Esc | Clear selection / cancel wire |
