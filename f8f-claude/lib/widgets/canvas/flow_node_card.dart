import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flowstock/controller/flow_controller.dart';
import 'package:flowstock/data/node_catalog.dart';
import 'package:flowstock/models/models.dart';
import 'package:flowstock/theme/flowstock_colors.dart';
import 'package:flowstock/widgets/icons/lucide_path_icon.dart';
import 'package:flowstock/widgets/shared_widgets.dart';

typedef GlobalToCanvas = Offset Function(Offset global);

class FlowNodeCard extends StatefulWidget {
  const FlowNodeCard({
    super.key,
    required this.node,
    required this.controller,
    required this.toCanvasLocal,
  });

  final FlowNode node;
  final FlowController controller;
  final GlobalToCanvas toCanvasLocal;

  @override
  State<FlowNodeCard> createState() => _FlowNodeCardState();
}

class _FlowNodeCardState extends State<FlowNodeCard> {
  bool _hover = false;
  int? _activePointer;

  FlowController get c => widget.controller;
  FlowNode get n => widget.node;

  void _onPointerDown(PointerDownEvent e) {
    if (e.buttons != kPrimaryButton) return;
    _activePointer = e.pointer;
    final local = widget.toCanvasLocal(e.position);
    c.startNodeDrag(n.id, c.toWorld(local));
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_activePointer != e.pointer) return;
    if (c.mode != DragMode.node) return;
    c.onPointerMove(
      local: widget.toCanvasLocal(e.position),
      global: e.position,
    );
  }

  void _onPointerUp(PointerEvent e) {
    if (_activePointer != e.pointer) return;
    _activePointer = null;
    if (c.mode == DragMode.connect) {
      c.finishConnect(n.id);
    } else if (c.mode == DragMode.node) {
      c.onPointerUp(
        local: widget.toCanvasLocal(e.position),
        global: e.position,
        overCanvas: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final def = NodeCatalog.typeOf(n.type);
    final cat = NodeCatalog.categoryOf(def.category);
    final selected = c.selectedId == n.id;
    final runStatus = c.run[n.id];
    var summary = '';
    try {
      summary = def.summary(n.config).trim();
    } catch (_) {}
    final outs = NodeCatalog.outSpecs(n.type);
    final hasInput = def.category != NodeCategory.trigger;
    final dragging = c.mode == DragMode.node && c.selectedId == n.id;

    return SizedBox(
      width: NodeCatalog.nodeWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Outline offset selection (no layout shift).
          if (selected)
            Positioned(
              left: -4,
              top: -4,
              right: -4,
              bottom: -4,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: FsColors.blue500, width: 2),
                  ),
                ),
              ),
            ),
          MouseRegion(
            cursor: dragging
                ? SystemMouseCursors.grabbing
                : SystemMouseCursors.grab,
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              onPointerCancel: _onPointerUp,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                decoration: BoxDecoration(
                  color: FsColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _hover || dragging
                      ? FsColors.shadowHover
                      : FsColors.shadowMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                      child: Row(
                        children: [
                          ChipDecor(
                            category: def.category,
                            iconPath: def.iconPath,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  def.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                    color: FsColors.slate900,
                                  ),
                                ),
                                Text(
                                  cat.label + (def.ai ? ' · ⚡' : ''),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: FsColors.slate500,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (summary.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: FsColors.slate50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: FsColors.slate600,
                            fontFamily: 'Consolas',
                            fontFamilyFallback: ['Menlo', 'monospace'],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (runStatus == RunStatus.running)
            const Positioned(
              top: -8,
              right: -8,
              child: _StatusBadge(
                color: FsColors.orange500,
                child: SpinningRing(size: 10),
              ),
            ),
          if (runStatus == RunStatus.done)
            const Positioned(
              top: -8,
              right: -8,
              child: _StatusBadge(
                color: FsColors.green500,
                child: LucidePathIcon(
                  pathData: Ic.check,
                  size: 11,
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          if (hasInput)
            Positioned(
              left: -7,
              top: 35,
              child: _Port(
                onAccept: () => c.finishConnect(n.id),
              ),
            ),
          for (var i = 0; i < outs.length; i++) ...[
            Positioned(
              right: -7,
              top: outs[i].cy - 7,
              child: _Port(
                onDragStart: () => c.startConnect(n.id, i),
                onDragUpdate: (global) {
                  c.onPointerMove(
                    local: widget.toCanvasLocal(global),
                    global: global,
                  );
                },
                onDragEnd: (global) {
                  if (c.mode == DragMode.connect) {
                    c.onPointerUp(
                      local: widget.toCanvasLocal(global),
                      global: global,
                      overCanvas: true,
                    );
                  }
                },
              ),
            ),
            if (outs[i].label != null)
              Positioned(
                left: NodeCatalog.nodeWidth + 11,
                top: outs[i].cy - 6,
                child: IgnorePointer(
                  child: Text(
                    '${i == 0 ? '✓ ' : '✕ '}${outs[i].label}',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: FsColors.slate400,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _Port extends StatefulWidget {
  const _Port({
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onAccept,
  });

  final VoidCallback? onDragStart;
  final ValueChanged<Offset>? onDragUpdate;
  final ValueChanged<Offset>? onDragEnd;
  final VoidCallback? onAccept;

  @override
  State<_Port> createState() => _PortState();
}

class _PortState extends State<_Port> {
  bool _hover = false;
  Offset _lastGlobal = Offset.zero;
  int? _pointer;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: widget.onDragStart == null
            ? null
            : (e) {
                if (e.buttons != kPrimaryButton) return;
                _pointer = e.pointer;
                _lastGlobal = e.position;
                widget.onDragStart!();
              },
        onPointerMove: widget.onDragUpdate == null
            ? null
            : (e) {
                if (_pointer != e.pointer) return;
                _lastGlobal = e.position;
                widget.onDragUpdate!(e.position);
              },
        onPointerUp: (e) {
          if (_pointer != e.pointer) return;
          _pointer = null;
          if (widget.onDragEnd != null) {
            widget.onDragEnd!(_lastGlobal);
          } else if (widget.onAccept != null) {
            widget.onAccept!();
          }
        },
        onPointerCancel: (e) {
          if (_pointer != e.pointer) return;
          _pointer = null;
          widget.onDragEnd?.call(_lastGlobal);
        },
        child: AnimatedScale(
          scale: _hover ? 1.25 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: FsColors.white,
              border: Border.all(
                color: _hover ? FsColors.blue600 : FsColors.slate400,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
