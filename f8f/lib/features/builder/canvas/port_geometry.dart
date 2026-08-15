import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

/// Shared node/port layout so the card, hit-tester and wire painter agree.
abstract final class PortGeometry {
  static const double minHeight = AnchorSpacing.nodeHeight;
  static const double portSlot = 26;
  static const double chrome = 28;

  static double nodeWidth([NodeTypeDef? _]) => AnchorSpacing.nodeWidth;

  static double nodeHeight(NodeTypeDef? type) {
    final n = math.max(type?.inputs.length ?? 0, type?.outputs.length ?? 0);
    if (n <= 1) return minHeight;
    return math.max(minHeight, chrome + n * portSlot);
  }

  static Size nodeSize(NodeTypeDef? type) =>
      Size(nodeWidth(type), nodeHeight(type));

  static List<PortDef> outputsOf(NodeTypeDef? type) {
    if (type == null || type.outputs.isEmpty) {
      return const [PortDef(id: 'out', label: 'Out')];
    }
    return type.outputs;
  }

  static List<PortDef> inputsOf(NodeTypeDef? type) => type?.inputs ?? const [];

  static Offset output(CanvasNode n, String? portId, NodeTypeDef? type) {
    final ports = outputsOf(type);
    return Offset(
      n.x + nodeWidth(type),
      n.y + slotY(ports, portId, nodeHeight(type)),
    );
  }

  static Offset input(CanvasNode n, String? portId, NodeTypeDef? type) {
    final ports = inputsOf(type);
    final h = nodeHeight(type);
    if (ports.isEmpty) return Offset(n.x, n.y + h / 2);
    return Offset(n.x, n.y + slotY(ports, portId, h));
  }

  static double slotY(List<PortDef> ports, String? portId, double height) {
    if (ports.length <= 1) return height / 2;
    var i = ports.indexWhere((p) => p.id == portId);
    if (i < 0) i = 0;
    final gap = height / (ports.length + 1);
    return gap * (i + 1);
  }

  static NodeTypeDef? typeOf(CanvasNode n, NodeCatalog catalog) =>
      catalog.find(n.def.id);
}
