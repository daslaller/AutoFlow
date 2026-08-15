import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/features/builder/canvas/port_geometry.dart';
import 'package:autoflow/theme/anchor_colors.dart';

Path bezierWire(Offset from, Offset to) {
  final dx = (to.dx - from.dx).abs();
  final cx = math.max(dx * 0.45, 48.0);
  return Path()
    ..moveTo(from.dx, from.dy)
    ..cubicTo(from.dx + cx, from.dy, to.dx - cx, to.dy, to.dx, to.dy);
}

Paint _aaStroke({
  required Color color,
  required double width,
  StrokeCap cap = StrokeCap.round,
  StrokeJoin join = StrokeJoin.round,
}) {
  return Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = cap
    ..strokeJoin = join;
}

class WirePainter extends CustomPainter {
  WirePainter({
    required this.nodes,
    required this.wires,
    required this.catalog,
    required this.dashPhase,
    this.hoveredWireId,
    this.snapTargetId,
    this.zoom = 1.0,
  });

  final List<CanvasNode> nodes;
  final List<Wire> wires;
  final NodeCatalog catalog;
  final double dashPhase;
  final String? hoveredWireId;
  final String? snapTargetId;
  final double zoom;

  /// Keep stroke readable when zoomed; never hairline-thin.
  double get _sw => (1 / zoom).clamp(0.9, 1.8);

  CanvasNode? _byId(String id) {
    for (final n in nodes) {
      if (n.iid == id) return n;
    }
    return null;
  }

  NodeTypeDef? _type(CanvasNode n) => catalog.find(n.def.id);

