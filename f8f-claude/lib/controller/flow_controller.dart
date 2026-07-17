import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show Color, Offset, Path, Rect, Size;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flowstock/data/node_catalog.dart';
import 'package:flowstock/models/models.dart';

enum DragMode { none, pan, node, connect, palette }

/// Serializable graph payload for embed / onRun callbacks.
class FlowGraph {
  const FlowGraph({
    required this.nodes,
    required this.wires,
    required this.name,
  });

  final List<Map<String, dynamic>> nodes;
  final List<Map<String, dynamic>> wires;
  final String name;

  Map<String, dynamic> toJson() => {
        'name': name,
        'nodes': nodes,
        'wires': wires,
      };
}

class FlowController extends ChangeNotifier {
  FlowController({
    this.showMinimap = true,
    this.wireStyle = WireStyle.curved,
    this.snapToGrid = false,
    this.onRun,
  }) {
    nodes = NodeCatalog.demoNodes();
    wires = NodeCatalog.demoWires();
  }

  final bool showMinimap;
  WireStyle wireStyle;
  bool snapToGrid;
  final FutureOr<void> Function(FlowGraph graph)? onRun;

  /// Graph structure + node positions / selection rings on nodes.
  final ValueNotifier<int> graphTick = ValueNotifier(0);

  /// Pan / zoom / temp wire / run badges that need canvas repaint.
  final ValueNotifier<int> viewportTick = ValueNotifier(0);

  /// Top bar, palette open, inspector open, embed, toast, active.
  final ValueNotifier<int> chromeTick = ValueNotifier(0);

  late List<FlowNode> nodes;
  late List<FlowWire> wires;

  Offset pan = const Offset(30, 10);
  double zoom = 0.95;
  String? selectedId;
  String? selectedWireId;
  String query = '';
  GhostDrag? ghost;
  TempWire? temp;
  final Map<String, RunStatus> run = {};
  final Map<String, RunStatus> wrun = {};
  bool running = false;
  String? toast;
  String wfName = 'Ready-for-pickup notifier';
  bool active = true;
  bool embedOpen = false;
  bool panning = false;
  bool paletteOpen = true;
  bool inspectorOpen = true;

  Size canvasSize = Size.zero;
  DragMode mode = DragMode.none;
  int _seq = 10;
  Timer? _toastTimer;
  bool _fittedOnce = false;

  String? _dragNodeId;
  Offset _nodeGrabOffset = Offset.zero;
  Offset _panStart = Offset.zero;
  Offset _panOrigin = Offset.zero;
  ({String id, int port})? _connectFrom;

  /// Last canvas-local pointer position (for edge auto-pan).
  Offset _lastLocal = Offset.zero;
  Ticker? _edgeTicker;
  Duration _lastTick = Duration.zero;

  double _miniMinX = 0;
  double _miniMinY = 0;
  double _miniSc = 1;

  static const double edgeMargin = 40;
  static const double edgeMaxSpeed = 14;

  void _notifyGraph() {
    graphTick.value++;
    notifyListeners();
  }

  void _notifyViewport() {
    viewportTick.value++;
    notifyListeners();
  }

  void _notifyChrome() {
    chromeTick.value++;
    notifyListeners();
  }

  void _notifyAll() {
    graphTick.value++;
    viewportTick.value++;
    chromeTick.value++;
    notifyListeners();
  }

  FlowNode? get selected {
    if (selectedId == null) return null;
    for (final n in nodes) {
      if (n.id == selectedId) return n;
    }
    return null;
  }

  NodeTypeDef? get selectedType {
    final n = selected;
    return n == null ? null : NodeCatalog.typeOf(n.type);
  }

  String get selectedJson {
    final n = selected;
    if (n == null) return '';
    return const JsonEncoder.withIndent('  ').convert({
      'id': n.id,
      'type': n.type,
      'config': n.config,
    });
  }

  FlowGraph exportGraph() => FlowGraph(
        name: wfName,
        nodes: [
          for (final n in nodes)
            {
              'id': n.id,
              'type': n.type,
              'x': n.x,
              'y': n.y,
              'config': Map<String, String>.from(n.config),
            },
        ],
        wires: [
          for (final w in wires)
            {
              'id': w.id,
              'from': w.from,
              'port': w.port,
              'to': w.to,
            },
        ],
      );

