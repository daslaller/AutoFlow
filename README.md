# F8F

Embeddable visual automation builder for Flutter. Draw a trigger → conditions
→ actions graph, preview it against a shop record, and hand the saved
`WorkflowDoc` to the host for production runs.

Built for [RepairX](https://github.com/daslaller/repairx); usable in any
Flutter app. The Dart package name is `autoflow` (the folder is `f8f/`).

## What it does

- **Design** — drag nodes from a catalog, wire them on a pan/zoom canvas.
  If/Else and Switch expose named output ports (`true`/`false`, `case1`…
  `default`); each port is independently wirable.
- **Preview** — pick a ticket, purchase order, device, or spare part. Its
  fields become `{{path}}` variables. Run Preview in the editor; only the
  taken branch executes (HeidNodes `fl_nodes_core` under
  `SimulationEngine`).
- **Hand off** — the host owns live execution. AutoFlow owns the editor,
  validation, and in-editor Preview. RepairX (or you) runs the saved graph
  when a real event fires.

## Quick start

```bash
cd f8f
flutter pub get
flutter run -d chrome
```

## Embed

```dart
import 'package:autoflow/autoflow.dart';

AutoFlowBuilder(
  controller: AutoFlowController(),
  catalog: buildDefaultCatalog(),
  variables: buildDefaultVariableSchema(),
  previewRecords: buildDefaultPreviewRecords(),
  chrome: EmbedChrome.minimal,
  callbacks: AutoFlowCallbacks(
    onWorkflowChanged: (doc) => save(doc.toJson()),
    onRequestCodePreview: (node, ctx) => hostEvalCode(node, ctx),
  ),
)
```

Hosts can override the palette (`AnchorColors.active = …`) before mounting
the builder. Named default-look alternatives (`midnight`, `workshop`,
`harbor`, `studio`) live in `AnchorThemePresets`. Full contract:
[`f8f/docs/HOST_API.md`](f8f/docs/HOST_API.md). RepairX wiring:
[`f8f/docs/REPAIRX.md`](f8f/docs/REPAIRX.md). How Preview actually runs:
[`f8f/docs/ENGINE.md`](f8f/docs/ENGINE.md).

## Repo layout

```
f8f/                  Flutter package (autoflow)
  lib/api/            AutoFlowBuilder, AutoFlowController
  lib/domain/         catalog, records, WorkflowDoc
  lib/features/builder/   canvas + inspector
  lib/features/run/   SimulationEngine (HeidNodes-backed)
  docs/               HOST_API, ENGINE, REPAIRX
```

## Tests

```bash
cd f8f
dart analyze
flutter test
```
