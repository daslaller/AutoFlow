# AutoFlow Host API

AutoFlow is an **embeddable workflow designer** — a node-based canvas for
building "when X happens, do Y" automation flows. It owns **design,
validation, and in-editor Preview** (a soft, sample-data simulation). It does
**not** own production execution, storage, or connectors — that's the host's
job. This is deliberate: AutoFlow has no opinion about your backend, your
data model, or how "send an email" actually happens. It hands you a
`WorkflowDoc` (plain JSON) and a `TriggerBinding`; what you do with them is
entirely up to you.

This doc is the full reference for embedding it. If you just want the
shortest path to a working embed, read "Quick start" and the "Controller
reference" table, then skim the rest as needed.

## Two ways to embed

AutoFlow supports two independent embedding modes. Pick the one that matches
your host — you do not need both.

| | **Native Flutter widget** | **Web / JS bridge** |
|---|---|---|
| Use when | Your host app is itself Flutter (mobile, desktop, or web) | Your host is anything else — a JS/TS web app, a server-rendered page, literally any backend that can render an iframe |
| Entry point | `AutoFlowBuilder` widget + `AutoFlowController` | Compiled AutoFlow web build loaded in an `<iframe>`, driven via `window.AutoFlow` or `postMessage` |
| Data path | Direct Dart method calls, `Stream`s | JSON over JS interop / `postMessage` |
| Where it's wired | `lib/api/*` (`AutoFlowBuilder`, `AutoFlowController`, `AutoFlowCallbacks`) | `lib/main.dart` (entrypoint) + `lib/features/embed/*` (`registerEmbedBridge`, `EmbedApi`) |

Both modes sit on top of the same `WorkflowController` (Riverpod) — they're
two different front doors onto identical behavior, not two separate
implementations. Nothing about the domain model, validation, or Preview
differs between them.

**Important:** the JS bridge is only wired up by `lib/main.dart` (the
standalone demo/iframe entrypoint) — it is *not* automatically registered
when you use `AutoFlowBuilder` as a native widget. If you're embedding
natively in a Flutter host, ignore the JS bridge section entirely; you don't
need it and it won't be present.

---

## Engine

Custom Flutter canvas (no Flame / React Flow):

- Viewport: matrix pan/zoom + pointer hit-testing
- Wires: antialiased `CustomPainter` Beziers (`wire_painter.dart`)
- Nodes: positioned widgets, fixed size (`AnchorSpacing.nodeWidth` ×
  `AnchorSpacing.nodeHeight`)
- State: Riverpod (`WorkflowController extends Notifier<WorkflowUiState>`)

---

## Quick start (native Flutter embed)

```dart
import 'package:autoflow/autoflow.dart';

final controller = AutoFlowController();

AutoFlowBuilder(
  controller: controller,
  catalog: catalogFromApi,          // NodeCatalog — your node type definitions
  variables: variablesFromApi,      // VariableSchema — {{path}} autocomplete data
  sampleRecord: sampleTicketJson,   // Map<String, dynamic> — Preview's fake event payload
  chrome: EmbedChrome.minimal,      // .full shows top bar + palette; .minimal is canvas + inspector only
  callbacks: AutoFlowCallbacks(
    onWorkflowChanged: (doc) => api.putFlow(doc.toJson()),
    onTriggerConfigured: (binding) => api.indexTrigger(binding.toJson()),
    onRequestCodePreview: (node, ctx) => hostEvalCode(node, ctx),
    onSaveRequested: () => api.flush(),
  ),
)
```

`controller.dispose()` when the host screen is torn down — it owns a Riverpod
`ProviderContainer` and four `StreamController`s that need closing.

---

## `AutoFlowController` reference

The host-facing handle. Create one per embedded flow-editor instance (don't
share one controller across multiple `AutoFlowBuilder`s).

