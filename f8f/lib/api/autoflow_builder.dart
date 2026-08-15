import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/api/autoflow_callbacks.dart';
import 'package:autoflow/api/autoflow_controller.dart';
import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/domain/records.dart';
import 'package:autoflow/domain/variables.dart';
import 'package:autoflow/features/builder/builder_page.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';
import 'package:autoflow/theme/anchor_theme.dart';

/// Embeddable workflow builder widget for RepairX and other Flutter hosts.
class AutoFlowBuilder extends ConsumerStatefulWidget {
  const AutoFlowBuilder({
    super.key,
    this.controller,
    this.initialWorkflow,
    this.catalog,
    this.variables,
    this.sampleRecord,
    this.previewRecords,
    this.callbacks = const AutoFlowCallbacks(),
    this.chrome = EmbedChrome.full,
    this.readOnly = false,
    this.wrapWithTheme = true,
  });

  final AutoFlowController? controller;
  final WorkflowDoc? initialWorkflow;
  final NodeCatalog? catalog;
  final VariableSchema? variables;
  final Map<String, dynamic>? sampleRecord;
  final List<DataRecord>? previewRecords;
  final AutoFlowCallbacks callbacks;
  final EmbedChrome chrome;
  final bool readOnly;
  final bool wrapWithTheme;

  @override
  ConsumerState<AutoFlowBuilder> createState() => _AutoFlowBuilderState();
}

class _AutoFlowBuilderState extends ConsumerState<AutoFlowBuilder> {
  bool _appliedInitial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyHostConfig());
  }

  @override
  void didUpdateWidget(covariant AutoFlowBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyHostConfig());
  }

  void _applyHostConfig() {
    final ctrl = ref.read(workflowProvider.notifier);
    widget.controller?.attach();
    ctrl.setHooks(widget.callbacks.toHooks());
    ctrl.setEmbedConfig(
      EmbedConfig(embedChrome: widget.chrome, readOnly: widget.readOnly),
    );
    if (widget.catalog != null) ctrl.setCatalog(widget.catalog!);
    if (widget.variables != null) ctrl.setVariables(widget.variables!);
    if (widget.previewRecords != null) {
      ctrl.setPreviewRecords(widget.previewRecords!);
    }
    if (widget.sampleRecord != null) {
      ctrl.setSampleRecord(widget.sampleRecord!);
    }
    if (!_appliedInitial && widget.initialWorkflow != null) {
      _appliedInitial = true;
      ctrl.replaceWorkflow(widget.initialWorkflow!);
    }
    widget.controller?.setHooks(widget.callbacks.toHooks());
  }

  @override
  Widget build(BuildContext context) {
    final page = const BuilderPage();
    if (!widget.wrapWithTheme) return page;
    return Theme(data: buildAnchorTheme(), child: page);
  }
}

/// Convenience defaults for demos / RepairX starter embeds.
NodeCatalog get autoflowDefaultCatalog => buildDefaultCatalog();
VariableSchema get autoflowDefaultVariables => buildDefaultVariableSchema();
Map<String, dynamic> autoflowDefaultSampleRecord() => buildDefaultSampleRecord();
