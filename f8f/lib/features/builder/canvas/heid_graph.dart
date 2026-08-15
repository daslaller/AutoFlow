import 'package:flutter/material.dart';
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';
import 'package:uuid/uuid.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/heid_prototypes.dart';
import 'package:autoflow/features/builder/canvas/heid_style.dart';

/// Owns the live HeidNodes controller used as AutoFlow's editor canvas.
class HeidGraph {
  HeidGraph({
    required NodeCatalog catalog,
    required this.session,
    bool snapToGrid = true,
    double gridSize = 28,
  }) : controller = FlNodesController(
          appVersion: '1.0.0',
          config: HeidStyle.editorConfig(
            snapToGrid: snapToGrid,
            gridSize: gridSize,
          ),
          style: HeidStyle.editor(),
        ) {
    session.catalog = catalog;
    registerCatalogPrototypes(controller, catalog, session);
  }

  final FlNodesController controller;
  final PreviewSession session;

  bool _applying = false;
  bool get isApplying => _applying;

  void attachCatalog(NodeCatalog catalog) {
    session.catalog = catalog;
    registerCatalogPrototypes(controller, catalog, session);
  }

  void setSnapToGrid(bool snap, {double gridSize = 28}) {
    // Rebuild the full config. FlNodesConfig.copyWith drops autoBuildGraph /
    // autoExecGraph / autoSave, which would re-enable live execute-on-edit.
    controller.setConfig(
      HeidStyle.editorConfig(snapToGrid: snap, gridSize: gridSize),
    );
  }

  /// Run [fn] without treating HeidNodes events as user edits. Callers should
  /// export/commit the graph after this returns if it changed.
  Future<void> mutate(Future<void> Function() fn) async {
    _applying = true;
    try {
      await fn();
    } finally {
      await Future<void>.delayed(Duration.zero);
      _applying = false;
    }
  }

  /// Set HeidNodes selection without [FlNodesController.selectNodesById],
  /// which internally [FlNodesController.clearSelection]s with `isHandled:
  /// false` and would bounce back as an AutoFlow deselect.
  void setSelection(Set<String> ids) {
    final previous = controller.selectedNodeIds.toSet();
    for (final id in previous) {
      controller.nodes[id]?.state.isSelected = false;
    }
    controller.selectedNodeIds
      ..clear()
      ..addAll(ids);
    for (final id in ids) {
      controller.nodes[id]?.state.isSelected = true;
    }
    notifyLayout();
  }

  /// Force the mounted editor to pick up programmatic offset/port changes.
  void notifyLayout() {
    controller.nodesDataDirty = true;
    controller.eventBus.emit(
      FlConfigurationChangeEvent(
        controller.config,
        id: const Uuid().v4(),
      ),
    );
  }

  /// Replace the live graph with [doc], preserving AutoFlow instance ids.
  Future<void> loadDoc(WorkflowDoc doc, NodeCatalog catalog) async {
    await mutate(() async {
      for (final id in controller.nodes.keys.toList()) {
        await controller.removeNodeById(id, isHandled: true);
      }
      for (final id in controller.links.keys.toList()) {
        controller.removeLinkById(id, isHandled: true);
      }

      for (final node in doc.nodes) {
        final proto = controller.nodePrototypes[node.def.id];
        if (proto == null) continue;
        controller.addNodeFromExisting(
          _instanceFromCanvas(proto, node),
          isHandled: true,
        );
      }
      for (final wire in doc.wires) {
        if (!controller.nodes.containsKey(wire.from) ||
            !controller.nodes.containsKey(wire.to)) {
          continue;
        }
        final fromNode = controller.nodes[wire.from]!;
        final toNode = controller.nodes[wire.to]!;
        if (!fromNode.ports.containsKey(wire.fromPort) ||
            !toNode.ports.containsKey(wire.toPort)) {
          continue;
        }
        controller.addLinkFromExisting(
          FlLinkDataModel(
            id: wire.id,
            ports: (
              (nodeId: wire.from, portId: wire.fromPort),
              (nodeId: wire.to, portId: wire.toPort),
            ),
            state: FlLinkState(),
          ),
          isHandled: true,
        );
      }
    });
  }

  WorkflowDoc exportDoc(
    WorkflowDoc shell,
    NodeCatalog catalog, {
    Map<String, RunStatus> statuses = const {},
  }) {
    final nodes = <CanvasNode>[];
    for (final fl in controller.nodes.values) {
      final type = catalog.find(fl.prototype.idName);
      final def = type?.asDef ??
          NodeDef(
            id: fl.prototype.idName,
            kind: NodeKind.action,
            label: fl.prototype.idName,
            sublabel: '',
          );
      nodes.add(
        CanvasNode(
          iid: fl.id,
          def: def,
          x: fl.offset.dx,
          y: fl.offset.dy,
          status: statuses[fl.id] ?? RunStatus.idle,
          config: _configFromFields(fl),
        ),
      );
    }

    final wires = <Wire>[];
    for (final link in controller.links.values) {
      final src = FlNodesUtils.getSource(controller, link);
      final dst = FlNodesUtils.getDestination(controller, link);
      wires.add(
        Wire(
          id: link.id,
          from: src.nodeId,
          fromPort: src.portId,
          to: dst.nodeId,
          toPort: dst.portId,
        ),
      );
    }

    return shell.copyWith(nodes: nodes, wires: wires);
  }

  FlNodeDataModel addCanvasNode({
    required String typeId,
    required Offset offset,
    String? iid,
    Map<String, String> config = const {},
  }) {
    final proto = controller.nodePrototypes[typeId];
    if (proto == null) {
      throw StateError('Unknown node type $typeId');
    }
    if (iid != null) {
      final instance = _instanceFromCanvas(
        proto,
        CanvasNode(
          iid: iid,
          def: NodeDef(
            id: typeId,
            kind: NodeKind.action,
            label: typeId,
            sublabel: '',
          ),
          x: offset.dx,
          y: offset.dy,
          config: config,
        ),
      );
      controller.addNodeFromExisting(instance);
      return instance;
    }
    final created = controller.addNode(typeId, offset: offset);
    created.fields[kHeidIidField]?.data = created.id;
    for (final e in config.entries) {
      created.fields[e.key]?.data = e.value;
    }
    return created;
  }

  void dispose() => controller.dispose();
}

Map<String, String> _configFromFields(FlNodeDataModel node) {
  final out = <String, String>{};
  for (final e in node.fields.entries) {
    if (e.key == kHeidIidField) continue;
    out[e.key] = '${e.value.data ?? ''}';
  }
  return out;
}

FlNodeDataModel _instanceFromCanvas(FlNodePrototype proto, CanvasNode node) {
  return FlNodeDataModel(
    id: node.iid,
    prototype: proto,
    ports: {
      for (final p in proto.portPrototypes)
        p.idName: FlPortDataModel(prototype: p, state: FlPortState()),
    },
    fields: {
      for (final f in proto.fieldPrototypes)
        f.idName: FlFieldDataModel(
          prototype: f,
          data: f.idName == kHeidIidField
              ? node.iid
              : (node.config[f.idName] ?? f.defaultData),
        ),
    },
    customData: <String, dynamic>{},
    state: FlNodeState(),
    offset: Offset(node.x, node.y),
  );
}