| Member | Signature | Purpose |
|---|---|---|
| `container` | `ProviderContainer` | The underlying Riverpod container — only needed if you're also registering the JS bridge (`registerEmbedBridge(controller.container)`) or writing tests. |
| `workflow` | `WorkflowDoc get` | Current doc, synchronous snapshot. |
| `getWorkflow()` | `WorkflowDoc Function()` | Same as `.workflow`, method form. |
| `setWorkflow(doc)` | `void Function(WorkflowDoc)` | Replace the whole doc (clears undo/redo history). |
| `setWorkflowJson(json)` | `void Function(Map<String,dynamic>)` | Same, from raw JSON (goes through the v1→v2 migration path). |
| `setCatalog(catalog)` | `void Function(NodeCatalog)` | Hot-swap node type definitions. Existing nodes whose `typeId` is still present get their `def` rebound to the new definition; nodes whose type disappeared keep their last-known `def` but immediately surface an "Unknown node type" validation issue. |
| `setVariables(schema)` | `void Function(VariableSchema)` | Bind the `{{path}}` variable dictionary shown in the Variables panel. |
| `setSampleRecord(record)` | `void Function(Map<String,dynamic>)` | The fake event payload Preview runs against. |
| `startPreview({record = true})` | `Future<RunReport?> Function({bool})` | Run the graph against `sampleRecord` in the editor (soft simulation, ~5% random failure injection on non-trigger/code nodes — see "Preview vs production" below). |
| `stopPreview()` | `void Function()` | Cancel an in-flight preview run. |
| `configure({embedChrome, readOnly})` | `void Function({EmbedChrome?, bool?})` | Toggle chrome and read-only lock at runtime. |
| `submitInput(payload, {run = true})` | `Future<RunReport?> Function(Map<String,dynamic>, {bool})` | Set `sampleRecord` and optionally run Preview immediately — the "feed it a real-looking event and see what happens" entry point. |
| `snapshot()` | `Map<String,dynamic> Function()` | One-shot JSON dump: `ready`, `selectedId`, `isRunning`, `isPreviewing`, `workflow`, `lastReport`, `validation`. Useful for host-side debugging/logging, not for driving UI (use the streams for that). |
| `attach()` | `void Function()` | Wires the controller's internal Riverpod listener so the streams below start emitting. **Called automatically** by `AutoFlowBuilder` on first frame — call it yourself only if you're using the controller headless (no `AutoFlowBuilder` in the tree at all, e.g. driving flows from a test or a background isolate). Idempotent. |
| `setHooks(hooks)` | `void Function(WorkflowHostHooks)` | Low-level hook registration. `AutoFlowBuilder` calls this for you from `callbacks:` — you normally never call it directly. |
| `workflowStream` | `Stream<WorkflowDoc>` | Emits on every committed doc change (node add/move/delete, wire add/delete, config edit, name change — anything that goes through `_commit`). |
| `selectionStream` | `Stream<String?>` | Emits the selected node's `iid`, or `null` when selection clears. |
| `previewStream` | `Stream<PreviewEvent>` | Emits one event per node as Preview executes it (not just at the end — use this for a live "running…" UI). |
| `validationStream` | `Stream<List<ValidationIssue>>` | Emits the full current issue list whenever it changes. |
| `dispose()` | `void Function()` | Close everything. Call from your host screen's `dispose()`. |

**Gotcha:** there is currently no `triggerStream` — `onTriggerConfigured` (see
callbacks below) is the *only* way to observe trigger changes; it is not
also mirrored onto a stream the way `onWorkflowChanged`/`onPreviewEvent` are.
If your host's persistence layer is stream-driven, wire the callback into
your own stream/controller manually.

---

## `AutoFlowBuilder` reference

The widget. All params besides `controller` are optional — omit `catalog`/
`variables`/`sampleRecord` to use the built-in RepairX-flavored demo data
(`buildDefaultCatalog()` / `buildDefaultVariableSchema()` /
`buildDefaultSampleRecord()`), which is useful for a first integration pass
before you've wired real data.

