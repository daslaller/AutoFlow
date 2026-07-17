import 'package:flutter/material.dart';

enum NodeCategory { trigger, ops, msg, ai, logic }

enum FieldType { select, text, textarea, code }

enum WireStyle { curved, stepped }

enum RunStatus { idle, running, done }

class CategoryStyle {
  const CategoryStyle({
    required this.label,
    this.color,
    this.gradient,
  });

  final String label;
  final Color? color;
  final Gradient? gradient;
}

class FieldDef {
  const FieldDef({
    required this.key,
    required this.label,
    required this.type,
    this.options = const [],
  });

  final String key;
  final String label;
  final FieldType type;
  final List<String> options;
}

class NodeTypeDef {
  const NodeTypeDef({
    required this.id,
    required this.name,
    required this.category,
    required this.iconPath,
    required this.description,
    required this.fields,
    required this.summary,
    this.ai = false,
    this.outs,
  });

  final String id;
  final String name;
  final NodeCategory category;
  final String iconPath;
  final String description;
  final List<FieldDef> fields;
  final String Function(Map<String, String> config) summary;
  final bool ai;
  final List<String>? outs;
}

class FlowNode {
  FlowNode({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    Map<String, String>? config,
  }) : config = config ?? {};

  final String id;
  final String type;
  double x;
  double y;
  final Map<String, String> config;

  FlowNode copy() => FlowNode(
        id: id,
        type: type,
        x: x,
        y: y,
        config: Map<String, String>.from(config),
      );
}

class FlowWire {
  FlowWire({
    required this.id,
    required this.from,
    required this.port,
    required this.to,
  });

  final String id;
  final String from;
  final int port;
  final String to;
}

class TempWire {
  TempWire({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  double x1;
  double y1;
  double x2;
  double y2;
}

class GhostDrag {
  GhostDrag({
    required this.type,
    required this.x,
    required this.y,
  });

  final String type;
  double x;
  double y;
}

class OutSpec {
  const OutSpec({required this.cy, this.label});

  final double cy;
  final String? label;
}
