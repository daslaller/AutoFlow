import 'package:flutter/material.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/port_geometry.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';
import 'package:autoflow/theme/anchor_typography.dart';

IconData kindIcon(NodeKind kind) => switch (kind) {
      NodeKind.trigger => Icons.bolt_rounded,
      NodeKind.action => Icons.play_arrow_rounded,
      NodeKind.condition => Icons.call_split_rounded,
      NodeKind.transform => Icons.shuffle_rounded,
      NodeKind.output => Icons.logout_rounded,
    };

enum PortSide { input, output }

class WorkflowNodeCard extends StatelessWidget {
  const WorkflowNodeCard({
    super.key,
    required this.node,
    required this.selected,
    this.type,
    this.hovered = false,
    this.hoveredPort,
    this.hoveredPortId,
    this.snapTarget = false,
    this.wireSource = false,
    this.hasError = false,
  });

  final CanvasNode node;
  final NodeTypeDef? type;
  final bool selected;
  final bool hovered;
  final PortSide? hoveredPort;
  final String? hoveredPortId;
  final bool snapTarget;
  final bool wireSource;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final c = node.def.kind.color;
    final sc = node.status.color;
    final pulse = node.status == RunStatus.running;
    final emphasize = selected || wireSource;
    final lift = emphasize || hovered;
    final size = PortGeometry.nodeSize(type);
    final inputs = PortGeometry.inputsOf(type);
    final outputs = PortGeometry.outputsOf(type);

    return AnimatedScale(
      scale: hovered && !selected ? 1.015 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: AnchorColors.white,
          borderRadius: BorderRadius.circular(AnchorSpacing.radiusLg),
          boxShadow: lift ? AnchorShadows.lg : AnchorShadows.md,
          border: Border.all(
            color: wireSource
                ? AnchorColors.primary.withValues(alpha: 0.75)
                : selected
                    ? c.withValues(alpha: 0.65)
                    : hasError
                        ? AnchorColors.destructive.withValues(alpha: 0.75)
                        : hovered
                            ? AnchorColors.slate300
                            : AnchorColors.slate200,
            width: emphasize || hasError ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 10,
              bottom: 10,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(3),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 14, 0),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(kindIcon(node.def.kind), size: 16, color: c),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.def.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AnchorColors.foreground,
                            letterSpacing: -0.15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          node.def.sublabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: AnchorColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasError)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: AnchorColors.destructive,
                      ),
                    ),
                  AnimatedOpacity(
                    opacity: pulse ? 0.45 : 1,
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: sc,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (final p in inputs)
              Positioned(
                left: -AnchorSpacing.portRadius,
                top: PortGeometry.slotY(inputs, p.id, size.height) -
                    AnchorSpacing.portRadius,
                child: _Port(
                  color: snapTarget ? AnchorColors.success : AnchorColors.slate400,
                  filled: false,
                  label: inputs.length > 1 ? p.label : null,
                  alignEnd: false,
                  emphasized: (hoveredPort == PortSide.input &&
                          hoveredPortId == p.id) ||
                      snapTarget,
                  connectable: snapTarget,
                ),
              ),
            for (final p in outputs)
              Positioned(
                right: -AnchorSpacing.portRadius,
                top: PortGeometry.slotY(outputs, p.id, size.height) -
                    AnchorSpacing.portRadius,
                child: _Port(
                  color: c,
                  filled: true,
                  label: outputs.length > 1 ? p.label : null,
                  alignEnd: true,
                  emphasized: (hoveredPort == PortSide.output &&
                          hoveredPortId == p.id) ||
                      wireSource,
                  connectable: wireSource,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Port extends StatelessWidget {
  const _Port({
    required this.color,
    required this.filled,
    this.label,
    this.alignEnd = false,
    this.emphasized = false,
    this.connectable = false,
  });

  final Color color;
  final bool filled;
  final String? label;
  final bool alignEnd;
  final bool emphasized;
  final bool connectable;

  @override
  Widget build(BuildContext context) {
    final base = AnchorSpacing.portRadius * 2;
    final size = emphasized ? base + 5 : base;
    final ring = emphasized ? size + 8 : size;

    final port = SizedBox(
      width: base,
      height: base,
      child: OverflowBox(
        minWidth: ring,
        maxWidth: ring,
        minHeight: ring,
        maxHeight: ring,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          width: ring,
          height: ring,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: emphasized
                ? color.withValues(alpha: connectable ? 0.2 : 0.12)
                : Colors.transparent,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: filled ? color : AnchorColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: emphasized ? 2.5 : 2,
              ),
              boxShadow: emphasized
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : AnchorShadows.sm,
            ),
          ),
        ),
      ),
    );

    if (label == null) return port;

    final chip = Container(
      margin: EdgeInsets.only(left: alignEnd ? 0 : 16, right: alignEnd ? 16 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AnchorColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AnchorColors.slate200),
      ),
      child: Text(
        label!,
        style: AnchorTypography.monoSmall.copyWith(
          fontSize: 9,
          color: color,
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: alignEnd ? [chip, port] : [port, chip],
    );
  }
}

class PaletteGhost extends StatelessWidget {
  const PaletteGhost({super.key, required this.def});

  final NodeDef def;

  @override
  Widget build(BuildContext context) {
    final c = def.kind.color;
    return Opacity(
      opacity: 0.92,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusLg),
        child: Container(
          width: AnchorSpacing.nodeWidth,
          height: AnchorSpacing.nodeHeight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AnchorColors.white,
            borderRadius: BorderRadius.circular(AnchorSpacing.radiusLg),
            border: Border.all(color: c.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(kindIcon(def.kind), size: 16, color: c),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      def.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AnchorColors.foreground,
                      ),
                    ),
                    Text(
                      def.sublabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: AnchorColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