  double snap(double v) =>
      snapToGrid ? (v / 12).round() * 12.0 : v.roundToDouble();

  Path wirePath(double x1, double y1, double x2, double y2) {
    final path = Path()..moveTo(x1, y1);
    if (wireStyle == WireStyle.stepped) {
      final mx = (x1 + x2) / 2;
      path
        ..lineTo(mx, y1)
        ..lineTo(mx, y2)
        ..lineTo(x2, y2);
    } else {
      final dx = math.max(46.0, (x2 - x1).abs() / 2);
      path.cubicTo(x1 + dx, y1, x2 - dx, y2, x2, y2);
    }
    return path;
  }

  Offset toWorld(Offset local) =>
      Offset((local.dx - pan.dx) / zoom, (local.dy - pan.dy) / zoom);

  void setCanvasSize(Size size) {
    if (size == canvasSize || size == Size.zero) return;
    canvasSize = size;
    _notifyViewport();
  }

  void ensureFitted() {
    if (_fittedOnce || canvasSize == Size.zero || nodes.isEmpty) return;
    fitView();
    _fittedOnce = true;
  }

  void zoomAt(double cx, double cy, double factor) {
    final z = (zoom * factor).clamp(0.3, 2.0);
    final k = z / zoom;
    zoom = z;
    pan = Offset(cx - (cx - pan.dx) * k, cy - (cy - pan.dy) * k);
    _notifyViewport();
  }

  void zoomIn() => zoomAt(canvasSize.width / 2, canvasSize.height / 2, 1.2);
  void zoomOut() =>
      zoomAt(canvasSize.width / 2, canvasSize.height / 2, 1 / 1.2);

  void fitView() {
    if (nodes.isEmpty || canvasSize == Size.zero) return;
    final xs = nodes.map((n) => n.x);
    final ys = nodes.map((n) => n.y);
    final minX = xs.reduce(math.min) - 60;
    final minY = ys.reduce(math.min) - 60;
    final maxX = xs.reduce(math.max) + NodeCatalog.nodeWidth + 90;
    final maxY = ys.reduce(math.max) + 150;
    final z = math.min(
      1.1,
      math.min(
        canvasSize.width / (maxX - minX),
        canvasSize.height / (maxY - minY),
      ),
    );
    zoom = z;
    pan = Offset(
      (canvasSize.width - (maxX - minX) * z) / 2 - minX * z,
      (canvasSize.height - (maxY - minY) * z) / 2 - minY * z,
    );
    _notifyViewport();
  }

  void setQuery(String q) {
    query = q;
    _notifyChrome();
  }

  void setWfName(String name) {
    wfName = name;
    _notifyChrome();
  }

  void toggleActive() {
    active = !active;
    _notifyChrome();
  }

  void togglePalette() {
    paletteOpen = !paletteOpen;
    _notifyChrome();
  }

  void toggleInspector() {
    inspectorOpen = !inspectorOpen;
    _notifyChrome();
  }

  void openEmbed() {
    embedOpen = true;
    _notifyChrome();
  }

  void closeEmbed() {
    embedOpen = false;
    _notifyChrome();
  }

  void updateField(String key, String value) {
    final n = selected;
    if (n == null) return;
    n.config[key] = value;
    _notifyGraph();
    _notifyChrome();
  }

  void bringToFront(String id) {
    final i = nodes.indexWhere((n) => n.id == id);
    if (i < 0 || i == nodes.length - 1) return;
    final n = nodes.removeAt(i);
    nodes.add(n);
  }

  void removeNode(String id) {
    nodes.removeWhere((n) => n.id == id);
    wires.removeWhere((w) => w.from == id || w.to == id);
    if (selectedId == id) selectedId = null;
    _notifyAll();
  }

  void deleteSelection() {
    if (selectedId != null) {
      removeNode(selectedId!);
    } else if (selectedWireId != null) {
      wires.removeWhere((w) => w.id == selectedWireId);
      selectedWireId = null;
      _notifyGraph();
    }
  }

