import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flowstock/controller/flow_controller.dart';
import 'package:flowstock/models/models.dart';
import 'package:flowstock/theme/flowstock_colors.dart';
import 'package:flowstock/widgets/canvas/flow_canvas.dart';
import 'package:flowstock/widgets/embed_dialog.dart';
import 'package:flowstock/widgets/inspector_panel.dart';
import 'package:flowstock/widgets/node_palette.dart';
import 'package:flowstock/widgets/top_bar.dart';

class FlowBuilderPage extends StatefulWidget {
  const FlowBuilderPage({
    super.key,
    this.showMinimap = true,
    this.wireStyle = WireStyle.curved,
    this.snapToGrid = false,
    this.onRun,
  });

  final bool showMinimap;
  final WireStyle wireStyle;
  final bool snapToGrid;

  /// Optional host callback when Run Test is pressed (embed API).
  final FutureOr<void> Function(FlowGraph graph)? onRun;

  @override
  State<FlowBuilderPage> createState() => _FlowBuilderPageState();
}

class _FlowBuilderPageState extends State<FlowBuilderPage> {
  late final FlowController _controller;
  final FocusNode _focus = FocusNode();
  final GlobalKey _canvasAreaKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = FlowController(
      showMinimap: widget.showMinimap,
      wireStyle: widget.wireStyle,
      snapToGrid: widget.snapToGrid,
      onRun: widget.onRun,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _controller.closeEmbed();
      _controller.cancelTemp();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      final primary = FocusManager.instance.primaryFocus;
      if (primary?.context != null) {
        final editable =
            primary!.context!.findAncestorWidgetOfExactType<EditableText>();
        if (editable != null) return KeyEventResult.ignored;
      }
      _controller.deleteSelection();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleGlobalPointer(PointerEvent e) {
    final mode = _controller.mode;
    if (mode == DragMode.none || mode == DragMode.pan) return;

    final box =
        _canvasAreaKey.currentContext?.findRenderObject() as RenderBox?;
    var local = Offset.zero;
    var over = false;
    if (box != null) {
      local = box.globalToLocal(e.position);
      over = (Offset.zero & box.size).contains(local);
    }

    if (e is PointerMoveEvent) {
      // Keep node/connect/palette drags alive even if pointer leaves the hit target.
      if (mode == DragMode.palette) {
        _controller.onPointerMove(local: local, global: e.position);
      } else if (mode == DragMode.node || mode == DragMode.connect) {
        // Prefer canvas-local when over canvas; still update when outside for edge pan.
        _controller.onPointerMove(
          local: over ? local : local,
          global: e.position,
        );
      }
    } else if (e is PointerUpEvent || e is PointerCancelEvent) {
      _controller.onPointerUp(
        local: local,
        global: e.position,
        overCanvas: over,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Listener(
        onPointerMove: _handleGlobalPointer,
        onPointerUp: _handleGlobalPointer,
        onPointerCancel: _handleGlobalPointer,
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: FsColors.pageGradient),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Elevated so canvas overflow never paints over the bar.
                    Material(
                      elevation: 2,
                      color: Colors.transparent,
                      child: TopBar(controller: _controller),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Material(
                            elevation: 1,
                            color: Colors.transparent,
                            child: NodePalette(controller: _controller),
                          ),
                          Expanded(
                            child: KeyedSubtree(
                              key: _canvasAreaKey,
                              child: FlowCanvas(controller: _controller),
                            ),
                          ),
                          Material(
                            elevation: 1,
                            color: Colors.transparent,
                            child: InspectorPanel(controller: _controller),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                DragGhost(controller: _controller),
                EmbedDialog(controller: _controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
