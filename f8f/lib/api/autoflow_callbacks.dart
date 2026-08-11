import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';

/// Callbacks the host (RepairX) implements when embedding AutoFlow.
class AutoFlowCallbacks {
  const AutoFlowCallbacks({
    this.onWorkflowChanged,
    this.onTriggerConfigured,
    this.onPreviewEvent,
    this.onRequestCodePreview,
    this.onSaveRequested,
  });

  final void Function(WorkflowDoc doc)? onWorkflowChanged;
  final void Function(TriggerBinding binding)? onTriggerConfigured;
  final void Function(PreviewEvent event)? onPreviewEvent;
  final CodePreviewHostFn? onRequestCodePreview;
  final void Function()? onSaveRequested;

  WorkflowHostHooks toHooks() => WorkflowHostHooks(
        onWorkflowChanged: onWorkflowChanged,
        onTriggerConfigured: onTriggerConfigured,
        onPreviewEvent: onPreviewEvent,
        onRequestCodePreview: onRequestCodePreview,
        onSaveRequested: onSaveRequested,
      );
}
