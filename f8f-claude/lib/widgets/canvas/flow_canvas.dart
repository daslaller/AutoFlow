import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flowstock/controller/flow_controller.dart';
import 'package:flowstock/data/node_catalog.dart';
import 'package:flowstock/models/models.dart';
import 'package:flowstock/theme/flowstock_colors.dart';
import 'package:flowstock/widgets/canvas/flow_node_card.dart';
import 'package:flowstock/widgets/canvas/wires_layer.dart';
import 'package:flowstock/widgets/icons/lucide_path_icon.dart';

class FlowCanvas extends StatefulWidget {
  const FlowCanvas({super.key, required this.controller});

  final FlowController controller;

  @override
  State<FlowCanvas> createState() => _FlowCanvasState();
}

class _FlowCanvasState extends State<FlowCanvas>
    with TickerProviderStateMixin {
  final GlobalKey _viewportKey = GlobalKey();
  late final AnimationController _dashAnim;

  FlowController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.attachTickerProvider(this);
    _dashAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    c.addListener(_syncDashAnim);
  }

  void _syncDashAnim() {
    final needDash = c.temp != null ||
        c.wrun.values.any((s) => s == RunStatus.running) ||
        c.run.values.any((s) => s == RunStatus.running);
    if (needDash) {
      if (!_dashAnim.isAnimating) _dashAnim.repeat();
    } else {
      if (_dashAnim.isAnimating) {
        _dashAnim.stop();
        _dashAnim.value = 0;
      }
    }
  }

  @override
  void didUpdateWidget(covariant FlowCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncDashAnim);
      c.attachTickerProvider(this);
      c.addListener(_syncDashAnim);
    }
  }

  @override
  void dispose() {
    c.removeListener(_syncDashAnim);
    _dashAnim.dispose();
    super.dispose();
  }

  Offset _toLocal(Offset global) {
    final box = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return global;
    return box.globalToLocal(global);
  }

  void _onBackgroundPointerDown(PointerDownEvent e) {
    if (c.mode != DragMode.none) return;
    if (e.buttons != kPrimaryButton) return;
    final local = _toLocal(e.position);
    final world = c.toWorld(local);
    final hit = WireHitTester.hit(c, world);
    if (hit != null) {
      c.selectWire(hit);
      return;
    }
    c.startPan(local);
  }

  void _onBackgroundPointerMove(PointerMoveEvent e) {
    if (c.mode == DragMode.pan) {
      c.onPointerMove(local: _toLocal(e.position), global: e.position);
    }
  }

  void _onBackgroundPointerUp(PointerEvent e) {
    if (c.mode == DragMode.pan) {
      c.onPointerUp(
        local: _toLocal(e.position),
        global: e.position,
        overCanvas: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([c.graphTick, c.viewportTick]),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            if (size != c.canvasSize && size != Size.zero) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                c.setCanvasSize(size);
                c.ensureFitted();
              });
            }

            return ClipRect(
              child: Listener(
                onPointerSignal: (e) {
                  if (e is PointerScrollEvent) {
                    final local = _toLocal(e.position);
                    c.zoomAt(
                      local.dx,
                      local.dy,
                      math.exp(-e.scrollDelta.dy * 0.0014),
                    );
                  }
                },
                child: MouseRegion(
                  cursor: c.mode == DragMode.node || c.panning
                      ? SystemMouseCursors.grabbing
                      : SystemMouseCursors.basic,
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: _onBackgroundPointerDown,
                    onPointerMove: _onBackgroundPointerMove,
                    onPointerUp: _onBackgroundPointerUp,
                    onPointerCancel: _onBackgroundPointerUp,
                    child: Container(
                      key: _viewportKey,
                      color: Colors.transparent,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _GridPainter(zoom: c.zoom, pan: c.pan),
                            ),
                          ),
                          // Large world box centered so negative coords stay hittable.
                          // Visual = pan + zoom * world, via translate(-origin) + Positioned(n+origin).
                          Transform(
                            transform: Matrix4.identity()
                              ..translateByDouble(c.pan.dx, c.pan.dy, 0, 1)
                              ..scaleByDouble(c.zoom, c.zoom, 1, 1)
                              ..translateByDouble(
                                -_worldOrigin,
                                -_worldOrigin,
                                0,
                                1,
                              ),
                            alignment: Alignment.topLeft,
                            filterQuality: FilterQuality.medium,
                            child: SizedBox(
                              width: _worldExtent,
                              height: _worldExtent,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    width: _worldExtent,
                                    height: _worldExtent,
                                    child: WiresLayer(
                                      controller: c,
                                      dashAnimation: _dashAnim,
                                      origin: _worldOrigin,
                                    ),
                                  ),
                                  for (final n in c.nodes)
                                    Positioned(
                                      left: n.x + _worldOrigin,
                                      top: n.y + _worldOrigin,
                                      child: FlowNodeCard(
                                        key: ValueKey(n.id),
                                        node: n,
                                        controller: c,
                                        toCanvasLocal: _toLocal,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: 10,
                            child: _ChromeBtn(
                              tooltip: c.paletteOpen
                                  ? 'Hide node library'
                                  : 'Show node library',
                              onTap: c.togglePalette,
                              onPointerDown: () =>
                                  c.suppressBackgroundPan = true,
                              onPointerUp: () =>
                                  c.suppressBackgroundPan = false,
                              child: LucidePathIcon(
                                pathData: c.paletteOpen
                                    ? Ic.chevronLeft
                                    : Ic.chevronRight,
                                size: 14,
                                color: FsColors.slate600,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: _ChromeBtn(
                              tooltip: c.inspectorOpen
                                  ? 'Hide inspector'
                                  : 'Show inspector',
                              onTap: c.toggleInspector,
                              onPointerDown: () =>
                                  c.suppressBackgroundPan = true,
                              onPointerUp: () =>
                                  c.suppressBackgroundPan = false,
                              child: LucidePathIcon(
                                pathData: c.inspectorOpen
                                    ? Ic.chevronRight
                                    : Ic.chevronLeft,
                                size: 14,
                                color: FsColors.slate600,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            bottom: 14,
                            child: _ZoomControls(controller: c),
                          ),
                          if (c.showMinimap && c.nodes.isNotEmpty)
                            Positioned(
                              right: 14,
                              bottom: 14,
                              child: _Minimap(controller: c),
                            ),
                          if (c.toast != null)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 18,
                              child: Center(child: _Toast(message: c.toast!)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Large virtual canvas so nodes remain hittable far from origin.
  static const double _worldOrigin = 50000;
  static const double _worldExtent = 100000;
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.zoom, required this.pan});

  final double zoom;
  final Offset pan;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FsColors.slate300.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final step = 24 * zoom;
    if (step < 4) return;
    final ox = pan.dx % step;
    final oy = pan.dy % step;
    for (var x = ox; x < size.width; x += step) {
      for (var y = oy; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.zoom != zoom || oldDelegate.pan != pan;
}

class _ChromeBtn extends StatefulWidget {
  const _ChromeBtn({
    required this.onTap,
    required this.child,
    this.tooltip,
    this.onPointerDown,
    this.onPointerUp,
  });

  final VoidCallback onTap;
  final Widget child;
  final String? tooltip;
  final VoidCallback? onPointerDown;
  final VoidCallback? onPointerUp;

  @override
  State<_ChromeBtn> createState() => _ChromeBtnState();
}

class _ChromeBtnState extends State<_ChromeBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final btn = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => widget.onPointerDown?.call(),
        onPointerUp: (_) => widget.onPointerUp?.call(),
        onPointerCancel: (_) => widget.onPointerUp?.call(),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _hover ? FsColors.slate100 : FsColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: FsColors.shadowMd,
            ),
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
    if (widget.tooltip == null) return btn;
    return Tooltip(message: widget.tooltip!, child: btn);
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.controller});

  final FlowController controller;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => controller.suppressBackgroundPan = true,
      onPointerUp: (_) => controller.suppressBackgroundPan = false,
      onPointerCancel: (_) => controller.suppressBackgroundPan = false,
      child: Container(
        decoration: BoxDecoration(
          color: FsColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: FsColors.shadowMd,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ZoomBtn(
              tooltip: 'Zoom in',
              onTap: controller.zoomIn,
              child: const LucidePathIcon(
                pathData: Ic.plus,
                size: 14,
                color: FsColors.slate600,
              ),
            ),
            Container(height: 1, color: FsColors.slate100),
            _ZoomBtn(
              tooltip: 'Zoom out',
              onTap: controller.zoomOut,
              child: const LucidePathIcon(
                pathData: Ic.minus,
                size: 14,
                color: FsColors.slate600,
              ),
            ),
            Container(height: 1, color: FsColors.slate100),
            _ZoomBtn(
              tooltip: 'Fit to view',
              onTap: controller.fitView,
              child: const LucidePathIcon(
                pathData: Ic.fit,
                size: 13,
                color: FsColors.slate600,
              ),
            ),
            Container(height: 1, color: FsColors.slate100),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 6),
              child: Text(
                '${(controller.zoom * 100).round()}%',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: FsColors.slate400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomBtn extends StatefulWidget {
  const _ZoomBtn({
    required this.onTap,
    required this.child,
    this.tooltip,
  });

  final VoidCallback onTap;
  final Widget child;
  final String? tooltip;

  @override
  State<_ZoomBtn> createState() => _ZoomBtnState();
}

class _ZoomBtnState extends State<_ZoomBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final btn = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 34,
          height: 32,
          color: _hover ? FsColors.slate100 : FsColors.white,
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
    if (widget.tooltip == null) return btn;
    return Tooltip(message: widget.tooltip!, child: btn);
  }
}

class _Minimap extends StatelessWidget {
  const _Minimap({required this.controller});

  final FlowController controller;

  @override
  Widget build(BuildContext context) {
    final layout = controller.minimapLayout();
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => controller.suppressBackgroundPan = true,
      onPointerUp: (_) => controller.suppressBackgroundPan = false,
      onPointerCancel: (_) => controller.suppressBackgroundPan = false,
      child: GestureDetector(
        onTapDown: (d) => controller.minimapJump(d.localPosition),
        onPanUpdate: (d) => controller.minimapJump(d.localPosition),
        child: Container(
          width: 168,
          height: 104,
          decoration: BoxDecoration(
            color: FsColors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(10),
            boxShadow: FsColors.shadowMd,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              for (final m in layout.nodes)
                Positioned(
                  left: m.l,
                  top: m.t,
                  child: Container(
                    width: m.w,
                    height: m.h,
                    decoration: BoxDecoration(
                      color: m.c,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              Positioned(
                left: layout.vp.left,
                top: layout.vp.top,
                child: Container(
                  width: math.max(0, layout.vp.width),
                  height: math.max(0, layout.vp.height),
                  decoration: BoxDecoration(
                    color: FsColors.blue500.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: FsColors.blue500, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: FsColors.white,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: FsColors.shadowLg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: FsColors.green100,
            ),
            alignment: Alignment.center,
            child: const LucidePathIcon(
              pathData: Ic.check,
              size: 10,
              color: FsColors.green700,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: FsColors.slate900,
            ),
          ),
        ],
      ),
    );
  }
}
