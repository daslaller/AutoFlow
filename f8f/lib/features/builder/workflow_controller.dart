import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';
import 'package:uuid/uuid.dart';
import 'package:autoflow/data/workflow_repository.dart';
import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/demo_workflow.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/domain/records.dart';
import 'package:autoflow/domain/variables.dart';
import 'package:autoflow/features/builder/canvas/heid_graph.dart';
import 'package:autoflow/features/builder/canvas/heid_prototypes.dart';

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
    this.previewRecords = const [],
    this.selectedRecordId,
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
  final List<DataRecord> previewRecords;
  final String? selectedRecordId;
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

  DataRecord? get selectedRecord {
    final id = selectedRecordId;
    if (id == null) return null;
    for (final r in previewRecords) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Variables the inspector should offer. A selected shop record wins so
  /// its fields become the `{{path}}` dictionary; otherwise the host schema.
  VariableSchema get effectiveVariables {
    if (sampleRecord.isNotEmpty) {
      final fromRecord = schemaFromRecordData(sampleRecord);
      if (fromRecord.groups.isNotEmpty) return fromRecord;
    }
    return variables;
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
    List<DataRecord>? previewRecords,
    String? selectedRecordId,
    bool clearSelectedRecord = false,
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
      previewRecords: previewRecords ?? this.previewRecords,
      selectedRecordId: clearSelectedRecord
          ? null
          : (selectedRecordId ?? this.selectedRecordId),
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
  final _uuid = const Uuid();
  Timer? _saveDebounce;
  bool _cancelRun = false;
  WorkflowHostHooks hooks = const WorkflowHostHooks();
  late final HeidGraph graph;
  StreamSubscription<NodeEditorEvent>? _heidSub;

  final List<WorkflowDoc> _undo = [];
  final List<WorkflowDoc> _redo = [];

  @override
  WorkflowUiState build() {
    final catalog = buildDefaultCatalog();
    graph = HeidGraph(catalog: catalog, session: PreviewSession());
    _heidSub = graph.controller.eventBus.events.listen(_onHeidEvent);
    ref.onDispose(() {
      _heidSub?.cancel();
      _cancelRun = true;
      graph.controller.runner.abort();
      graph.dispose();
    });
    Future.microtask(_bootstrap);
    final records = buildDefaultPreviewRecords();
    final first = records.first;
    return WorkflowUiState(
      doc: createDemoWorkflow(),
      catalog: catalog,
      variables: buildDefaultVariableSchema(),
      sampleRecord: first.data,
      previewRecords: records,
      selectedRecordId: first.id,
    );
  }

  void _onHeidEvent(NodeEditorEvent event) {
    if (graph.isApplying || event.isHandled) return;
    if (event is FlNodeSelectionEvent) {
      if (event.type == FlSelectionEventType.deselect) {
        select(null, fromHeid: true);
      } else {
        selectMany(event.nodeIds, fromHeid: true);
      }
      return;
    }
    if (event is FlViewportOffsetEvent) {
      state = state.copyWith(
        panX: graph.controller.viewportOffset.dx,
        panY: graph.controller.viewportOffset.dy,
      );
      return;
    }
    if (event is FlViewportZoomEvent) {
      state = state.copyWith(zoom: graph.controller.viewportZoom);
      return;
    }
    if (event is FlAddNodeEvent ||
        event is FlRemoveNodeEvent ||
        event is FlAddLinkEvent ||
        event is FlRemoveLinkEvent ||
        event is FlDragSelectionCommitEvent ||
        event is FlPasteSelectionEvent) {
      if (state.embedConfig.readOnly) {
        unawaited(graph.loadDoc(state.doc, state.catalog));
        return;
      }
      _syncFromHeid();
    }
  }

  void _syncFromHeid({bool recordUndo = true}) {
    final statuses = {
      for (final n in state.doc.nodes) n.iid: n.status,
    };
    _commit(
      graph.exportDoc(state.doc, state.catalog, statuses: statuses),
      recordUndo: recordUndo,
    );
  }

  Future<void> _bootstrap() async {
    final doc = await _repo.load(state.catalog);
    await graph.loadDoc(doc, state.catalog);
    final exported = graph.exportDoc(doc, state.catalog);
    state = state.copyWith(
      doc: exported,
      ready: true,
      validation: _validate(exported),
    );
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
        if (v == null || v.trim().isEmpty) {
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
    unawaited(_restoreDoc(prev, canUndo: _undo.isNotEmpty, canRedo: true));
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(state.doc);
    final next = _redo.removeLast();
    unawaited(_restoreDoc(next, canUndo: true, canRedo: _redo.isNotEmpty));
  }

  Future<void> _restoreDoc(
    WorkflowDoc doc, {
    required bool canUndo,
    required bool canRedo,
  }) async {
    await graph.loadDoc(doc, state.catalog);
    state = state.copyWith(
      doc: doc,
      canUndo: canUndo,
      canRedo: canRedo,
      validation: _validate(doc),
    );
    hooks.onWorkflowChanged?.call(doc);
  }

  void setName(String name) => _commit(state.doc.copyWith(name: name));

  void setSearch(String q) => state = state.copyWith(search: q);

  void setSideTab(SidePanelTab tab) => state = state.copyWith(sideTab: tab);

  void toggleSnapToGrid() {
    final next = !state.snapToGrid;
    graph.setSnapToGrid(next, gridSize: state.gridSize);
    state = state.copyWith(snapToGrid: next);
  }

  void setSnapToGrid(bool v) {
    graph.setSnapToGrid(v, gridSize: state.gridSize);
    state = state.copyWith(snapToGrid: v);
  }

  void setCatalog(NodeCatalog catalog) {
    graph.attachCatalog(catalog);
    final nodes = state.doc.nodes.map((n) {
      final t = catalog.find(n.def.id);
      return t == null ? n : n.copyWith(def: t.asDef);
    }).toList();
    state = state.copyWith(catalog: catalog);
    final next = state.doc.copyWith(nodes: nodes);
    unawaited(() async {
      await graph.loadDoc(next, catalog);
      _commit(graph.exportDoc(next, catalog), recordUndo: false);
    }());
  }

  void setVariables(VariableSchema schema) =>
      state = state.copyWith(variables: schema);

  void setSampleRecord(Map<String, dynamic> record) {
    String? matchId;
    for (final r in state.previewRecords) {
      if (_mapsEqual(r.data, record) || r.id == record['id']) {
        matchId = r.id;
        break;
      }
    }
    state = state.copyWith(
      sampleRecord: record,
      selectedRecordId: matchId,
      clearSelectedRecord: matchId == null,
    );
  }

  void setPreviewRecords(List<DataRecord> records) {
    final keep = state.selectedRecordId;
    final still = records.any((r) => r.id == keep);
    final next = still
        ? records.firstWhere((r) => r.id == keep)
        : (records.isEmpty ? null : records.first);
    state = state.copyWith(
      previewRecords: records,
      selectedRecordId: next?.id,
      clearSelectedRecord: next == null,
      sampleRecord: next?.data ?? state.sampleRecord,
    );
  }

  void selectRecord(String? id) {
    if (id == null) {
      state = state.copyWith(clearSelectedRecord: true);
      return;
    }
    DataRecord? rec;
    for (final r in state.previewRecords) {
      if (r.id == id) {
        rec = r;
        break;
      }
    }
    if (rec == null) return;
    state = state.copyWith(
      selectedRecordId: rec.id,
      sampleRecord: rec.data,
      sideTab: SidePanelTab.records,
    );
  }

  bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }

  void setPanZoom({double? panX, double? panY, double? zoom}) {
    if (panX != null || panY != null) {
      graph.controller.setViewportOffset(
        Offset(panX ?? state.panX, panY ?? state.panY),
        absolute: true,
        animate: false,
      );
    }
    if (zoom != null) {
      graph.controller.setViewportZoom(
        zoom.clamp(0.15, 2.5),
        absolute: true,
        animate: false,
      );
    }
    state = state.copyWith(
      panX: panX,
      panY: panY,
      zoom: zoom?.clamp(0.15, 2.5),
    );
  }

  void zoomIn() => setPanZoom(zoom: (state.zoom * 1.2).clamp(0.15, 2.5));
  void zoomOut() => setPanZoom(zoom: (state.zoom / 1.2).clamp(0.15, 2.5));
  void zoomReset() {
    graph.controller.setViewportOffset(Offset.zero, absolute: true, animate: false);
    graph.controller.setViewportZoom(0.82, absolute: true, animate: false);
    state = state.copyWith(panX: 80, panY: 90, zoom: 0.82);
  }

  void select(String? id, {bool additive = false, bool fromHeid = false}) {
    if (id == null) {
      state = state.copyWith(clearSelected: true, sideTab: SidePanelTab.properties);
      if (!fromHeid) graph.setSelection(const {});
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
      if (!fromHeid) graph.setSelection(next);
    } else {
      state = state.copyWith(
        selectedId: id,
        selectedIds: {id},
        sideTab: SidePanelTab.properties,
      );
      if (!fromHeid) graph.setSelection({id});
    }
  }

  void selectMany(Set<String> ids, {bool fromHeid = false}) {
    state = state.copyWith(
      selectedIds: ids,
      selectedId: ids.isEmpty ? null : ids.first,
      clearSelected: ids.isEmpty,
    );
    if (!fromHeid) graph.setSelection(ids);
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
    for (final id in ids) {
      final node = graph.controller.nodes[id];
      if (node == null) continue;
      node.offset = Offset(
        _snap(node.offset.dx + dx * step),
        _snap(node.offset.dy + dy * step),
      );
    }
    graph.notifyLayout();
    _syncFromHeid();
  }

  void addNodeFromDef(NodeDef def, double worldX, double worldY) {
    if (state.embedConfig.readOnly) return;
    final type = state.catalog.find(def.id);
    final resolved = type?.asDef ?? def;
    final iid = 'n${_uuid.v4().substring(0, 8)}';
    graph.addCanvasNode(
      typeId: resolved.id,
      iid: iid,
      offset: Offset(_snap(worldX), _snap(worldY)),
    );
    select(iid);
  }

  void addNodeFromTypeId(String typeId, double worldX, double worldY) {
    final t = state.catalog.find(typeId);
    if (t == null) return;
    addNodeFromDef(t.asDef, worldX, worldY);
  }

  void updateSelectedConfig(String key, String value) {
    final sel = state.selectedNode;
    if (sel == null || state.embedConfig.readOnly) return;
    final fl = graph.controller.nodes[sel.iid];
    if (fl != null && fl.fields.containsKey(key)) {
      graph.controller.setFieldData(
        sel.iid,
        key,
        eventType: FlFieldEventType.submit,
        data: value,
      );
    }
    final config = Map<String, String>.from(sel.config)..[key] = value;
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
    unawaited(() async {
      await graph.mutate(() async {
        for (final id in ids) {
          await graph.controller.removeNodeById(id, isHandled: true);
        }
      });
      select(null, fromHeid: true);
      graph.setSelection(const {});
      _syncFromHeid();
    }());
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
    final pastedIds = <String>{};
    unawaited(() async {
      await graph.mutate(() async {
        for (final n in state.clipboard) {
          final nid = 'n${_uuid.v4().substring(0, 8)}';
          pastedIds.add(nid);
          graph.addCanvasNode(
            typeId: n.def.id,
            iid: nid,
            offset: Offset(_snap(n.x + offset), _snap(n.y + offset)),
            config: n.config,
          );
        }
      });
      graph.setSelection(pastedIds);
      selectMany(pastedIds, fromHeid: true);
      _syncFromHeid();
    }());
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
    if (toId != null && toId != dw.fromId) {
      graph.controller.addLink(dw.fromId, dw.fromPort, toId, toPort);
    }
    state = state.copyWith(clearDrawingWire: true);
  }

  void deleteWire(String id) {
    if (state.embedConfig.readOnly) return;
    graph.controller.removeLinkById(id);
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

    graph.session.reset(
      input: sample,
      catalog: state.catalog,
      codePreview: hooks.onRequestCodePreview,
      shouldCancel: () => _cancelRun,
      onStatus: setNodeStatus,
      onEvent: (e) {
        events.add(e);
        hooks.onPreviewEvent?.call(e);
        state = state.copyWith(previewEvents: List.of(events));
      },
      useRandomFailures: !preview,
    );

    for (final n in state.doc.nodes) {
      setNodeStatus(n.iid, RunStatus.idle);
    }
    await Future<void>.delayed(const Duration(milliseconds: 120));

    graph.controller.runner.buildGraph();
    await graph.controller.runner.executeGraph();

    final report = RunReport(
      order: List.of(graph.session.order),
      results: List.of(graph.session.results),
      input: sample,
      finishedAt: DateTime.now().toUtc(),
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

  void stopPreview() {
    _cancelRun = true;
    graph.controller.runner.abort();
  }

  Future<void> replaceWorkflow(WorkflowDoc doc) async {
    _undo.clear();
    _redo.clear();
    state = state.copyWith(clearSelected: true, canUndo: false, canRedo: false);
    await graph.loadDoc(doc, state.catalog);
    _commit(graph.exportDoc(doc, state.catalog), recordUndo: false);
  }

  String exportJson() => _repo.encodeWorkflow(state.doc);

  void importJson(String raw) {
    final doc = _repo.decodeWorkflow(raw, state.catalog);
    unawaited(replaceWorkflow(doc));
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
    final nodes = [
      for (final id in ids) graph.controller.nodes[id],
    ].whereType<FlNodeDataModel>().toList();
    if (nodes.length < 2) return;
    if (horizontal) {
      final y = nodes.map((n) => n.offset.dy).reduce(math.min);
      for (final n in nodes) {
        n.offset = Offset(n.offset.dx, _snap(y));
      }
    } else {
      final x = nodes.map((n) => n.offset.dx).reduce(math.min);
      for (final n in nodes) {
        n.offset = Offset(_snap(x), n.offset.dy);
      }
    }
    graph.notifyLayout();
    _syncFromHeid();
  }
}

final workflowProvider =
    NotifierProvider<WorkflowController, WorkflowUiState>(WorkflowController.new);