  void _drawSmoothStroke(
    Canvas canvas,
    Path path, {
    required Color color,
    required double width,
    bool dashed = false,
    double dash = 10,
    double gap = 6,
  }) {
    canvas.drawPath(
      path,
      _aaStroke(
        color: color.withValues(alpha: 0.18),
        width: (width + 3.2) * _sw,
      ),
    );
    final top = _aaStroke(color: color, width: width * _sw);
    if (dashed) {
      _drawDashed(canvas, path, top, dash, gap, dashPhase);
    } else {
      canvas.drawPath(path, top);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Paint directly — a saveLayer the size of the 6000² world exceeds
    // typical GPU texture limits and drops every stroke, including the
    // in-progress drag line.
    for (final w in wires) {
      final fn = _byId(w.from);
      final tn = _byId(w.to);
      if (fn == null || tn == null) continue;
      final from = PortGeometry.output(fn, w.fromPort, _type(fn));
      final to = PortGeometry.input(tn, w.toPort, _type(tn));
      final path = bezierWire(from, to);
      final kindColor = fn.def.kind.color;
      final hovered = w.id == hoveredWireId;
      final active =
          fn.status == RunStatus.success || fn.status == RunStatus.running;
      final flowing = fn.status == RunStatus.running;

      if (hovered) {
        canvas.drawPath(
          path,
          _aaStroke(
            color: AnchorColors.destructive.withValues(alpha: 0.16),
            width: 14 * _sw,
          ),
        );
      } else if (active) {
        canvas.drawPath(
          path,
          _aaStroke(
            color: kindColor.withValues(alpha: 0.14),
            width: 10 * _sw,
          ),
        );
      }

      final color = hovered
          ? AnchorColors.destructive
          : (active ? kindColor : AnchorColors.slate500);

      _drawSmoothStroke(
        canvas,
        path,
        color: color,
        width: hovered ? 3.0 : (active ? 2.4 : 2.1),
        dashed: flowing && !hovered,
      );

      if (hovered) {
        final metrics = path.computeMetrics().toList();
        if (metrics.isNotEmpty) {
          final mid =
              metrics.first.getTangentForOffset(metrics.first.length / 2);
          if (mid != null) {
            final p = mid.position;
            canvas.drawCircle(
              p,
              9,
              Paint()
                ..isAntiAlias = true
                ..color = AnchorColors.white,
            );
            canvas.drawCircle(
              p,
              9,
              _aaStroke(color: AnchorColors.destructive, width: 1.5),
            );
            final xPaint = _aaStroke(color: AnchorColors.destructive, width: 1.6);
            canvas.drawLine(
              p + const Offset(-3.5, -3.5),
              p + const Offset(3.5, 3.5),
              xPaint,
            );
            canvas.drawLine(
              p + const Offset(3.5, -3.5),
              p + const Offset(-3.5, 3.5),
              xPaint,
            );
          }
        }
      }
    }

    if (snapTargetId != null) {
      final n = _byId(snapTargetId!);
      if (n != null) {
        final type = _type(n);
        final ports = PortGeometry.inputsOf(type);
        final p = ports.isEmpty
            ? PortGeometry.input(n, null, type)
            : PortGeometry.input(n, ports.first.id, type);
        canvas.drawCircle(
          p,
          16,
          Paint()
            ..isAntiAlias = true
            ..color = AnchorColors.success.withValues(alpha: 0.15),
        );
        canvas.drawCircle(
          p,
          16,
          _aaStroke(color: AnchorColors.success, width: 2),
        );
      }
    }
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint,
    double dash,
    double gap,
    double phase,
  ) {
    for (final metric in path.computeMetrics()) {
      var distance = phase % (dash + gap);
      while (distance < metric.length) {
        final next = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  String? hitTestWire(Offset worldPoint) {
    for (final w in wires) {
      final fn = _byId(w.from);
      final tn = _byId(w.to);
      if (fn == null || tn == null) continue;
      final path = bezierWire(
        PortGeometry.output(fn, w.fromPort, _type(fn)),
        PortGeometry.input(tn, w.toPort, _type(tn)),
      );
      for (final metric in path.computeMetrics()) {
        for (var d = 0.0; d < metric.length; d += 2) {
          final tan = metric.getTangentForOffset(d);
          if (tan != null && (tan.position - worldPoint).distance < 14) {
            return w.id;
          }
        }
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant WirePainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.wires != wires ||
        oldDelegate.catalog != catalog ||
        oldDelegate.dashPhase != dashPhase ||
        oldDelegate.hoveredWireId != hoveredWireId ||
        oldDelegate.snapTargetId != snapTargetId ||
        oldDelegate.zoom != zoom;
  }

  @override
  bool? hitTest(Offset position) => null;
}

/// Viewport-space rubber-band drawn while dragging a new wire. Lives outside
/// the 6000² world transform so the preview cannot vanish with the layer.
class DrawingWirePainter extends CustomPainter {
  DrawingWirePainter({
    required this.from,
    required this.to,
    required this.valid,
  });

  final Offset from;
  final Offset to;
  final bool valid;

  @override
  void paint(Canvas canvas, Size size) {
    final path = bezierWire(from, to);
    final color = valid ? AnchorColors.success : AnchorColors.primary;
    canvas.drawPath(
      path,
      _aaStroke(color: color.withValues(alpha: 0.2), width: 6),
    );
    canvas.drawPath(
      path,
      _aaStroke(color: color, width: 2.4)
        ..strokeCap = StrokeCap.round,
    );
    _dash(canvas, path, _aaStroke(color: AnchorColors.white.withValues(alpha: 0.55), width: 2.4), 7, 5);
    canvas.drawCircle(
      to,
      valid ? 8 : 6,
      Paint()
        ..isAntiAlias = true
        ..color = color.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      to,
      valid ? 8 : 6,
      _aaStroke(color: color, width: 2),
    );
    canvas.drawCircle(
      from,
      5,
      Paint()
        ..isAntiAlias = true
        ..color = color,
    );
  }

  void _dash(Canvas canvas, Path path, Paint paint, double dash, double gap) {
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final next = math.min(d + dash, metric.length);
        canvas.drawPath(metric.extractPath(d, next), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingWirePainter oldDelegate) {
    return oldDelegate.from != from ||
        oldDelegate.to != to ||
        oldDelegate.valid != valid;
  }
}