| Param | Type | Default | Notes |
|---|---|---|---|
| `controller` | `AutoFlowController?` | `null` | Omit only if you truly don't need programmatic access — you'll still get `callbacks`, but no `workflowStream`/`getWorkflow()`/etc. |
| `initialWorkflow` | `WorkflowDoc?` | demo doc | Applied exactly once, on first frame — later rebuilds with a different `initialWorkflow` are ignored (see "Known limitations"). To load a *different* flow into an already-mounted builder, call `controller.setWorkflow(doc)` instead. |
| `catalog` | `NodeCatalog?` | `buildDefaultCatalog()` | Re-applied on every rebuild, unlike `initialWorkflow` — safe to pass a `FutureBuilder`-derived value that starts `null` and resolves later. |
| `variables` | `VariableSchema?` | demo schema | Same rebuild behavior as `catalog`. |
| `sampleRecord` | `Map<String,dynamic>?` | demo record | Same. |
| `callbacks` | `AutoFlowCallbacks` | `const AutoFlowCallbacks()` (no-ops) | See below. |
| `chrome` | `EmbedChrome` | `.full` | `.full` = top bar + node palette + inspector; `.minimal` = canvas + inspector only (no top bar, no palette — for embedding inside a host page that supplies its own chrome). |
| `readOnly` | `bool` | `false` | Locks all mutation (`updateSelectedConfig`, `deleteSelected`, wire drawing, etc. all no-op) — canvas is still pannable/zoomable and inspectable. |
| `wrapWithTheme` | `bool` | `true` | Set `false` if your host already provides a `Theme` you want AutoFlow to inherit instead of `buildAnchorTheme()`. |

---

## `AutoFlowCallbacks` reference

Every field is optional; unset ones are no-ops.

| Callback | Signature | Fires when |
|---|---|---|
| `onWorkflowChanged` | `void Function(WorkflowDoc doc)` | After **every** committed mutation — this is your save hook. It's debounced at the `_scheduleSave()` level internally (400ms) only for the built-in local `WorkflowRepository` persistence; `onWorkflowChanged` itself fires synchronously on each commit, so debounce/coalesce on your side if `doc.toJson()` is expensive or your write path is rate-limited. |
| `onTriggerConfigured` | `void Function(TriggerBinding binding)` | After a commit, if the doc has a trigger-capable node (see "Trigger derivation" below). This is the signal to (re)index the flow in your runtime's trigger→flow lookup. |
| `onPreviewEvent` | `void Function(PreviewEvent event)` | Once per node, during Preview execution. |
| `onRequestCodePreview` | `CodePreviewHostFn` = `Future<Map<String,dynamic>> Function(CanvasNode node, Map<String,dynamic> ctx)` | When Preview hits a `code` node whose `lang` config isn't `expression` (i.e. `javascript`/`dart_snippet` — AutoFlow's built-in evaluator only understands its own tiny expression language). Return whatever your sandboxed evaluator produces; it's merged into the running preview context. If unset, those nodes fail Preview with "Host code preview not configured for `<lang>`" — by design, not a bug: AutoFlow will never eval arbitrary JS/Dart itself. |
| `onSaveRequested` | `void Function()` | When the host UI's explicit save affordance is triggered (Ctrl/Cmd+S canvas shortcut → `ctrl.requestSave()`). AutoFlow does not call this on every change — that's `onWorkflowChanged`'s job. Use this only if you want an explicit "force flush now" hook distinct from autosave. |

---

## Domain model reference

Everything below round-trips through `.toJson()` / `.fromJson()`. This is the
actual wire format if you're persisting or transmitting flows.

### `WorkflowDoc` (the flow)

```json
{
  "version": 2,
  "id": "flow_onboard_sms",
  "name": "On SMS received → triage",
  "trigger": { "type": "message.received", "filters": { "channel": "sms" } },
  "nodes": [
    {
      "iid": "n1",
      "typeId": "message.received",
      "defId": "message.received",
      "x": 60, "y": 190,
      "status": "idle",
      "config": { "channel": "sms" }
    }
  ],
  "wires": [
    { "id": "w1", "from": "n1", "fromPort": "out", "to": "n2", "toPort": "in" }
  ],
  "meta": { "updatedAt": "2026-07-17T00:00:00Z" }
}
```

