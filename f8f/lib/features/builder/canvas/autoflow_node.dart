import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/heid_prototypes.dart';
import 'package:autoflow/features/builder/canvas/node_card.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';
import 'package:autoflow/theme/anchor_typography.dart';

/// HeidNodes node chrome for AutoFlow: header + named ports, no in-card
/// field editors (config lives in the inspector).
class AutoflowNodeWidget extends FlBaseNodeWidget {
  const AutoflowNodeWidget({
    super.key,
    required super.controller,
    required super.node,
    required super.showPortContextMenu,
    required super.showNodeCreationMenu,
    required super.showNodeContextMenu,
    required this.session,
  });

  final PreviewSession session;

  @override
  State<AutoflowNodeWidget> createState() => _AutoflowNodeWidgetState();
}

class _AutoflowNodeWidgetState extends FlBaseNodeWidgetState<AutoflowNodeWidget> {
  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSession);
  }

  @override
  void didUpdateWidget(AutoflowNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session != widget.session) {
      oldWidget.session.removeListener(_onSession);
      widget.session.addListener(_onSession);
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSession);
    super.dispose();
  }

  RunStatus? _lastStatus;

  void _onSession() {
    if (!mounted) return;
    setState(() {});

    // Every node listens to the one session, so a single status change wakes
    // all of them; only the node that actually changed can have changed size.
    final status = widget.session.statusOf(widget.node.id);
    if (status == _lastStatus) return;
    _lastStatus = status;

    // ⚠️ **Without this, running a Preview makes the graph disappear.**
    //
    // HeidNodes' node layer lays out only the children in its own
    // `_childrenNotLaidOut` set, which is filled from *its* events — a node
    // added, moved, selected, hovered, collapsed. A node widget that rebuilds
    // on its own says nothing to that set, so the child is skipped in layout,
    // and `RenderObject._paintWithContext` then silently returns early while
    // `_needsLayout` is true. The node stops painting entirely and all that is
    // left of it is the cached drop shadow the layer draws from the node's
    // last known rect — a grey blur where the card was.
    //
    // A run status is exactly that kind of self-rebuild: five nodes went to
    // ghosts the first time this canvas was photographed mid-Preview. This
    // hands the layer the one per-node signal it does listen to. It carries
    // no hover state — the render object sets `state.isHovered` itself before
    // emitting, and we deliberately do not — so all it means here is "this
    // node's chrome changed, measure it again".
    //
    // The real fix is upstream: the layer should lay out any child that is
    // dirty, not only the ones it was told about.
    widget.controller.eventBus.emit(
      FlNodeHoverEvent(
        widget.node.id,
        type: FlHoverEventType.exit,
        id: const Uuid().v4(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.session.statusOf(widget.node.id);
    final decoration = widget.node.builtStyle.decoration;
    final borderColor = switch (status) {
      RunStatus.running => AnchorColors.statusRunning,
      RunStatus.error => AnchorColors.statusError,
      RunStatus.success => AnchorColors.statusSuccess.withValues(alpha: 0.65),
      RunStatus.idle => null,
    };

    return wrapWithControls(
      IntrinsicHeight(
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: AnchorSpacing.nodeWidth),
            child: Stack(
              key: widget.node.key,
              clipBehavior: Clip.none,
              children: [
                // ⚠️ **Not an `AnimatedContainer`, and that is a fix.**
                //
                // A run status used to cross-fade in over 160ms. A border is
                // part of a `BoxDecoration`'s padding, so every tick of that
                // fade re-laid the card out — and HeidNodes' node layer only
                // lays out children it was *told* about (see `_onSession`
                // below), so the node was skipped in layout and then silently
                // skipped in paint for the whole animation. Three of six nodes
                // photographed as grey blurs a frame after their status
                // landed. Anything animating layout inside a node does this;
                // the ring is now simply on or off.
                DecoratedBox(
                  decoration: decoration.copyWith(
                    color: AnchorColors.white,
                    border: borderColor == null
                        ? null
                        : Border.all(color: borderColor, width: 2),
                  ),
                  child: const SizedBox.expand(),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      node: widget.node,
                      kind: widget.session.kindOf(widget.node.prototype.idName),
                      status: status,
                    ),
                    Offstage(
                      offstage: widget.node.state.isCollapsed,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final port in ports.where(_isInput))
                                    _Port(node: widget.node, port: port),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  for (final port in ports.where(_isOutput))
                                    _Port(node: widget.node, port: port),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isInput(FlPortDataModel port) =>
      port.prototype is FlDataInputPortPrototype ||
      port.prototype is FlControlInputPortPrototype;

  bool _isOutput(FlPortDataModel port) =>
      port.prototype is FlDataOutputPortPrototype ||
      port.prototype is FlControlOutputPortPrototype;

  @override
  void updatePortsPosition() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final nodeBox =
        widget.node.key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || nodeBox == null) return;

    final Size renderBoxSize = renderBox.size;
    final Offset nodeOffset = nodeBox.localToGlobal(Offset.zero);
    final bool isCollapsed = widget.node.state.isCollapsed;
    final num collapsedYAdjustment =
        isCollapsed ? -renderBoxSize.height + 8 : 0;

    for (final FlPortDataModel port in widget.node.ports.values) {
      final portBox = port.key.currentContext?.findRenderObject() as RenderBox?;
      if (portBox == null) continue;
      final Offset portOffset = portBox.localToGlobal(Offset.zero);
      final double relativeY =
          portOffset.dy - nodeOffset.dy + collapsedYAdjustment;
      final bool isInput = _isInput(port);
      port.offset = Offset(
        isInput ? 0 : renderBoxSize.width,
        relativeY + portBox.size.height / 2,
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.node,
    required this.kind,
    required this.status,
  });

  final FlNodeDataModel node;
  final NodeKind kind;
  final RunStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: node.builtHeaderStyle.padding,
      decoration: node.builtHeaderStyle.decoration,
      child: Row(
        children: [
          // The glyph sits in its own tinted chip rather than loose on the
          // wash: at 10% the header is close enough to white that a bare
          // 16px icon reads as a stray mark instead of as the node's kind.
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: kind.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(kindIcon(kind), size: 15, color: kind.color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              node.prototype.displayName(context),
              style: node.builtHeaderStyle.textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (status != RunStatus.idle) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: status.color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Port extends StatelessWidget {
  const _Port({required this.node, required this.port});

  final FlNodeDataModel node;
  final FlPortDataModel port;

  @override
  Widget build(BuildContext context) {
    if (node.state.isCollapsed) {
      return SizedBox(key: port.key, height: 0, width: 0);
    }
    final isInput = port.prototype is FlDataInputPortPrototype ||
        port.prototype is FlControlInputPortPrototype;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            isInput ? MainAxisAlignment.start : MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        key: port.key,
        children: [
          Flexible(
            child: Text(
              port.prototype.displayName(context),
              style: AnchorTypography.textTheme.bodySmall?.copyWith(
                color: AnchorColors.mutedForeground,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: isInput ? TextAlign.left : TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FlNodeDataModel>('node', node))
      ..add(DiagnosticsProperty<FlPortDataModel>('port', port));
  }
}