  void selectNode(String id, {bool openInspector = true}) {
    selectedId = id;
    selectedWireId = null;
    if (openInspector) inspectorOpen = true;
    bringToFront(id);
    _notifyGraph();
    if (openInspector) _notifyChrome();
  }

  void selectWire(String id) {
    selectedWireId = id;
    selectedId = null;
    _notifyGraph();
  }

  void clearSelection() {
    if (selectedId == null && selectedWireId == null) return;
    selectedId = null;
    selectedWireId = null;
    _notifyGraph();
  }

  /// Set by overlay chrome (zoom, minimap, chevrons) so background won't pan.
  bool suppressBackgroundPan = false;

  void startPan(Offset local) {
    if (suppressBackgroundPan) return;
    mode = DragMode.pan;
    _panStart = local;
    _panOrigin = pan;
    panning = true;
    _lastLocal = local;
    clearSelection();
    _notifyViewport();
  }

  void startNodeDrag(String id, Offset world) {
    final n = nodes.firstWhere((e) => e.id == id);
    mode = DragMode.node;
    _dragNodeId = id;
    _nodeGrabOffset = Offset(world.dx - n.x, world.dy - n.y);
    final already = selectedId == id;
    selectedId = id;
    selectedWireId = null;
    inspectorOpen = true;
    bringToFront(id);
    if (!already) {
      _notifyGraph();
      _notifyChrome();
    } else {
      _notifyGraph();
    }
    _startEdgeTicker();
  }

  void startConnect(String nodeId, int port) {
    mode = DragMode.connect;
    _connectFrom = (id: nodeId, port: port);
    final n = nodes.firstWhere((e) => e.id == nodeId);
    final p = NodeCatalog.outPos(n, port);
    temp = TempWire(x1: p.dx, y1: p.dy, x2: p.dx, y2: p.dy);
    _notifyViewport();
    _startEdgeTicker();
  }

  void startPaletteDrag(String type, Offset global) {
    mode = DragMode.palette;
    ghost = GhostDrag(type: type, x: global.dx, y: global.dy);
    _notifyViewport();
  }

  void onPointerMove({
    required Offset local,
    required Offset global,
  }) {
    _lastLocal = local;
    switch (mode) {
      case DragMode.pan:
        pan = _panOrigin + (local - _panStart);
        _notifyViewport();
      case DragMode.node:
        _applyNodeDrag(local);
      case DragMode.connect:
        final w = toWorld(local);
        temp?.x2 = w.dx;
        temp?.y2 = w.dy;
        _notifyViewport();
      case DragMode.palette:
        ghost?.x = global.dx;
        ghost?.y = global.dy;
        _notifyViewport();
      case DragMode.none:
        break;
    }
  }

  void _applyNodeDrag(Offset local) {
    final w = toWorld(local);
    final n = nodes.firstWhere((e) => e.id == _dragNodeId);
    n.x = snap(w.dx - _nodeGrabOffset.dx);
    n.y = snap(w.dy - _nodeGrabOffset.dy);
    _notifyGraph();
    _notifyViewport();
  }

  void onPointerUp({
    required Offset local,
    required Offset global,
    required bool overCanvas,
  }) {
    if (mode == DragMode.none) return;
    _stopEdgeTicker();
    if (mode == DragMode.palette && overCanvas && ghost != null) {
      final w = toWorld(local);
      final id = 'n${++_seq}';
      nodes.add(
        FlowNode(
          id: id,
          type: ghost!.type,
          x: snap(w.dx - NodeCatalog.nodeWidth / 2),
          y: snap(w.dy - 30),
          config: NodeCatalog.defaultConfig(ghost!.type),
        ),
      );
      selectedId = id;
      selectedWireId = null;
      inspectorOpen = true;
      run.clear();
      wrun.clear();
    }
    if (mode == DragMode.connect && overCanvas) {
      final w = toWorld(local);
      final target = _nodeAt(w);
      if (target != null) {
        finishConnect(target);
        return;
      }
      temp = null;
    }
    mode = DragMode.none;
    ghost = null;
    panning = false;
    suppressBackgroundPan = false;
    _dragNodeId = null;
    _connectFrom = null;
    _notifyAll();
  }

