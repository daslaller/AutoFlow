import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  void _onSession() {
    if (mounted) setState(() {});
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: decoration.copyWith(
                    color: AnchorColors.white,
                    border: borderColor == null
                        ? null
                        : Border.all(color: borderColor, width: 2),
                  ),
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
          Icon(kindIcon(kind), size: 16, color: Colors.white),
          const SizedBox(width: 8),
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
