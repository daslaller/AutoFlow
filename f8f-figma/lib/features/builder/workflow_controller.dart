import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:autoflow/data/workflow_repository.dart';
import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/demo_workflow.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/domain/variables.dart';
import 'package:autoflow/features/run/simulation_engine.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

class WorkflowUiState {
  const WorkflowUiState({
    required this.doc,
    required this.catalog,
    required this.variables,
    this.selectedId,
    this.selectedIds = const {},
    this.panX = 80,
    this.panY = 90,
    this.zoom = 0.82,
    this.isRunning = false,
    this.isPreviewing = false,
    this.drawingWire,
    this.search = '',
    this.sampleRecord = const {},
    this.lastReport,
    this.previewEvents = const [],
    this.lastRecording,
    this.ready = false,
    this.embedConfig = const EmbedConfig(),
    this.snapToGrid = true,
    this.gridSize = 28,
    this.sideTab = SidePanelTab.properties,
    this.canUndo = false,
    this.canRedo = false,
    this.validation = const [],
    this.clipboard = const [],
  });

  final WorkflowDoc doc;
  final NodeCatalog catalog;
  final VariableSchema variables;
  final String? selectedId;
  final Set<String> selectedIds;
  final double panX;
  final double panY;
  final double zoom;
  final bool isRunning;
  final bool isPreviewing;
  final DrawingWire? drawingWire;
  final String search;
  final Map<String, dynamic> sampleRecord;
  final RunReport? lastReport;
  final List<PreviewEvent> previewEvents;
  final PreviewRecording? lastRecording;
  final bool ready;
  final EmbedConfig embedConfig;
  final bool snapToGrid;
  final double gridSize;
  final SidePanelTab sideTab;
  final bool canUndo;
  final bool canRedo;
  final List<ValidationIssue> validation;
  final List<CanvasNode> clipboard;

  CanvasNode? get selectedNode {
    final id = selectedId;
    if (id == null) return null;
    for (final n in doc.nodes) {
      if (n.iid == id) return n;
    }
    return null;
  }

  WorkflowUiState copyWith({
    WorkflowDoc? doc,
    NodeCatalog? catalog,
    VariableSchema? variables,
    String? selectedId,
    bool clearSelected = false,
    Set<String>? selectedIds,
    double? panX,
    double? panY,
    double? zoom,
    bool? isRunning,
    bool? isPreviewing,
    DrawingWire? drawingWire,
    bool clearDrawingWire = false,
    String? search,
    Map<String, dynamic>? sampleRecord,
    RunReport? lastReport,
    List<PreviewEvent>? previewEvents,
    PreviewRecording? lastRecording,
    bool? ready,
    EmbedConfig? embedConfig,
    bool? snapToGrid,
    double? gridSize,
    SidePanelTab? sideTab,
    bool? canUndo,
    bool? canRedo,
    List<ValidationIssue>? validation,
    List<CanvasNode>? clipboard,
  }) {
    return WorkflowUiState(
      doc: doc ?? this.doc,
      catalog: catalog ?? this.catalog,
      variables: variables ?? this.variables,
      selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
      selectedIds: clearSelected ? const {} : (selectedIds ?? this.selectedIds),
      panX: panX ?? this.panX,
      panY: panY ?? this.panY,
      zoom: zoom ?? this.zoom,
      isRunning: isRunning ?? this.isRunning,
      isPreviewing: isPreviewing ?? this.isPreviewing,
      drawingWire:
          clearDrawingWire ? null : (drawingWire ?? this.drawingWire),
      search: search ?? this.search,
      sampleRecord: sampleRecord ?? this.sampleRecord,
      lastReport: lastReport ?? this.lastReport,
      previewEvents: previewEvents ?? this.previewEvents,
      lastRecording: lastRecording ?? this.lastRecording,
      ready: ready ?? this.ready,
      embedConfig: embedConfig ?? this.embedConfig,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      gridSize: gridSize ?? this.gridSize,
      sideTab: sideTab ?? this.sideTab,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
      validation: validation ?? this.validation,
      clipboard: clipboard ?? this.clipboard,
    );
  }
}