  String? _nodeAt(Offset world) {
    for (final n in nodes.reversed) {
      final def = NodeCatalog.typeOf(n.type);
      final h = def.summary(n.config).trim().isEmpty ? 58.0 : 86.0;
      final rect = Rect.fromLTWH(n.x, n.y, NodeCatalog.nodeWidth, h);
      final hit =
          Rect.fromLTRB(rect.left - 10, rect.top, rect.right + 10, rect.bottom);
      if (hit.contains(world)) return n.id;
    }
    return null;
  }

  void finishConnect(String toId) {
    if (mode != DragMode.connect || _connectFrom == null) return;
    final from = _connectFrom!;
    mode = DragMode.none;
    _stopEdgeTicker();
    if (from.id == toId) {
      temp = null;
      _connectFrom = null;
      _notifyViewport();
      return;
    }
    final toType = NodeCatalog.typeOf(
      nodes.firstWhere((n) => n.id == toId).type,
    );
    if (toType.category == NodeCategory.trigger) {
      temp = null;
      _connectFrom = null;
      _notifyViewport();
      return;
    }
    final exists = wires.any(
      (w) => w.from == from.id && w.port == from.port && w.to == toId,
    );
    if (!exists) {
      wires.add(
        FlowWire(
          id: 'w${++_seq}',
          from: from.id,
          port: from.port,
          to: toId,
        ),
      );
      run.clear();
      wrun.clear();
    }
    temp = null;
    _connectFrom = null;
    _notifyAll();
  }

  void cancelTemp() {
    if (temp == null && mode != DragMode.connect) return;
    temp = null;
    if (mode == DragMode.connect) mode = DragMode.none;
    _connectFrom = null;
    _stopEdgeTicker();
    _notifyViewport();
  }

  void attachTickerProvider(TickerProvider vsync) {
    _edgeTicker?.dispose();
    _edgeTicker = vsync.createTicker(_onEdgeTick);
  }

  void _startEdgeTicker() {
    _lastTick = Duration.zero;
    _edgeTicker?.start();
  }

  void _stopEdgeTicker() {
    _edgeTicker?.stop();
    _lastTick = Duration.zero;
  }

  void _onEdgeTick(Duration elapsed) {
    if (mode != DragMode.node && mode != DragMode.connect) {
      _stopEdgeTicker();
      return;
    }
    if (canvasSize == Size.zero) return;

    final dt = _lastTick == Duration.zero
        ? 1 / 60
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0) return;

    final local = _lastLocal;
    var dx = 0.0;
    var dy = 0.0;

    if (local.dx < edgeMargin) {
      dx = _edgeSpeed(edgeMargin - local.dx) * dt * 60;
    } else if (local.dx > canvasSize.width - edgeMargin) {
      dx = -_edgeSpeed(local.dx - (canvasSize.width - edgeMargin)) * dt * 60;
    }
    if (local.dy < edgeMargin) {
      dy = _edgeSpeed(edgeMargin - local.dy) * dt * 60;
    } else if (local.dy > canvasSize.height - edgeMargin) {
      dy = -_edgeSpeed(local.dy - (canvasSize.height - edgeMargin)) * dt * 60;
    }

    if (dx == 0 && dy == 0) return;