- `id` is host-assigned (nullable) — AutoFlow never generates it.
- `defId` is a v1-compat duplicate of `typeId`; both are always written, only
  `typeId` (falling back to `defId`, falling back to nested `def.id`) is read.
- `trigger` is **derived automatically** by AutoFlow on every commit (see
  below) — you do not set it by editing the doc; it's overwritten on the
  next commit regardless of what you pass in via `setWorkflow`.
- `meta.updatedAt` is stamped by AutoFlow itself on every commit; add your
  own keys freely, they round-trip untouched.

### `CanvasNode.config` — `Map<String, dynamic>`

As of this version, `config` (and the field-editor write path,
`updateSelectedConfig(key, dynamic value)`) is `Map<String, dynamic>`, not
`Map<String, String>`. This matters if you're consuming it:

- **On decode** (`WorkflowRepository.workflowFromJson`), config values are
  passed through as-is from JSON — a `number` field stored as a JSON number
  stays a `num`, a `toggle` stored as a JSON `bool` stays a `bool`. Nothing
  is silently stringified anymore.
- **Today's built-in field editors still write strings** (the `toggle`
  editor writes `'true'`/`'false'`, the generic text editor always writes
  `String`) — the type was widened to *allow* richer values end-to-end, but
  no built-in UI writes non-string values yet. If you supply your own
  catalog with `number`/`toggle` fields and want typed config, you can
  write typed values directly via `controller.setWorkflow(...)` /
  `setWorkflowJson(...)`; AutoFlow will preserve and display them correctly
  (comparisons like the toggle's `== 'true'` check are string-based today,
  so a literal boolean `true` in config won't register as "on" in the
  built-in toggle widget — round-trips fine as data, just isn't
  editor-recognized as "checked" yet).
- Wherever host code reads `node.config[key]`, treat it as `dynamic` and
  coerce explicitly (`'${node.config[key]}'`) rather than assuming `String`.

### `NodeCatalog` / `NodeTypeDef` (your node type definitions)

```json
{
  "version": "2",
  "types": [
    {
      "id": "ticket.status_changed",
      "kind": "trigger",
      "label": "Status Changed",
      "sublabel": "Ticket status transition",
      "iconKey": "zap",
      "inputs": [],
      "outputs": [{ "id": "out", "label": "Out" }],
      "fields": [
        { "key": "statusTo", "label": "To status", "type": "statusEnum", "required": true }
      ],
      "produces": ["ticket", "status.to"],
      "requires": [],
      "trigger": { "type": "ticket.status_changed", "filters": {} }
    }
  ]
}
```

- `kind` is one of `trigger | action | condition | transform | output` — it
  drives the node's color/icon/palette grouping. It is *not* a behavioral
  gate: a node with `outputs: []` still renders as a normal card regardless
  of `kind`.
- `trigger` (optional) is what makes a node type trigger-capable — see
  "Trigger derivation" below. Only set it on node types that represent a
  real inbound event in your system.
- `produces` / `requires` are free-form string tags, currently
  **informational only** — nothing in AutoFlow enforces or uses them (no
  compatibility checking between a node's `requires` and an upstream node's
  `produces`). If your host wants type-safe wiring, that validation would
  need to live in your own layer (e.g. before accepting `onTriggerConfigured`
  or on `onWorkflowChanged`, walk `doc.wires` and cross-check `produces`/
  `requires` yourself).
- `iconKey` is a free-form string slot on both `NodeTypeDef` and legacy
  `NodeDef`, but **nothing in the current UI reads it** — the canvas/palette
  icon is derived purely from `kind` (5 fixed icons, one per `NodeKind`),
  not per-type. If you need distinct icons per node type, that's a UI change
  on AutoFlow's side, not something you can drive from the catalog today.

