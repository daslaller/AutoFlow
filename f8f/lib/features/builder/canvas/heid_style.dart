import 'package:flutter/material.dart';
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

/// Anchor-flavoured HeidNodes styles so the editor canvas matches AutoFlow chrome.
abstract final class HeidStyle {
  static FlNodesStyle editor({bool showGrid = true}) => FlNodesStyle(
        decoration: BoxDecoration(color: AnchorColors.slate50),
        gridStyle: const FlGridStyle.dots().copyWith(
          gridSpacingX: AnchorSpacing.s6,
          gridSpacingY: AnchorSpacing.s6,
          intersectionColor: const Color(0x66CBD5E1),
          showGrid: showGrid,
        ),
        highlightAreaStyle: FlHighlightAreaStyle(
          color: AnchorColors.primary.withValues(alpha: 0.12),
          borderWidth: 1,
          borderColor: AnchorColors.primary.withValues(alpha: 0.7),
          borderDrawMode: FlLineDrawMode.solid,
        ),
        nodesShadow: const BoxShadow(
          color: Color(0x1A000000),
          offset: Offset(0, 4),
          blurRadius: 6,
          spreadRadius: -1,
        ),
      );

  static FlNodeStyle nodeStyle(FlNodeState state) {
    final selected = state.isSelected;
    final hovered = state.isHovered;
    return FlNodeStyle(
      decoration: BoxDecoration(
        color: AnchorColors.white,
        borderRadius: BorderRadius.circular(AnchorSpacing.radiusLg),
        boxShadow: selected
            ? AnchorShadows.lg
            : hovered
                ? AnchorShadows.md
                : AnchorShadows.sm,
      ),
    );
  }

  static FlNodeHeaderStyle headerStyle(NodeKind kind, FlNodeState state) {
    return FlNodeHeaderStyle(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kind.color,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AnchorSpacing.radiusLg),
        ),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      icon: Icons.expand_more,
    );
  }

  static FlPortStyle portStyle(Color color, FlPortState state) {
    return FlPortStyle(
      shape: FlPortShape.circle,
      color: state.isHovered ? color : color.withValues(alpha: 0.85),
      radius: state.isHovered ? 7 : 5.5,
      linkStyleBuilder: (link) => FlLinkStyle(
        color: link.isSelected || link.isHovered
            ? color
            : const Color(0xFF94A3B8),
        lineWidth: link.isSelected ? 3 : 2.2,
        drawMode: FlLineDrawMode.solid,
        curveType: FlLinkCurveType.bezier,
      ),
    );
  }

  /// Do not use [FlNodesConfig.copyWith] / [FlNodesController.enableSnapToGrid]:
  /// copyWith omits `autoBuildGraph`, `autoExecGraph`, and `autoSave`, which
  /// would reset them to true and execute the graph on every edit.
  static FlNodesConfig editorConfig({
    required bool snapToGrid,
    required double gridSize,
  }) =>
      FlNodesConfig(
        enableZoom: true,
        zoomSensitivity: 0.12,
        minZoom: 0.15,
        maxZoom: 2.5,
        enablePan: true,
        panSensitivity: 1.0,
        enableKineticScrolling: true,
        enableAutoScrolling: true,
        enableAreaSelection: true,
        enableSnapToGrid: snapToGrid,
        snapToGridSize: gridSize,
        autoSave: false,
        autoBuildGraph: false,
        autoExecGraph: false,
      );
}
