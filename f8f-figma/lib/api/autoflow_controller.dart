import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';

/// Host-facing controller for embedding AutoFlow in RepairX (or any Flutter app).
class AutoFlowController {
  AutoFlowController({ProviderContainer? container})
      : _container = container ?? ProviderContainer();

  final ProviderContainer _container;
  final _workflowCtrl = StreamController<WorkflowDoc>.broadcast();
  final _selectionCtrl = StreamController<String?>.broadcast();
  final _previewCtrl = StreamController<PreviewEvent>.broadcast();
  final _validationCtrl = StreamController<List<ValidationIssue>>.broadcast();
  ProviderSubscription<WorkflowUiState>? _sub;
  bool _attached = false;

  ProviderContainer get container => _container;

  WorkflowController get _wc => _container.read(workflowProvider.notifier);
  WorkflowUiState get _state => _container.read(workflowProvider);

  WorkflowDoc get workflow => _state.doc;
  Stream<WorkflowDoc> get workflowStream => _workflowCtrl.stream;
  Stream<String?> get selectionStream => _selectionCtrl.stream;
  Stream<PreviewEvent> get previewStream => _previewCtrl.stream;
  Stream<List<ValidationIssue>> get validationStream => _validationCtrl.stream;

  void attach() {
    if (_attached) return;
    _attached = true;
    _sub = _container.listen(workflowProvider, (prev, next) {
      if (prev?.doc != next.doc) _workflowCtrl.add(next.doc);
      if (prev?.selectedId != next.selectedId) {
        _selectionCtrl.add(next.selectedId);
      }
      if (prev?.validation != next.validation) {
        _validationCtrl.add(next.validation);
      }
    });
  }

  void setHooks(WorkflowHostHooks hooks) {
    _wc.setHooks(
      WorkflowHostHooks(
        onWorkflowChanged: (doc) {
          hooks.onWorkflowChanged?.call(doc);
          _workflowCtrl.add(doc);
        },
        onTriggerConfigured: hooks.onTriggerConfigured,
        onPreviewEvent: (e) {
          hooks.onPreviewEvent?.call(e);
          _previewCtrl.add(e);
        },
        onRequestCodePreview: hooks.onRequestCodePreview,
        onSaveRequested: hooks.onSaveRequested,
      ),
    );
  }

  void setWorkflow(WorkflowDoc doc) => _wc.replaceWorkflow(doc);

  void setWorkflowJson(Map<String, dynamic> json) {
    _wc.importJson(jsonEncode(json));
  }

  WorkflowDoc getWorkflow() => _state.doc;

  void setCatalog(NodeCatalog catalog) => _wc.setCatalog(catalog);

  void setVariables(VariableSchema schema) => _wc.setVariables(schema);

  void setSampleRecord(Map<String, dynamic> record) =>
      _wc.setSampleRecord(record);

  Future<RunReport?> startPreview({bool record = true}) =>
      _wc.startPreview(record: record);

  void stopPreview() => _wc.stopPreview();

  void configure({EmbedChrome? embedChrome, bool? readOnly}) {
    _wc.setEmbedConfig(
      EmbedConfig(
        embedChrome: embedChrome ?? _state.embedConfig.embedChrome,
        readOnly: readOnly ?? _state.embedConfig.readOnly,
      ),
    );
  }

  Future<RunReport?> submitInput(
    Map<String, dynamic> payload, {
    bool run = true,
  }) async {
    if (!run) {
      _wc.submitInput(payload, run: false);
      return null;
    }
    return _wc.submitInputAndWait(payload);
  }

  Map<String, dynamic> snapshot() => {
        'ready': _state.ready,
        'selectedId': _state.selectedId,
        'isRunning': _state.isRunning,
        'isPreviewing': _state.isPreviewing,
        'workflow': _state.doc.toJson(),
        'lastReport': _state.lastReport?.toJson(),
        'validation': _state.validation
            .map(
              (v) => {
                'nodeId': v.nodeId,
                'message': v.message,
                'fieldKey': v.fieldKey,
              },
            )
            .toList(),
      };

  void dispose() {
    _sub?.close();
    _workflowCtrl.close();
    _selectionCtrl.close();
    _previewCtrl.close();
    _validationCtrl.close();
  }
}
