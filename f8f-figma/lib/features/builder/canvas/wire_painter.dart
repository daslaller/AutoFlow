import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:autoflow/domain/models.dart';
import 'package:autoflow/theme/anchor_colors.dart';
import 'package:autoflow/theme/anchor_spacing.dart';

Path bezierWire(Offset from, Offset to) {
  final cx = math.max((to.dx - from.dx).abs() * 0.45, 60.0);
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
    required this.drawingWire,
    required this.dashPhase,
    this.hoveredWireId,
    this.snapTargetId,
    this.drawingValid = false,
    this.zoom = 1.0,
  });

  final List<CanvasNode> nodes;
  final List<Wire> wires;
  final DrawingWire? drawingWire;
  final double dashPhase;
  final String? hoveredWireId;
  final String? snapTargetId;
  final bool drawingValid;
  final double zoom;

  /// Keep stroke visually consistent when zoomed; clamp for readability.
  double get _sw => (1 / zoom).clamp(0.85, 1.6);

  CanvasNode? _byId(String id) {
    for (final n in nodes) {
      if (n.iid == id) return n;
    }
    return null;
  }

  void _drawSmoothStroke(
    Canvas canvas,
    Path path, {
    required Color color,
    required double width,
    bool dashed = false,
    double dash = 10,
    double gap = 6,
  }) {
    // Soft under-stroke for AA / glow
    canvas.drawPath(
      path,
      _aaStroke(
        color: color.withValues(alpha: 0.22),
        width: (width + 2.5) * _sw,
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
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..isAntiAlias = true ..filterQuality = FilterQuality.high,
    );

    for (final w in wires) {
      final fn = _byId(w.from);
      final tn = _byId(w.to);
      if (fn == null || tn == null) continue;
      final from = _portOut(fn, w.fromPort);
      final to = _portIn(tn, w.toPort);
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
            color: kindColor.withValues(alpha: 0.12),
            width: 10 * _sw,
          ),
        );
      }

      final color = hovered
          ? AnchorColors.destructive
          : (active ? kindColor.withValues(alpha: 0.92) : AnchorColors.slate300);

      _drawSmoothStroke(
        canvas,
        path,
        color: color,
        width: hovered ? 3.0 : (active ? 2.2 : 1.75),
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

    if (drawingWire != null) {
      final path = bezierWire(
        Offset(drawingWire!.fx, drawingWire!.fy),
        Offset(drawingWire!.tx, drawingWire!.ty),
      );
      final color =
          drawingValid ? AnchorColors.success : AnchorColors.primary;
      _drawSmoothStroke(
        canvas,
        path,
        color: color.withValues(alpha: 0.9),
        width: drawingValid ? 2.4 : 1.9,
        dashed: true,
        dash: 7,
        gap: 4,
      );
      canvas.drawCircle(
        Offset(drawingWire!.tx, drawingWire!.ty),
        drawingValid ? 7 : 5,
        Paint()
          ..isAntiAlias = true
          ..color = color.withValues(alpha: 0.2),
      );
      canvas.drawCircle(
        Offset(drawingWire!.tx, drawingWire!.ty),
        drawingValid ? 7 : 5,
        _aaStroke(color: color, width: 2),
      );
    }

    if (snapTargetId != null) {
      final n = _byId(snapTargetId!);
      if (n != null) {
        final p = Offset(n.x, n.y + AnchorSpacing.nodeHeight / 2);
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

    canvas.restore();
  }

  Offset _portOut(CanvasNode n, String? portId) {
    // Multi-port ready: default single right-center output
    return Offset(
      n.x + AnchorSpacing.nodeWidth,
      n.y + AnchorSpacing.nodeHeight / 2,
    );
  }

  Offset _portIn(CanvasNode n, String? portId) {
    return Offset(n.x, n.y + AnchorSpacing.nodeHeight / 2);
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
      final path = bezierWire(_portOut(fn, w.fromPort), _portIn(tn, w.toPort));
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
        oldDelegate.drawingWire != drawingWire ||
        oldDelegate.dashPhase != dashPhase ||
        oldDelegate.hoveredWireId != hoveredWireId ||
        oldDelegate.snapTargetId != snapTargetId ||
        oldDelegate.drawingValid != drawingValid ||
        oldDelegate.zoom != zoom;
  }

  @override
  bool? hitTest(Offset position) => null;
}