### `FieldDef` / `FieldType` (per-node config fields)

Field types: `text`, `textarea`, `number`, `select`, `toggle`, `json`,
`code`, `variablePicker`, `statusEnum`, `template`.

All ten are handled by the properties panel: `toggle` gets a `Switch`,
`select` (with `options`) gets a dropdown, everything else gets a text input
(single-line for `text`/`number`/`variablePicker`/`statusEnum`, multi-line
for `textarea`/`code`/`json`/`template`). `number` and `statusEnum` are
presentation-only distinctions today — they render as a plain text field
with no numeric keyboard, spinner, or enum-value constraint. If you need
real input constraints for those, validate host-side after `onWorkflowChanged`
rather than relying on the editor to enforce them.

`required: true` fields are checked on every commit; the effective value for
that check falls back the same way the editor displays it (`config[key] ??
defaultValue ?? (select's first option)`), so a required field with a
sensible default is never permanently flagged.

### `TriggerBinding`

```json
{ "type": "message.received", "filters": { "channel": "sms" } }
```

`filters` is the *entire config map* of the winning trigger node, merged
over the node type's static `trigger.filters`. There's no allow-list — every
config key on that node ends up in `filters`, whether or not it's meaningful
as a match filter. If a trigger node type has config fields that shouldn't
be treated as event-matching filters, keep them off that node type, or
filter `binding.filters` down to the keys you care about on your side in
`onTriggerConfigured`.

### Trigger derivation (`WorkflowController._deriveTrigger`)

On every commit, AutoFlow scans `doc.nodes` **in array order** and uses the
**first** node whose catalog type has `trigger` set. This has two
consequences worth knowing:

1. **Only one trigger is ever active per flow.** If a user adds a second
   trigger-capable node, it's silently inert — as of this version, the
   properties panel does surface a validation issue on the ignored node
   ("Only one trigger node is active per flow — this one is ignored"), but
   nothing stops them from adding it or wires it into anything.
2. Which node "wins" depends on insertion order, not canvas position — don't
   assume the visually-first (leftmost/topmost) trigger node is the one
   whose `filters` you'll get.

If your catalog only ever has one trigger-capable node type and you enforce
"at most one instance of it" some other way (e.g. hide it from the palette
once placed), this is moot. If you allow multiple trigger types in one
catalog, watch for this.

### `RunReport` / `NodeResult` / `PreviewEvent`

Preview execution output — `RunReport` is the final summary
(`{order, results, input, finishedAt}`), `PreviewEvent` is the per-node
stream item (`onPreviewEvent` / `previewStream`), `NodeResult` is what ends
up in `RunReport.results`. All three are `toJson()`-able. `status` is one of
`idle | running | success | error`.

Preview execution (`SimulationEngine`) is **not** your production runtime —
see "Preview vs production" below.

### `ValidationIssue`

`{nodeId, message, fieldKey?}` — currently three sources: unknown node type,
missing required field, and (new) redundant trigger node. Surfaced via
`validationStream` and shown inline in the properties panel per-node.

### `EmbedConfig` / `EmbedChrome`

`{embedChrome: full|minimal, readOnly: bool}` — see `AutoFlowBuilder`
params above; `configure()` on the controller changes this at runtime.

---

## Preview vs production

| | Preview (AutoFlow) | Production (your host) |
|---|---|---|
| Data | Sample **Record** (`sampleRecord`) | Live event payload |
| Trigger/action nodes | Interpolated against the sample record, no side effects | Your connectors — actually send the email, actually create the PO |
| `code` nodes | AutoFlow's built-in expression evaluator, or `onRequestCodePreview` for JS/Dart | Your `CodeExecutor` |
| Failures | Non-trigger/code nodes get a random ~5% simulated failure (`useRandomFailures: true` in `runWorkflow`, only when `preview: false`... — see note below) | Real connector errors |
| Side effects | **None.** AutoFlow never calls your APIs, never sends anything. | All of them. |