typedef WorkflowChangedFn = void Function(WorkflowDoc doc);
typedef TriggerConfiguredFn = void Function(TriggerBinding binding);
typedef PreviewEventFn = void Function(PreviewEvent event);
typedef CodePreviewHostFn = Future<Map<String, dynamic>> Function(
  CanvasNode node,
  Map<String, dynamic> ctx,
);

class WorkflowHostHooks {
  const WorkflowHostHooks({
    this.onWorkflowChanged,
    this.onTriggerConfigured,
    this.onPreviewEvent,
    this.onRequestCodePreview,
    this.onSaveRequested,
  });

  final WorkflowChangedFn? onWorkflowChanged;
  final TriggerConfiguredFn? onTriggerConfigured;
  final PreviewEventFn? onPreviewEvent;
  final CodePreviewHostFn? onRequestCodePreview;
  final void Function()? onSaveRequested;
}

class WorkflowController extends Notifier<WorkflowUiState> {
  final _repo = WorkflowRepository();
  final _engine = SimulationEngine();
  final _uuid = const Uuid();
  Timer? _saveDebounce;
  bool _cancelRun = false;
  WorkflowHostHooks hooks = const WorkflowHostHooks();

  final List<WorkflowDoc> _undo = [];
  final List<WorkflowDoc> _redo = [];

  @override
  WorkflowUiState build() {
    Future.microtask(_bootstrap);
    return WorkflowUiState(
      doc: createDemoWorkflow(),
      catalog: buildDefaultCatalog(),
      variables: buildDefaultVariableSchema(),
      sampleRecord: buildDefaultSampleRecord(),
    );
  }

  Future<void> _bootstrap() async {
    final doc = await _repo.load(state.catalog);
    state = state.copyWith(doc: doc, ready: true, validation: _validate(doc));
  }

  void setHooks(WorkflowHostHooks h) => hooks = h;

  double _snap(double v) {
    if (!state.snapToGrid) return v;
    final g = state.gridSize;
    return (v / g).round() * g;
  }

  void _pushUndo() {
    _undo.add(state.doc);
    if (_undo.length > 50) _undo.removeAt(0);
    _redo.clear();
    state = state.copyWith(canUndo: _undo.isNotEmpty, canRedo: false);
  }