    pan = Offset(pan.dx + dx, pan.dy + dy);
    if (mode == DragMode.node) {
      _applyNodeDrag(local);
    } else if (mode == DragMode.connect) {
      final w = toWorld(local);
      temp?.x2 = w.dx;
      temp?.y2 = w.dy;
      _notifyViewport();
    } else {
      _notifyViewport();
    }
  }

  /// Test helper: advances edge auto-pan as if a ticker fired.
  @visibleForTesting
  void debugEdgeTick(Duration elapsed) => _onEdgeTick(elapsed);

  double _edgeSpeed(double depth) {
    final t = (depth / edgeMargin).clamp(0.0, 1.0);
    return edgeMaxSpeed * t * t;
  }

  void minimapJump(Offset localInMini) {
    if (nodes.isEmpty) return;
    final wx = (localInMini.dx - 4) / _miniSc + _miniMinX;
    final wy = (localInMini.dy - 4) / _miniSc + _miniMinY;
    pan = Offset(
      canvasSize.width / 2 - wx * zoom,
      canvasSize.height / 2 - wy * zoom,
    );
    _notifyViewport();
  }

  ({
    List<({double l, double t, double w, double h, Color c})> nodes,
    Rect vp,
  }) minimapLayout() {
    if (nodes.isEmpty) {
      return (nodes: const [], vp: Rect.zero);
    }
    final xs = nodes.map((n) => n.x);
    final ys = nodes.map((n) => n.y);
    final minX = xs.reduce(math.min) - 120;
    final minY = ys.reduce(math.min) - 120;
    final maxX = xs.reduce(math.max) + NodeCatalog.nodeWidth + 120;
    final maxY = ys.reduce(math.max) + 200;
    final sc = math.min(160 / (maxX - minX), 96 / (maxY - minY));
    _miniMinX = minX;
    _miniMinY = minY;
    _miniSc = sc;

    final miniNodes = nodes
        .map(
          (n) => (
            l: (n.x - minX) * sc + 4,
            t: (n.y - minY) * sc + 4,
            w: math.max(4.0, NodeCatalog.nodeWidth * sc),
            h: math.max(3.0, 62 * sc),
            c: selectedId == n.id
                ? const Color(0xFF3B82F6)
                : const Color(0xFF94A3B8),
          ),
        )
        .toList();

    final rawVp = Rect.fromLTWH(
      (-pan.dx / zoom - minX) * sc + 4,
      (-pan.dy / zoom - minY) * sc + 4,
      canvasSize.width / zoom * sc,
      canvasSize.height / zoom * sc,
    );
    final bounds = const Rect.fromLTWH(0, 0, 168, 104);
    final vp = Rect.fromLTRB(
      rawVp.left.clamp(bounds.left, bounds.right),
      rawVp.top.clamp(bounds.top, bounds.bottom),
      rawVp.right.clamp(bounds.left, bounds.right),
      rawVp.bottom.clamp(bounds.top, bounds.bottom),
    );
    return (nodes: miniNodes, vp: vp);
  }

  Future<void> runFlow() async {
    if (running) return;
    running = true;
    run.clear();
    wrun.clear();
    toast = null;
    _notifyAll();

    final graph = exportGraph();
    final hook = onRun;
    if (hook != null) {
      await hook(graph);
    }

    var level = nodes
        .where((n) => !wires.any((w) => w.to == n.id))
        .map((n) => n.id)
        .toList();
    final seen = <String>{};
    var steps = 0;
    final t0 = DateTime.now();

    while (level.isNotEmpty) {
      level = level.where((id) => !seen.contains(id)).toList();
      if (level.isEmpty) break;
      for (final id in level) {
        seen.add(id);
      }
      steps += level.length;
      for (final id in level) {
        run[id] = RunStatus.running;
      }
      for (final w in wires) {
        if (level.contains(w.to)) wrun[w.id] = RunStatus.running;
      }
      _notifyGraph();
      _notifyViewport();
      await Future<void>.delayed(const Duration(milliseconds: 620));
      for (final id in level) {
        run[id] = RunStatus.done;
      }
      for (final w in wires) {
        if (level.contains(w.to)) wrun[w.id] = RunStatus.done;
      }
      _notifyGraph();
      _notifyViewport();
      level = wires
          .where((w) => level.contains(w.from))
          .map((w) => w.to)
          .toList();
    }

    final secs = DateTime.now().difference(t0).inMilliseconds / 1000;
    running = false;
    toast = 'Run complete · $steps steps · ${secs.toStringAsFixed(1)}s';
    _notifyAll();
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 3800), () {
      toast = null;
      _notifyChrome();
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _edgeTicker?.dispose();
    graphTick.dispose();
    viewportTick.dispose();
    chromeTick.dispose();
    super.dispose();
  }
}