**Note on the random-failure flag:** `WorkflowController.runWorkflow` passes
`useRandomFailures: !preview` — i.e. random failures are injected on
*non*-preview runs and suppressed *during* Preview. Since AutoFlow has no
other run mode (there is no "production run" concept inside the package
itself — `startPreview`/`submitInputAndWait` always pass `preview: true`),
this flag is effectively dead in every path currently reachable from the
public API. Don't rely on Preview ever exercising the random-failure branch.

AutoFlow does not need to be on-screen for your production runs — your
runtime executes `WorkflowDoc`s directly, driven by the `trigger`/`nodes`/
`wires` data, independent of the editor UI.

---

## Building your runtime executor (host-side, backend-agnostic)

AutoFlow gives you two things to build a runtime on: a `TriggerBinding` (via
`onTriggerConfigured`) telling you *when* a flow should fire, and a
`WorkflowDoc` (via `onWorkflowChanged`) telling you *what* it should do.
Everything past that is yours. A minimal host runtime is three pieces,
regardless of language/framework:

1. **Trigger index** — on `onTriggerConfigured(binding)`, store
   `{flowId, binding.type, binding.filters}` somewhere queryable. On your
   own domain events, look up flows by `type` + filter match.
2. **Executor** — given a matched `WorkflowDoc` and a real event payload,
   walk `nodes`/`wires` in the same topological order AutoFlow's
   `SimulationEngine.executionOrder` computes (source is public — reuse it
   or reimplement the same BFS-from-zero-inbound-edges logic), and for each
   node, dispatch on `node.def.id`/`node.typeId` to your own connector
   implementation (send email, create PO, update ticket status, etc.) — the
   `id` values are whatever you chose when authoring your `NodeCatalog`, so
   this dispatch table is entirely under your control.
3. **Code sandbox** — implement `onRequestCodePreview` if you support
   `code` nodes with `lang != expression`; your production executor needs
   the equivalent non-preview version of the same sandbox.

This is intentionally not prescriptive about connectors — "send email",
"create purchase order", "text customer" are not things AutoFlow knows
about; they're catalog entries you define and an executor you write. That's
what makes it embeddable into *any* backend: the only contract is
JSON in, JSON out, plus the callback functions above.

---

## Known limitations (read before designing branching flows)

- **Multi-output nodes render and wire as single-output today.** The domain
  model supports it (`NodeTypeDef.outputs: List<PortDef>`, `Wire.fromPort`),
  and the demo data even hardcodes a two-output wire (`if-else` node with
  `true`/`false` outputs) — but the interactive canvas does not: node cards
  render exactly one output port regardless of `outputs.length`, wire
  hit-testing/positioning (`WirePainter._portOut`, `WorkflowCanvas._hitOutput`)
  always resolves to the single center-right point, and
  `WorkflowCanvas._onPointerDown` always starts a new wire with the default
  `fromPort: 'out'` — there is currently no way for a user to interactively
  create a wire on any port other than `'out'`. If your automation needs
  branching (e.g. "if ticket status == X do A else do B"), either build
  branch logic into a single node's config (a `select`/`condition` field the
  executor reads) rather than via separate output ports, or budget engine
  work to add multi-port rendering/hit-testing before relying on it.
- **`initialWorkflow` only applies once.** Changing it on a rebuilt
  `AutoFlowBuilder` does nothing after the first frame — use
  `controller.setWorkflow(doc)` to load a different flow into a live editor.
- **No `triggerStream`** — see the controller reference above.
- **`produces`/`requires` are unenforced** — see the catalog reference above.
- **`iconKey` is unused** by the current canvas/palette — icons are keyed
  off `kind` only (5 fixed icons).

None of these block embedding AutoFlow as a linear (single trigger → single
chain of actions) automation engine, which covers most "when X happens, do
Y" rules. They matter once you need conditional branching authored visually
rather than inside one node's config.

