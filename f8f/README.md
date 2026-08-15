# AutoFlow

Flutter package inside this repo (`package:autoflow`). The product overview,
run commands, and embed snippet live in the [repo README](../README.md).

```bash
flutter pub get
flutter run -d chrome
```

```dart
import 'package:autoflow/autoflow.dart';

AutoFlowBuilder(
  controller: AutoFlowController(),
  catalog: buildDefaultCatalog(),
  previewRecords: buildDefaultPreviewRecords(),
  callbacks: AutoFlowCallbacks(
    onWorkflowChanged: (doc) => save(doc.toJson()),
  ),
)
```

- Host API: [docs/HOST_API.md](docs/HOST_API.md)
- RepairX playbook: [docs/REPAIRX.md](docs/REPAIRX.md)
- Preview engine: [docs/ENGINE.md](docs/ENGINE.md)
