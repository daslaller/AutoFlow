# AutoFlow

Embeddable automation workflow builder (Flutter) for RepairX and other hosts — design flows visually, preview against a sample record, export `WorkflowDoc` for host-side production execution.

## Engine

Custom Flutter canvas (matrix pan/zoom + `CustomPainter` Beziers + Riverpod). Not Flame / React Flow.

## Run demo

```bash
flutter pub get
flutter run -d chrome
```

## Embed in Flutter (RepairX)

```dart
import 'package:autoflow/autoflow.dart';

AutoFlowBuilder(
  controller: AutoFlowController(),
  catalog: buildDefaultCatalog(), // or API-fetched NodeCatalog
  variables: buildDefaultVariableSchema(),
  chrome: EmbedChrome.minimal,
  callbacks: AutoFlowCallbacks(
    onWorkflowChanged: (doc) => save(doc.toJson()),
  ),
)
```

See [docs/HOST_API.md](docs/HOST_API.md) and [docs/REPAIRX.md](docs/REPAIRX.md).

## Features

- Schema-driven node catalog (host-defined shapes + RepairX triggers/actions)
- Canvas: pan/zoom, snap-to-grid, auto-pan, AA wires, node hover, port/link feedback
- Variables panel, Preview + Record inspector
- Custom Code node (expression / JS / Dart snippet via host)
- Undo/redo, copy/paste, validation badges
- Web JS bridge (`window.AutoFlow`) + `web/embed_host.html`

## Design

Visual language from `design/Anchor Design System/` (tokens only). Product behavior from `Embeddable automation tool/`.
