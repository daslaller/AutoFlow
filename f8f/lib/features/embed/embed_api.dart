import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/domain/records.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';

/// Platform-agnostic embed surface used by the web JS bridge.
class EmbedApi {
  EmbedApi(this._ref);

  final ProviderContainer _ref;

  WorkflowController get _ctrl => _ref.read(workflowProvider.notifier);
  WorkflowUiState get _state => _ref.read(workflowProvider);

  Map<String, dynamic> getWorkflow() => _state.doc.toJson();

  void setWorkflow(Map<String, dynamic> json) {
    _ctrl.importJson(jsonEncode(json));
  }

  void setCatalog(Map<String, dynamic> json) {
    _ctrl.setCatalog(NodeCatalog.fromJson(json));
  }

  void setVariables(Map<String, dynamic> json) {
    _ctrl.setVariables(VariableSchema.fromJson(json));
  }

  void setSampleRecord(Map<String, dynamic> json) {
    _ctrl.setSampleRecord(json);
  }

  void setPreviewRecords(List<dynamic> json) {
    _ctrl.setPreviewRecords(
      json
          .whereType<Map>()
          .map((r) => DataRecord.fromJson(Map<String, dynamic>.from(r)))
          .toList(),
    );
  }

  void configure({String? embedChrome, bool? readOnly}) {
    final chrome = switch (embedChrome) {
      'minimal' => EmbedChrome.minimal,
      _ => EmbedChrome.full,
    };
    _ctrl.setEmbedConfig(
      EmbedConfig(
        embedChrome: chrome,
        readOnly: readOnly ?? _state.embedConfig.readOnly,
      ),
    );
  }

  Future<Map<String, dynamic>> submitInput(
    Map<String, dynamic> payload, {
    bool run = true,
  }) async {
    if (!run) {
      _ctrl.submitInput(payload, run: false);
      return {'accepted': true, 'run': false};
    }
    final report = await _ctrl.submitInputAndWait(payload);
    return report?.toJson() ?? {'error': 'Run already in progress'};
  }

  Future<Map<String, dynamic>> startPreview() async {
    final report = await _ctrl.startPreview(record: true);
    return report?.toJson() ?? {'error': 'Busy'};
  }

  Map<String, dynamic> snapshot() => {
        'ready': _state.ready,
        'selectedId': _state.selectedId,
        'isRunning': _state.isRunning,
        'isPreviewing': _state.isPreviewing,
        'workflow': _state.doc.toJson(),
        'lastReport': _state.lastReport?.toJson(),
        'snapToGrid': _state.snapToGrid,
      };
}
