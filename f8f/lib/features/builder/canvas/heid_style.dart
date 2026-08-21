import 'package:flutter/material.dart';
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/beam_link_effect.dart';
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

  /// **Host hook: the beam's two colours**, as (head, tail), derived from the
  /// port's own kind colour. Replace it to put a host's palette on the wires —
  /// RepairX has one signal colour language and AutoFlow has another, and this
  /// is the seam between them.
  ///
  /// The default keeps one hue per wire: the head is the kind's colour lifted
  /// a little, the tail is the colour itself, fading out. `AnimatedBeam`'s own
  /// amber→violet pair is two brand colours and would say the same thing on
  /// every wire in a canvas whose whole colour language is *which kind of node
  /// this came out of*.
  static (Color, Color) Function(Color kindColor) beamColors = kindBeam;

  static (Color, Color) kindBeam(Color kindColor) => (
        Color.lerp(kindColor, AnchorColors.white, 0.18)!,
        kindColor,
      );

  /// The literal translation of the React defaults — `#ffaa40` → `#9c40ff` —
  /// kept so the two can be photographed side by side.
  static (Color, Color) magicuiBeam(Color _) =>
      (const Color(0xFFFFAA40), const Color(0xFF9C40FF));

  static FlPortStyle portStyle(Color color, FlPortState state) {
    return FlPortStyle(
      shape: FlPortShape.circle,
      color: state.isHovered ? color : color.withValues(alpha: 0.85),
      radius: state.isHovered ? 7 : 5.5,
      linkStyleBuilder: (link) => linkStyle(color, link),
    );
  }

  /// **A placed line, and what it is doing.** A wire in a workflow is not
  /// decoration — it is the claim that *this* runs and then *that* does — and
  /// a static curve says the shape of that claim without ever saying its
  /// direction. Which end feeds which was previously readable only by finding
  /// the ports and reasoning about them.
  ///
  /// So the line carries a beam: an opaque head running source → target over
  /// a faint path. Direction, at a glance, on every wire at once. See
  /// [BeamLinkEffect] for the design source (magicui's `AnimatedBeam`) and
  /// for what was translated and what was deliberately not.
  ///
  /// Three choices in here that are not the obvious ones:
  ///
  /// - **The resting path is slate ink, not the port's colour.** The painter
  ///   lays it down at 22% under the beam (the React component's
  ///   `pathColor: gray, pathOpacity: 0.2`), and a graph whose five wires are
  ///   each a different saturated hue at 22% reads as smudges competing with
  ///   the node headers. The *beam* is where the kind's colour belongs,
  ///   because that is the part you are meant to follow.
  /// - **The head is a tint of the port's colour, the tail is the colour
  ///   itself.** `AnimatedBeam` ships an orange→purple pair, which is its own
  ///   brand and would put a fixed second hue on every wire in a canvas whose
  ///   whole colour language is *kind*. One hue per wire, brightened at the
  ///   head, keeps the trigger green, the branch amber, the transform violet.
  /// - **Selecting or hovering speeds the beam up** (5s → 2.6s) and widens it,
  ///   rather than only thickening the line. The wire you asked about is the
  ///   one that should look busiest.
  static FlLinkStyle linkStyle(Color portColor, FlLinkState link) {
    final bool lit = link.isSelected || link.isHovered;
    return FlLinkStyle(
      color: lit ? portColor : const Color(0xFF334155),
      lineWidth: lit ? 3 : 2.2,
      drawMode: FlLineDrawMode.solid,
      curveType: FlLinkCurveType.bezier,
      effect: BeamLinkEffect(
        headColor: beamColors(portColor).$1,
        tailColor: beamColors(portColor).$2,
        duration: lit ? 2.6 : 5.0,
        beamFraction: lit ? 0.55 : 0.45,
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
