import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/heid_prototypes.dart';
import 'package:autoflow/features/builder/canvas/node_card.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/canvas_harness.dart';

/// **A look-book for the node card, photographed on the real canvas.**
///
/// The shipped card is a saturated kind-coloured header over a white body,
/// and it was designed when the wires were flat slate — the header was the
/// only colour on the canvas. Now that every placed line carries a beam in
/// its source node's own colour, five solid header bars and five coloured
/// beams are two things saying the same thing at the same volume, and the
/// beam is the one carrying information the graph could not previously show.
///
/// So each candidate below spends *less* colour on the card, differently:
///
/// - **rail** — colour reduced to a 4px spine down the left edge, the icon in
///   a 10% tint. The card is white; the kind is a margin note.
/// - **tint** — the header stays, at 10% with kind-coloured text. Same
///   silhouette as today, a quarter of the ink.
/// - **badge** — no header band at all: title row, with the kind as a small
///   pill. The flattest of the three.
///
/// Nothing here is wired into the app. These live in the harness on purpose —
/// a look nobody picked has no business in `lib/`, and whichever one sticks
/// gets written into `AutoflowNodeWidget` and the rest deleted.
void main() {
  setUpAll(loadTestFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final look in NodeLook.values) {
    testWidgets('nodes — ${look.name}', (tester) async {
      final harness = CanvasHarness();
      await harness.mount(
        tester,
        nodeBuilder: (node, heid) => _LookNode(
          node: node,
          controller: heid,
          session: harness.session,
          look: look,
          showPortContextMenu: (_, _, _, _) {},
          showNodeCreationMenu: (_, _, _, _, _) {},
          showNodeContextMenu: (_, _, _, _) {},
        ),
      );
      // Mid-pass: the shot has to show the card against a lit wire, since
      // that is the whole question these candidates are answering.
      await harness.pumpToPhase(tester, 0.45);
      await harness.shoot(tester, 'nodes-${look.name}');
      await harness.teardown(tester);
    });
  }

  testWidgets('nodes — shipped, for comparison', (tester) async {
    final harness = CanvasHarness();
    await harness.mount(tester);
    await harness.pumpToPhase(tester, 0.45);
    await harness.shoot(tester, 'nodes-current');
    await harness.teardown(tester);
  });
}

enum NodeLook { rail, tint, badge }

class _LookNode extends FlBaseNodeWidget {
  const _LookNode({
    required super.controller,
    required super.node,
    required super.showPortContextMenu,
    required super.showNodeCreationMenu,
    required super.showNodeContextMenu,
    required this.session,
    required this.look,
  });

  final PreviewSession session;
  final NodeLook look;

  @override
  State<_LookNode> createState() => _LookNodeState();
}

class _LookNodeState extends FlBaseNodeWidgetState<_LookNode> {
  @override
  Widget build(BuildContext context) {
    final kind = widget.session.kindOf(widget.node.prototype.idName);
    final color = kind.color;
    final title = widget.node.prototype.displayName(context);

    return wrapWithControls(
      IntrinsicHeight(
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AnchorSpacing.nodeWidth,
            ),
            child: Stack(
              key: widget.node.key,
              clipBehavior: Clip.none,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AnchorColors.white,
                    borderRadius: BorderRadius.circular(AnchorSpacing.radiusLg),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: AnchorShadows.sm,
                  ),
                  child: const SizedBox.expand(),
                ),
                // Clipped: the rail candidate's spine runs the card's full
                // height with square ends, so without this it pokes out
                // through both left-hand corners.
                ClipRRect(
                  borderRadius: BorderRadius.circular(AnchorSpacing.radiusLg),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.look == NodeLook.rail)
                        Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(AnchorSpacing.radiusLg),
                            ),
                          ),
                        ),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [_header(kind, color, title), _ports()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(NodeKind kind, Color color, String title) {
    final bool tinted = widget.look == NodeLook.tint;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: tinted ? color.withValues(alpha: 0.10) : null,
        borderRadius: tinted
            ? const BorderRadius.vertical(
                top: Radius.circular(AnchorSpacing.radiusLg),
              )
            : null,
        border: tinted
            ? Border(bottom: BorderSide(color: color.withValues(alpha: 0.22)))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withValues(alpha: tinted ? 0.16 : 0.10),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(kindIcon(kind), size: 15, color: color),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: tinted ? color : AnchorColors.foreground,
              ),
            ),
          ),
          if (widget.look == NodeLook.badge) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                kind.label,
                style: TextStyle(
                  fontSize: 9,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ports() {
    return Offstage(
      offstage: widget.node.state.isCollapsed,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final port in ports.where(_isInput))
                    _PortLabel(node: widget.node, port: port, input: true),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final port in ports.where(_isOutput))
                    _PortLabel(node: widget.node, port: port, input: false),
                ],
              ),
            ),
          ],
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

  /// Copied from `AutoflowNodeWidget`: the engine paints each port dot at the
  /// offset the node reports, so a candidate that skips this draws its wires
  /// into the top-left corner.
  @override
  void updatePortsPosition() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final nodeBox =
        widget.node.key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || nodeBox == null) return;

    final Size renderBoxSize = renderBox.size;
    final Offset nodeOffset = nodeBox.localToGlobal(Offset.zero);
    final bool isCollapsed = widget.node.state.isCollapsed;
    final num collapsedYAdjustment = isCollapsed
        ? -renderBoxSize.height + 8
        : 0;

    for (final FlPortDataModel port in widget.node.ports.values) {
      final portBox = port.key.currentContext?.findRenderObject() as RenderBox?;
      if (portBox == null) continue;
      final Offset portOffset = portBox.localToGlobal(Offset.zero);
      final double relativeY =
          portOffset.dy - nodeOffset.dy + collapsedYAdjustment;
      port.offset = Offset(
        _isInput(port) ? 0 : renderBoxSize.width,
        relativeY + portBox.size.height / 2,
      );
    }
  }
}

class _PortLabel extends StatelessWidget {
  const _PortLabel({
    required this.node,
    required this.port,
    required this.input,
  });

  final FlNodeDataModel node;
  final FlPortDataModel port;
  final bool input;

  @override
  Widget build(BuildContext context) {
    if (node.state.isCollapsed) {
      return SizedBox(key: port.key, height: 0, width: 0);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        key: port.key,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: input
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              port.prototype.displayName(context),
              overflow: TextOverflow.ellipsis,
              textAlign: input ? TextAlign.left : TextAlign.right,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}