---

## Web / JS bridge

Only present when you load the compiled AutoFlow web build directly (see
`lib/main.dart`) — e.g. in an `<iframe>` on a host page. Two equivalent
call surfaces exist; pick one:

**Direct methods** on `window.AutoFlow`:

```js
window.AutoFlow.getWorkflow()
window.AutoFlow.setCatalog(catalog)
window.AutoFlow.setVariables(schema)
window.AutoFlow.setSampleRecord(record)
window.AutoFlow.setWorkflow(doc)
window.AutoFlow.startPreview()
window.AutoFlow.submitInput({ payload, run: true })
window.AutoFlow.configure({ embedChrome, readOnly })
window.AutoFlow.snapshot()
window.AutoFlow.call(method, args)   // generic dispatch, see below
```

**`postMessage`** (for cross-origin iframes where you can't touch
`window.AutoFlow` directly):

```js
iframe.contentWindow.postMessage({
  target: 'autoflow',
  method: 'setWorkflow',
  requestId: 'req-1',       // optional, echoed back in the response event
  args: { workflow: doc },
}, '*')
```

Both surfaces resolve to the same internal `dispatch(method, args)` — note
the **named methods and `dispatch()` don't always parse `args` identically**
(e.g. `window.AutoFlow.setWorkflow(doc)` takes the doc directly, while
`dispatch('setWorkflow', args)` expects `{workflow: doc}` and only falls
back to treating the whole `args` as the doc if there's no `workflow` key).
When in doubt, wrap payloads in the named key shown in each doc example
above rather than passing bare values through `call()`/`postMessage`.

Outbound events (`window.addEventListener('message', ...)`, all with
`{source: 'autoflow', type, ...}`):

| `type` | When |
|---|---|
| `ready` | Bridge finished registering — safe to start calling. |
| `workflowSet` | After `setWorkflow` completes. |
| `runComplete` | After `startPreview` / `submitInput` finishes — includes `report`. |
| `response` | Reply to a `call()`/`postMessage` request — includes `requestId` (if you sent one) and `result`. |

---

## Versioning

`WorkflowDoc.version` — currently `2`. v1 docs (keyed by `defId` instead of
`typeId`, no top-level `trigger`) still decode: `WorkflowRepository`
migrates on load by bumping `version` to 2 and deriving `trigger` from the
first trigger-capable node found, same rule as live editing (see "Trigger
derivation" above — same single-winner caveat applies to migrated docs too).

---

## Canvas shortcuts

| Key | Action |
|-----|--------|
| G | Toggle snap to grid |
| Ctrl/Cmd+Z / Y | Undo / redo |
| Ctrl/Cmd+C / V | Copy / paste nodes |
| Arrows | Nudge selection |
| Del | Delete selection / hovered wire |
| Esc | Clear selection / cancel wire |
| Ctrl/Cmd+S | `onSaveRequested` |

---

## Verification checklist for a new host integration

- [ ] `setCatalog` with a custom node type renders in the palette and can be
      dragged onto the canvas without rebuilding AutoFlow.
- [ ] `onWorkflowChanged` fires and `doc.toJson()` round-trips through your
      persistence layer and back via `setWorkflow`/`setWorkflowJson`.
- [ ] `onTriggerConfigured` fires exactly once per flow with a single
      trigger node; adding a second trigger node surfaces the "ignored"
      validation issue instead of silently swapping which one is active.
- [ ] A `required: true` field with a `defaultValue` (or a required
      `select`) does **not** show a permanent validation error.
- [ ] `code` node Preview correctly falls through to
      `onRequestCodePreview` for non-`expression` languages.
- [ ] `configure(readOnly: true)` actually locks editing (try deleting a
      node, dragging a wire, editing a field — all should no-op).
- [ ] Unknown `typeId` (e.g. after a catalog change removes a type in use)
      shows the "Unknown node type" validation badge instead of crashing.