  void _commit(WorkflowDoc doc, {bool recordUndo = true}) {
    if (recordUndo) _pushUndo();
    final trigger = _deriveTrigger(doc);
    final next = doc.copyWith(
      trigger: trigger,
      version: 2,
      meta: {
        ...doc.meta,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
    state = state.copyWith(
      doc: next,
      validation: _validate(next),
      canUndo: _undo.isNotEmpty,
      canRedo: _redo.isNotEmpty,
    );
    hooks.onWorkflowChanged?.call(next);
    if (trigger != null) hooks.onTriggerConfigured?.call(trigger);
    _scheduleSave();
  }

  TriggerBinding? _deriveTrigger(WorkflowDoc doc) {
    for (final n in doc.nodes) {
      final t = state.catalog.find(n.def.id)?.trigger;
      if (t != null) {
        return TriggerBinding(
          type: t.type,
          filters: {...t.filters, ...n.config},
        );
      }
    }
    return doc.trigger;
  }

  List<ValidationIssue> _validate(WorkflowDoc doc) {
    final issues = <ValidationIssue>[];
    for (final n in doc.nodes) {
      final type = state.catalog.find(n.def.id);
      if (type == null) {
        issues.add(
          ValidationIssue(
            nodeId: n.iid,
            message: 'Unknown node type "${n.def.id}"',
          ),
        );
        continue;
      }
      for (final f in type.fields.where((f) => f.required)) {
        final v = n.config[f.key];
        if (v == null || '$v'.trim().isEmpty) {
          issues.add(
            ValidationIssue(
              nodeId: n.iid,
              fieldKey: f.key,
              message: '${f.label} is required',
            ),
          );
        }
      }
    }
    return issues;
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      _repo.save(state.doc);
    });
  }

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(state.doc);
    final prev = _undo.removeLast();
    state = state.copyWith(
      doc: prev,
      canUndo: _undo.isNotEmpty,
      canRedo: true,
      validation: _validate(prev),
    );
    hooks.onWorkflowChanged?.call(prev);
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(state.doc);
    final next = _redo.removeLast();
    state = state.copyWith(
      doc: next,
      canUndo: true,
      canRedo: _redo.isNotEmpty,
      validation: _validate(next),
    );
    hooks.onWorkflowChanged?.call(next);
  }

  void setName(String name) => _commit(state.doc.copyWith(name: name));

  void setSearch(String q) => state = state.copyWith(search: q);

  void setSideTab(SidePanelTab tab) => state = state.copyWith(sideTab: tab);

  void toggleSnapToGrid() =>
      state = state.copyWith(snapToGrid: !state.snapToGrid);

  void setSnapToGrid(bool v) => state = state.copyWith(snapToGrid: v);

  void setCatalog(NodeCatalog catalog) {
    // Rebind node defs to new catalog types when possible.
    final nodes = state.doc.nodes.map((n) {
      final t = catalog.find(n.def.id);
      return t == null ? n : n.copyWith(def: t.asDef);
    }).toList();
    state = state.copyWith(catalog: catalog);
    _commit(state.doc.copyWith(nodes: nodes), recordUndo: false);
  }

  void setVariables(VariableSchema schema) =>
      state = state.copyWith(variables: schema);

  void setSampleRecord(Map<String, dynamic> record) =>
      state = state.copyWith(sampleRecord: record);

  void setPanZoom({double? panX, double? panY, double? zoom}) {
    state = state.copyWith(
      panX: panX,
      panY: panY,
      zoom: zoom?.clamp(0.15, 2.5),
    );
  }

  void zoomIn() => setPanZoom(zoom: (state.zoom * 1.2).clamp(0.15, 2.5));
  void zoomOut() => setPanZoom(zoom: (state.zoom / 1.2).clamp(0.15, 2.5));
  void zoomReset() => state = state.copyWith(panX: 80, panY: 90, zoom: 0.82);

  void select(String? id, {bool additive = false}) {
    if (id == null) {
      state = state.copyWith(clearSelected: true, sideTab: SidePanelTab.properties);
      return;
    }
    if (additive) {
      final next = {...state.selectedIds};
      if (next.contains(id)) {
        next.remove(id);
      } else {
        next.add(id);
      }
      state = state.copyWith(
        selectedId: next.isEmpty ? null : id,
        selectedIds: next,
        clearSelected: next.isEmpty,
        sideTab: SidePanelTab.properties,
      );
    } else {
      state = state.copyWith(
        selectedId: id,
        selectedIds: {id},
        sideTab: SidePanelTab.properties,
      );
    }
  }

  void selectMany(Set<String> ids) {
    state = state.copyWith(
      selectedIds: ids,
      selectedId: ids.isEmpty ? null : ids.first,
      clearSelected: ids.isEmpty,
    );
  }

  void moveNode(String iid, double x, double y, {bool snap = false}) {
    final nx = snap || state.snapToGrid ? _snap(x) : x;
    final ny = snap || state.snapToGrid ? _snap(y) : y;
    final nodes = state.doc.nodes
        .map((n) => n.iid == iid ? n.copyWith(x: nx, y: ny) : n)
        .toList();
    // Live move without undo spam; finalize on pointer up via finalizeMove.
    state = state.copyWith(doc: state.doc.copyWith(nodes: nodes));
  }

  void finalizeMove() {
    _commit(state.doc);
  }

  void nudgeSelected(double dx, double dy) {
    if (state.selectedIds.isEmpty && state.selectedId == null) return;
    final ids = state.selectedIds.isEmpty
        ? {state.selectedId!}
        : state.selectedIds;
    final step = state.snapToGrid ? state.gridSize : 1.0;
    final nodes = state.doc.nodes.map((n) {
      if (!ids.contains(n.iid)) return n;
      return n.copyWith(x: _snap(n.x + dx * step), y: _snap(n.y + dy * step));
    }).toList();
    _commit(state.doc.copyWith(nodes: nodes));
  }

  void addNodeFromDef(NodeDef def, double worldX, double worldY) {
    if (state.embedConfig.readOnly) return;
    final type = state.catalog.find(def.id);
    final resolved = type?.asDef ?? def;
    final node = CanvasNode(
      iid: 'n${_uuid.v4().substring(0, 8)}',
      def: resolved,
      x: _snap(worldX - AnchorSpacing.nodeWidth / 2),
      y: _snap(worldY - AnchorSpacing.nodeHeight / 2),
    );
    _commit(state.doc.copyWith(nodes: [...state.doc.nodes, node]));
    select(node.iid);
  }

  void addNodeFromTypeId(String typeId, double worldX, double worldY) {
    final t = state.catalog.find(typeId);
    if (t == null) return;
    addNodeFromDef(t.asDef, worldX, worldY);
  }

  void updateSelectedConfig(String key, dynamic value) {
    final sel = state.selectedNode;
    if (sel == null || state.embedConfig.readOnly) return;
    final config = Map<String, dynamic>.from(sel.config)..[key] = value;
    final nodes = state.doc.nodes
        .map((n) => n.iid == sel.iid ? n.copyWith(config: config) : n)
        .toList();
    _commit(state.doc.copyWith(nodes: nodes));
  }

  void deleteSelected() {
    final ids = {
      ...state.selectedIds,
      if (state.selectedId != null) state.selectedId!,
    };
    if (ids.isEmpty || state.embedConfig.readOnly) return;
    final nodes = state.doc.nodes.where((n) => !ids.contains(n.iid)).toList();
    final wires = state.doc.wires
        .where((w) => !ids.contains(w.from) && !ids.contains(w.to))
        .toList();
    state = state.copyWith(clearSelected: true);
    _commit(state.doc.copyWith(nodes: nodes, wires: wires));
  }

  void deleteNode(String id) {
    select(id);
    deleteSelected();
  }

  void copySelected() {
    final ids = {
      ...state.selectedIds,
      if (state.selectedId != null) state.selectedId!,
    };
    final nodes = state.doc.nodes.where((n) => ids.contains(n.iid)).toList();
    state = state.copyWith(clipboard: nodes);
  }

  void pasteClipboard() {
    if (state.clipboard.isEmpty || state.embedConfig.readOnly) return;
    final offset = state.gridSize * 2;
    final mapped = <String, String>{};
    final pasted = <CanvasNode>[];
    for (final n in state.clipboard) {
      final nid = 'n${_uuid.v4().substring(0, 8)}';
      mapped[n.iid] = nid;
      pasted.add(
        n.copyWith(
          iid: nid,
          x: _snap(n.x + offset),
          y: _snap(n.y + offset),
          status: RunStatus.idle,
        ),
      );
    }
    _commit(state.doc.copyWith(nodes: [...state.doc.nodes, ...pasted]));
    selectMany(pasted.map((n) => n.iid).toSet());
  }

  void startDrawingWire(String fromId, double fx, double fy, {String fromPort = 'out'}) {
    if (state.embedConfig.readOnly) return;
    state = state.copyWith(
      drawingWire: DrawingWire(
        fromId: fromId,
        fromPort: fromPort,
        fx: fx,
        fy: fy,
        tx: fx,
        ty: fy,
      ),
    );
  }

  void updateDrawingWire(double tx, double ty) {
    final dw = state.drawingWire;
    if (dw == null) return;
    state = state.copyWith(drawingWire: dw.copyWith(tx: tx, ty: ty));
  }

  void finishDrawingWire(String? toId, {String toPort = 'in'}) {
    final dw = state.drawingWire;
    if (dw == null) {
      state = state.copyWith(clearDrawingWire: true);
      return;
    }
    if (toId != null &&
        toId != dw.fromId &&
        !state.doc.wires.any(
          (w) =>
              w.from == dw.fromId &&
              w.to == toId &&
              w.fromPort == dw.fromPort &&
              w.toPort == toPort,
        )) {
      final wire = Wire(
        id: 'w${_uuid.v4().substring(0, 8)}',
        from: dw.fromId,
        to: toId,
        fromPort: dw.fromPort,
        toPort: toPort,
      );
      state = state.copyWith(clearDrawingWire: true);
      _commit(state.doc.copyWith(wires: [...state.doc.wires, wire]));
    } else {
      state = state.copyWith(clearDrawingWire: true);
    }
  }

  void deleteWire(String id) {
    if (state.embedConfig.readOnly) return;
    _commit(
      state.doc.copyWith(
        wires: state.doc.wires.where((w) => w.id != id).toList(),
      ),
    );
  }

  void setNodeStatus(String iid, RunStatus status) {
    final nodes = state.doc.nodes
        .map((n) => n.iid == iid ? n.copyWith(status: status) : n)
        .toList();
    state = state.copyWith(doc: state.doc.copyWith(nodes: nodes));
  }

  Future<RunReport?> runWorkflow({
    Map<String, dynamic>? input,
    bool preview = false,
    bool record = false,
  }) async {
    if (state.isRunning || state.isPreviewing) return null;
    _cancelRun = false;
    final sample = input ?? state.sampleRecord;
    final events = <PreviewEvent>[];
    final started = DateTime.now().toUtc();

    state = state.copyWith(
      isRunning: !preview,
      isPreviewing: preview,
      sampleRecord: sample,
      previewEvents: const [],
      sideTab: preview ? SidePanelTab.preview : state.sideTab,
    );

    final report = await _engine.run(
      nodes: state.doc.nodes,
      wires: state.doc.wires,
      input: sample,
      catalog: state.catalog,
      useRandomFailures: !preview,
      onStatus: setNodeStatus,
      onEvent: (e) {
        events.add(e);
        hooks.onPreviewEvent?.call(e);
        state = state.copyWith(previewEvents: List.of(events));
      },
      codePreview: hooks.onRequestCodePreview,
      shouldCancel: () => _cancelRun,
    );

    PreviewRecording? recording;
    if (record || preview) {
      recording = PreviewRecording(
        events: events,
        sampleRecord: sample,
        startedAt: started,
        finishedAt: DateTime.now().toUtc(),
      );
    }

    state = state.copyWith(
      isRunning: false,
      isPreviewing: false,
      lastReport: report,
      lastRecording: recording ?? state.lastRecording,
      sideTab: SidePanelTab.preview,
    );
    _scheduleSave();
    return report;
  }

  Future<RunReport?> startPreview({bool record = true}) =>
      runWorkflow(preview: true, record: record);

  void stopPreview() => _cancelRun = true;

  void replaceWorkflow(WorkflowDoc doc) {
    _undo.clear();
    _redo.clear();
    state = state.copyWith(clearSelected: true, canUndo: false, canRedo: false);
    _commit(doc, recordUndo: false);
  }

  String exportJson() => _repo.encodeWorkflow(state.doc);

  void importJson(String raw) {
    final doc = _repo.decodeWorkflow(raw, state.catalog);
    replaceWorkflow(doc);
  }

  void setEmbedConfig(EmbedConfig config) {
    state = state.copyWith(embedConfig: config);
  }

  void submitInput(Map<String, dynamic> payload, {bool run = true}) {
    state = state.copyWith(sampleRecord: payload);
    if (run) {
      unawaited(runWorkflow(input: payload, preview: true, record: true));
    }
  }

  Future<RunReport?> submitInputAndWait(Map<String, dynamic> payload) async {
    state = state.copyWith(sampleRecord: payload);
    return runWorkflow(input: payload, preview: true, record: true);
  }

  void requestSave() => hooks.onSaveRequested?.call();

  /// Align selected nodes.
  void alignSelected({required bool horizontal}) {
    final ids = state.selectedIds;
    if (ids.length < 2) return;
    final nodes = state.doc.nodes.where((n) => ids.contains(n.iid)).toList();
    if (horizontal) {
      final y = nodes.map((n) => n.y).reduce(math.min);
      final next = state.doc.nodes
          .map((n) => ids.contains(n.iid) ? n.copyWith(y: _snap(y)) : n)
          .toList();
      _commit(state.doc.copyWith(nodes: next));
    } else {
      final x = nodes.map((n) => n.x).reduce(math.min);
      final next = state.doc.nodes
          .map((n) => ids.contains(n.iid) ? n.copyWith(x: _snap(x)) : n)
          .toList();
      _commit(state.doc.copyWith(nodes: next));
    }
  }
}

final workflowProvider =
    NotifierProvider<WorkflowController, WorkflowUiState>(WorkflowController.new);
