import 'package:flutter/material.dart';
import 'package:autoflow/design_system/badge.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';
import 'package:autoflow/theme/anchor_typography.dart';

IconData kindIcon(NodeKind kind) => switch (kind) {
      NodeKind.trigger => Icons.bolt_rounded,
      NodeKind.action => Icons.arrow_forward_rounded,
      NodeKind.condition => Icons.account_tree_outlined,
      NodeKind.transform => Icons.shuffle_rounded,
      NodeKind.output => Icons.output_rounded,
    };

enum PortSide { input, output }

class WorkflowNodeCard extends StatelessWidget {
  const WorkflowNodeCard({
    super.key,
    required this.node,
    required this.selected,
    this.hovered = false,
    this.hoveredPort,
    this.snapTarget = false,
    this.wireSource = false,
    this.hasError = false,
  });

  final CanvasNode node;
  final bool selected;
  final bool hovered;
  final PortSide? hoveredPort;
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

    return AnimatedScale(
      scale: hovered && !selected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        width: AnchorSpacing.nodeWidth,
        height: AnchorSpacing.nodeHeight,
        decoration: BoxDecoration(
          color: AnchorColors.white,
          borderRadius: BorderRadius.circular(AnchorSpacing.radiusLg),
          boxShadow: lift ? AnchorShadows.lg : AnchorShadows.md,
          border: Border.all(
            color: wireSource
                ? AnchorColors.primary.withValues(alpha: 0.7)
                : selected
                    ? c.withValues(alpha: 0.55)
                    : hasError
                        ? AnchorColors.destructive.withValues(alpha: 0.7)
                        : hovered
                            ? AnchorColors.slate300
                            : AnchorColors.slate200.withValues(alpha: 0.0),
            width: emphasize || hasError ? 2 : (hovered ? 1.5 : 1),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(kindIcon(node.def.kind), size: 14, color: c),
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
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AnchorColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnchorBadge(
                          label: node.def.kind.label,
                          backgroundColor: c.withValues(alpha: 0.12),
                          foregroundColor: c,
                        ),
                      ],
                    ),
                  ),
                  if (hasError)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
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
            Positioned(
              left: -AnchorSpacing.portRadius,
              top: AnchorSpacing.nodeHeight / 2 - AnchorSpacing.portRadius,
              child: _Port(
                color: snapTarget ? AnchorColors.success : AnchorColors.slate400,
                filled: false,
                emphasized: hoveredPort == PortSide.input || snapTarget,
                connectable: snapTarget,
              ),
            ),
            Positioned(
              right: -AnchorSpacing.portRadius,
              top: AnchorSpacing.nodeHeight / 2 - AnchorSpacing.portRadius,
              child: _Port(
                color: c,
                filled: true,
                emphasized: hoveredPort == PortSide.output || wireSource,
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
    this.emphasized = false,
    this.connectable = false,
  });

  final Color color;
  final bool filled;
  final bool emphasized;
  final bool connectable;

  @override
  Widget build(BuildContext context) {
    final base = AnchorSpacing.portRadius * 2;
    final size = emphasized ? base + 6 : base;
    final ring = emphasized ? size + 10 : size;

    return SizedBox(
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
                        color: color.withValues(alpha: 0.45),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : AnchorShadows.sm,
            ),
          ),
        ),
      ),
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
      opacity: 0.9,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusLg),
        child: Container(
          width: AnchorSpacing.nodeWidth,
          height: AnchorSpacing.nodeHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AnchorColors.white,
            borderRadius: BorderRadius.circular(AnchorSpacing.radiusLg),
            border: Border.all(color: c.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(kindIcon(def.kind), size: 14, color: c),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    def.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(def.kind.label, style: AnchorTypography.monoSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
