import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/node_card.dart';
import 'package:autoflow/features/builder/canvas/wire_painter.dart';
import 'package:autoflow/features/builder/workflow_controller.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';
import 'package:autoflow/theme/anchor_typography.dart';

enum _DragMode { none, pan, node, wire }

class _PortHit {
  const _PortHit(this.nodeId, this.side);
  final String nodeId;
  final PortSide side;
}

class WorkflowCanvas extends ConsumerStatefulWidget {
  const WorkflowCanvas({super.key});

  @override
  ConsumerState<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends ConsumerState<WorkflowCanvas>
    with TickerProviderStateMixin {
  final _focus = FocusNode();
  late final AnimationController _dashCtrl;
  Ticker? _autoPanTicker;
  Duration _lastAutoPan = Duration.zero;

  _DragMode _mode = _DragMode.none;
  Offset _pointerScreen = Offset.zero;
  Offset _startScreen = Offset.zero;
  double _startPanX = 0;
  double _startPanY = 0;
  String? _dragNodeId;
  Offset _grabOffset = Offset.zero;
  WirePainter? _lastPainter;

  String? _hoveredWireId;
  String? _hoveredNodeId;
  _PortHit? _hoveredPort;
  String? _snapTargetId;
  Size _viewportSize = Size.zero;

  static const _edgeMargin = 56.0;
  static const _autoPanSpeed = 520.0; // px/sec at full edge strength

  @override
  void initState() {
    super.initState();
    _dashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
  }

  @override
  void dispose() {
    _autoPanTicker?.dispose();
    _dashCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Offset _screenToWorld(Offset screen, WorkflowUiState s) {
    return Offset(
      (screen.dx - s.panX) / s.zoom,
      (screen.dy - s.panY) / s.zoom,
    );
  }

  bool _hitOutput(CanvasNode n, Offset world) {
    final px = n.x + AnchorSpacing.nodeWidth;
    final py = n.y + AnchorSpacing.nodeHeight / 2;
    return (Offset(px, py) - world).distance < AnchorSpacing.portRadius + 12;
  }

  bool _hitInput(CanvasNode n, Offset world) {
    final px = n.x;
    final py = n.y + AnchorSpacing.nodeHeight / 2;
    return (Offset(px, py) - world).distance < AnchorSpacing.portRadius + 14;
  }

  bool _hitBody(CanvasNode n, Offset world) {
    return world.dx >= n.x &&
        world.dx <= n.x + AnchorSpacing.nodeWidth &&
        world.dy >= n.y &&
        world.dy <= n.y + AnchorSpacing.nodeHeight;
  }

  _PortHit? _findPort(Offset world, List<CanvasNode> nodes, {bool inputsOnly = false, bool outputsOnly = false}) {
    for (final n in nodes.reversed) {
      if (!inputsOnly && _hitOutput(n, world)) {
        return _PortHit(n.iid, PortSide.output);
      }
      if (!outputsOnly && _hitInput(n, world)) {
        return _PortHit(n.iid, PortSide.input);
      }
    }
    return null;
  }

  void _clearHover() {
    if (_hoveredWireId != null ||
        _hoveredPort != null ||
        _hoveredNodeId != null) {
      setState(() {
        _hoveredWireId = null;
        _hoveredPort = null;
        _hoveredNodeId = null;
      });
    }
  }

  void _updateHover(Offset screen, WorkflowUiState s) {
    if (_mode != _DragMode.none) return;
    final world = _screenToWorld(screen, s);
    final port = _findPort(world, s.doc.nodes);
    String? nodeId;
    if (port == null) {
      for (final n in s.doc.nodes.reversed) {
        if (_hitBody(n, world)) {
          nodeId = n.iid;
          break;
        }
      }
    }
    final wireId =
        port == null && nodeId == null ? _lastPainter?.hitTestWire(world) : null;
    if (port?.nodeId != _hoveredPort?.nodeId ||
        port?.side != _hoveredPort?.side ||
        wireId != _hoveredWireId ||
        nodeId != _hoveredNodeId) {
      setState(() {
        _hoveredPort = port;
        _hoveredWireId = wireId;
        _hoveredNodeId = nodeId;
      });
    }
  }

  void _startAutoPan() {
    _autoPanTicker?.dispose();
    _lastAutoPan = Duration.zero;
    _autoPanTicker = createTicker(_onAutoPanTick)..start();
  }

  void _stopAutoPan() {
    _autoPanTicker?.dispose();
    _autoPanTicker = null;
    _lastAutoPan = Duration.zero;
  }

  /// Strength 0..1 based on how deep the pointer is into the edge margin.
  double _edgeStrength(double pos, double max, {required bool nearStart}) {
    if (nearStart) {
      if (pos >= _edgeMargin) return 0;
      return (1 - pos / _edgeMargin).clamp(0.0, 1.0);
    }
    final dist = max - pos;
    if (dist >= _edgeMargin) return 0;
    return (1 - dist / _edgeMargin).clamp(0.0, 1.0);
  }

  void _onAutoPanTick(Duration elapsed) {
    if (_mode != _DragMode.node && _mode != _DragMode.wire) {
      _stopAutoPan();
      return;
    }
    final dt = _lastAutoPan == Duration.zero
        ? 0.0
        : (elapsed - _lastAutoPan).inMicroseconds / 1e6;
    _lastAutoPan = elapsed;
    if (dt <= 0 || dt > 0.1) return;

    final s = ref.read(workflowProvider);
    final size = _viewportSize;
    if (size == Size.zero) return;

    final left = _edgeStrength(_pointerScreen.dx, size.width, nearStart: true);
    final right = _edgeStrength(_pointerScreen.dx, size.width, nearStart: false);
    final top = _edgeStrength(_pointerScreen.dy, size.height, nearStart: true);
    final bottom =
        _edgeStrength(_pointerScreen.dy, size.height, nearStart: false);

    if (left == 0 && right == 0 && top == 0 && bottom == 0) return;

    final dx = (right - left) * _autoPanSpeed * dt;
    final dy = (bottom - top) * _autoPanSpeed * dt;
    final ctrl = ref.read(workflowProvider.notifier);
    ctrl.setPanZoom(panX: s.panX - dx, panY: s.panY - dy);

    // Keep dragged node under the pointer after pan.
    if (_mode == _DragMode.node && _dragNodeId != null) {
      final next = ref.read(workflowProvider);
      final world = _screenToWorld(_pointerScreen, next);
      ctrl.moveNode(
        _dragNodeId!,
        world.dx - _grabOffset.dx,
        world.dy - _grabOffset.dy,
      );
    } else if (_mode == _DragMode.wire) {
      final next = ref.read(workflowProvider);
      final world = _screenToWorld(_pointerScreen, next);
      _updateWireDrag(world, next);
    }
  }

  void _updateWireDrag(Offset world, WorkflowUiState s) {
    final ctrl = ref.read(workflowProvider.notifier);
    ctrl.updateDrawingWire(world.dx, world.dy);
    String? snap;
    for (final n in s.doc.nodes) {
      if (s.drawingWire != null && n.iid == s.drawingWire!.fromId) continue;
      if (_hitInput(n, world)) {
        snap = n.iid;
        break;
      }
    }
    if (snap != _snapTargetId) {
      setState(() => _snapTargetId = snap);
    }
  }

  void _onPointerDown(PointerDownEvent e, WorkflowUiState s) {
    if (e.buttons != kPrimaryButton) return;
    _focus.requestFocus();
    _pointerScreen = e.localPosition;
    final ctrl = ref.read(workflowProvider.notifier);
    final world = _screenToWorld(e.localPosition, s);
    final nodes = [...s.doc.nodes].reversed;

    for (final n in nodes) {
      if (_hitOutput(n, world)) {
        _mode = _DragMode.wire;
        _clearHover();
        setState(() {
          _snapTargetId = null;
          _hoveredPort = _PortHit(n.iid, PortSide.output);
        });
        ctrl.startDrawingWire(
          n.iid,
          n.x + AnchorSpacing.nodeWidth,
          n.y + AnchorSpacing.nodeHeight / 2,
        );
        _startAutoPan();
        return;
      }
    }

    for (final n in nodes) {
      if (_hitBody(n, world)) {
        _mode = _DragMode.node;
        _dragNodeId = n.iid;
        _startScreen = e.localPosition;
        _grabOffset = Offset(world.dx - n.x, world.dy - n.y);
        _clearHover();
        final additive = HardwareKeyboard.instance.isShiftPressed;
        ctrl.select(n.iid, additive: additive);
        _startAutoPan();
        return;
      }
    }

    final wireId = _lastPainter?.hitTestWire(world);
    if (wireId != null) {
      ctrl.deleteWire(wireId);
      _clearHover();
      return;
    }

    _mode = _DragMode.pan;
    _startScreen = e.localPosition;
    _startPanX = s.panX;
    _startPanY = s.panY;
    _clearHover();
    ctrl.select(null);
  }

  void _onPointerMove(PointerMoveEvent e, WorkflowUiState s) {
    _pointerScreen = e.localPosition;
    final ctrl = ref.read(workflowProvider.notifier);
    final world = _screenToWorld(e.localPosition, s);

    if (_mode == _DragMode.pan) {
      final dx = e.localPosition.dx - _startScreen.dx;
      final dy = e.localPosition.dy - _startScreen.dy;
      ctrl.setPanZoom(panX: _startPanX + dx, panY: _startPanY + dy);
    } else if (_mode == _DragMode.node && _dragNodeId != null) {
      ctrl.moveNode(
        _dragNodeId!,
        world.dx - _grabOffset.dx,
        world.dy - _grabOffset.dy,
      );
    } else if (_mode == _DragMode.wire) {
      _updateWireDrag(world, s);
    }
  }

  void _onPointerHover(PointerHoverEvent e, WorkflowUiState s) {
    _pointerScreen = e.localPosition;
    _updateHover(e.localPosition, s);
  }

  void _onPointerUp(PointerUpEvent e, WorkflowUiState s) {
    final ctrl = ref.read(workflowProvider.notifier);
    if (_mode == _DragMode.node) {
      ctrl.finalizeMove();
    }
    if (_mode == _DragMode.wire) {
      final world = _screenToWorld(e.localPosition, s);
      String? toId = _snapTargetId;
      if (toId == null) {
        for (final n in s.doc.nodes) {
          if (_hitInput(n, world)) {
            toId = n.iid;
            break;
          }
        }
      }
      ctrl.finishDrawingWire(toId);
    }
    _stopAutoPan();
    _mode = _DragMode.none;
    _dragNodeId = null;
    setState(() {
      _snapTargetId = null;
      _hoveredPort = null;
    });
    _updateHover(e.localPosition, ref.read(workflowProvider));
  }

  void _onScroll(PointerSignalEvent e, WorkflowUiState s) {
    if (e is! PointerScrollEvent) return;
    final ctrl = ref.read(workflowProvider.notifier);
    final factor = e.scrollDelta.dy < 0 ? 1.1 : 0.9;
    final oz = s.zoom;
    final nz = (oz * factor).clamp(0.15, 2.5);
    final sx = e.localPosition.dx;
    final sy = e.localPosition.dy;
    ctrl.setPanZoom(
      panX: sx - (sx - s.panX) * (nz / oz),
      panY: sy - (sy - s.panY) * (nz / oz),
      zoom: nz,
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final primary = FocusManager.instance.primaryFocus?.context?.widget;
    if (primary is EditableText) return KeyEventResult.ignored;
    final ctrl = ref.read(workflowProvider.notifier);
    final key = event.logicalKey;
    final meta = HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed;

    if (key == LogicalKeyboardKey.keyG) {
      ctrl.toggleSnapToGrid();
      return KeyEventResult.handled;
    }
    if (meta && key == LogicalKeyboardKey.keyZ) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        ctrl.redo();
      } else {
        ctrl.undo();
      }
      return KeyEventResult.handled;
    }
    if (meta && key == LogicalKeyboardKey.keyY) {
      ctrl.redo();
      return KeyEventResult.handled;
    }
    if (meta && key == LogicalKeyboardKey.keyC) {
      ctrl.copySelected();
      return KeyEventResult.handled;
    }
    if (meta && key == LogicalKeyboardKey.keyV) {
      ctrl.pasteClipboard();
      return KeyEventResult.handled;
    }
    if (meta && key == LogicalKeyboardKey.keyS) {
      ctrl.requestSave();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      ctrl.nudgeSelected(-1, 0);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      ctrl.nudgeSelected(1, 0);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      ctrl.nudgeSelected(0, -1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      ctrl.nudgeSelected(0, 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      if (_hoveredWireId != null && _mode == _DragMode.none) {
        ctrl.deleteWire(_hoveredWireId!);
        _clearHover();
        return KeyEventResult.handled;
      }
      ctrl.deleteSelected();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      if (_mode == _DragMode.wire) {
        ctrl.finishDrawingWire(null);
        _stopAutoPan();
        _mode = _DragMode.none;
        setState(() => _snapTargetId = null);
        return KeyEventResult.handled;
      }
      ctrl.select(null);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  MouseCursor _cursor() {
    if (_mode == _DragMode.pan) return SystemMouseCursors.grabbing;
    if (_mode == _DragMode.node) return SystemMouseCursors.grabbing;
    if (_mode == _DragMode.wire) {
      return _snapTargetId != null
          ? SystemMouseCursors.copy
          : SystemMouseCursors.precise;
    }
    if (_hoveredPort != null) return SystemMouseCursors.precise;
    if (_hoveredWireId != null) return SystemMouseCursors.click;
    if (_hoveredNodeId != null) return SystemMouseCursors.grab;
    return SystemMouseCursors.basic;
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(workflowProvider);
    final drawingValid = _snapTargetId != null;
    final painter = WirePainter(
      nodes: s.doc.nodes,
      wires: s.doc.wires,
      drawingWire: s.drawingWire,
      dashPhase: _dashCtrl.value * 24,
      hoveredWireId: _hoveredWireId,
      snapTargetId: _snapTargetId,
      drawingValid: drawingValid,
      zoom: s.zoom,
    );
    _lastPainter = painter;
    final wireSourceId = s.drawingWire?.fromId;

    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        return Semantics(
          label: 'Workflow canvas. Scroll to zoom, drag to pan.',
          child: Focus(
            focusNode: _focus,
            onKeyEvent: _onKey,
            child: MouseRegion(
              cursor: _cursor(),
              onExit: (_) => _clearHover(),
              child: Listener(
                onPointerDown: (e) => _onPointerDown(e, s),
                onPointerMove: (e) => _onPointerMove(e, s),
                onPointerUp: (e) => _onPointerUp(e, s),
                onPointerHover: (e) => _onPointerHover(e, s),
                onPointerSignal: (e) => _onScroll(e, s),
                child: DragTarget<NodeDef>(
                  onWillAcceptWithDetails: (_) => !s.embedConfig.readOnly,
                  onAcceptWithDetails: (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final local = box.globalToLocal(details.offset);
                    final world = _screenToWorld(
                      Offset(
                        local.dx + AnchorSpacing.nodeWidth / 2,
                        local.dy + AnchorSpacing.nodeHeight / 2,
                      ),
                      s,
                    );
                    ref.read(workflowProvider.notifier).addNodeFromDef(
                          details.data,
                          world.dx,
                          world.dy,
                        );
                  },
                  builder: (context, candidate, rejected) {
                    return AnimatedBuilder(
                      animation: _dashCtrl,
                      builder: (context, _) {
                        return ClipRect(
                          child: Container(
                            color: Colors.transparent,
                            child: Stack(
                              children: [
                                CustomPaint(
                                  painter: _DotGridPainter(
                                    panX: s.panX,
                                    panY: s.panY,
                                    zoom: s.zoom,
                                    emphasize: s.snapToGrid,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                                Transform(
                                  transform: Matrix4.identity()
                                    ..translateByDouble(s.panX, s.panY, 0, 1)
                                    ..scaleByDouble(s.zoom, s.zoom, 1, 1),
                                  alignment: Alignment.topLeft,
                                  child: SizedBox(
                                    width: AnchorSpacing.worldSize,
                                    height: AnchorSpacing.worldSize,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        CustomPaint(
                                          size: const Size(
                                            AnchorSpacing.worldSize,
                                            AnchorSpacing.worldSize,
                                          ),
                                          painter: WirePainter(
                                            nodes: s.doc.nodes,
                                            wires: s.doc.wires,
                                            drawingWire: s.drawingWire,
                                            dashPhase: _dashCtrl.value * 24,
                                            hoveredWireId: _hoveredWireId,
                                            snapTargetId: _snapTargetId,
                                            drawingValid: drawingValid,
                                            zoom: s.zoom,
                                          ),
                                        ),
                                        ...s.doc.nodes.map((n) {
                                          PortSide? portHover;
                                          if (_hoveredPort?.nodeId == n.iid) {
                                            portHover = _hoveredPort!.side;
                                          }
                                          final hasError = s.validation
                                              .any((v) => v.nodeId == n.iid);
                                          return Positioned(
                                            left: n.x,
                                            top: n.y,
                                            child: IgnorePointer(
                                              child: WorkflowNodeCard(
                                                node: n,
                                                selected: n.iid == s.selectedId ||
                                                    s.selectedIds.contains(n.iid),
                                                hovered: _hoveredNodeId == n.iid,
                                                hoveredPort: portHover,
                                                snapTarget:
                                                    _snapTargetId == n.iid,
                                                wireSource:
                                                    wireSourceId == n.iid,
                                                hasError: hasError,
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_hoveredWireId != null &&
                                    _mode == _DragMode.none)
                                  Positioned(
                                    top: 12,
                                    left: 0,
                                    right: 0,
                                    child: IgnorePointer(
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AnchorColors.slate900
                                                .withValues(alpha: 0.85),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Click link to remove',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 16,
                                  left: 0,
                                  right: 0,
                                  child: IgnorePointer(
                                    child: Text(
                                      'Scroll to zoom · drag canvas to pan · Del to remove',
                                      textAlign: TextAlign.center,
                                      style: AnchorTypography.monoSmall.copyWith(
                                        color: AnchorColors.slate400,
                                      ),
                                    ),
                                  ),
                                ),
                                if (s.doc.nodes.isEmpty)
                                  const Center(
                                    child: Text(
                                      'No nodes yet — drag from the palette',
                                      style: TextStyle(
                                        color: AnchorColors.slate500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({
    required this.panX,
    required this.panY,
    required this.zoom,
    this.emphasize = false,
  });

  final double panX;
  final double panY;
  final double zoom;
  final bool emphasize;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 28.0;
    final paint = Paint()
      ..color = emphasize ? AnchorColors.slate300 : AnchorColors.slate200;
    final ox = panX % (step * zoom);
    final oy = panY % (step * zoom);
    final spacing = step * zoom;
    final r = emphasize ? 1.5 : 1.2;
    for (var x = ox; x < size.width; x += spacing) {
      for (var y = oy; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) {
    return oldDelegate.panX != panX ||
        oldDelegate.panY != panY ||
        oldDelegate.zoom != zoom ||
        oldDelegate.emphasize != emphasize;
  }
}
