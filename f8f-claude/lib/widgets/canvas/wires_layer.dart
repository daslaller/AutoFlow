import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flowstock/controller/flow_controller.dart';
import 'package:flowstock/data/node_catalog.dart';
import 'package:flowstock/models/models.dart';
import 'package:flowstock/theme/flowstock_colors.dart';

class WiresLayer extends StatelessWidget {
  const WiresLayer({
    super.key,
    required this.controller,
    required this.dashAnimation,
    this.origin = 0,
  });

  final FlowController controller;
  final Animation<double> dashAnimation;
  final double origin;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dashAnimation,
      builder: (context, _) {
        return CustomPaint(
          painter: _WiresPainter(
            controller: controller,
            dashPhase: dashAnimation.value * 28,
            origin: origin,
          ),
        );
      },
    );
  }
}

class _WiresPainter extends CustomPainter {
  _WiresPainter({
    required this.controller,
    required this.dashPhase,
    required this.origin,
  });

  final FlowController controller;
  final double dashPhase;
  final double origin;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(origin, origin);
    final c = controller;
    final byId = {for (final n in c.nodes) n.id: n};

    for (final w in c.wires) {
      final a = byId[w.from];
      final b = byId[w.to];
      if (a == null || b == null) continue;
      final p1 = NodeCatalog.outPos(a, w.port);
      final p2 = NodeCatalog.inPos(b);
      final path = c.wirePath(p1.dx, p1.dy, p2.dx, p2.dy);
      final st = c.wrun[w.id];
      final sel = c.selectedWireId == w.id;

      final Color stroke;
      if (st == RunStatus.running) {
        stroke = FsColors.blue500;
      } else if (st == RunStatus.done) {
        stroke = FsColors.blue600;
      } else if (sel) {
        stroke = FsColors.blue600;
      } else {
        stroke = FsColors.slate300;
      }
      final sw = (sel || st != null) ? 2.5 : 2.0;

      final paint = Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round;

      if (st == RunStatus.running) {
        _drawDashed(canvas, path, paint, 8, 6, dashPhase);
      } else {
        canvas.drawPath(path, paint);
      }
    }

    final temp = c.temp;
    if (temp != null) {
      final path = c.wirePath(temp.x1, temp.y1, temp.x2, temp.y2);
      final paint = Paint()
        ..color = FsColors.blue600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      _drawDashed(canvas, path, paint, 6, 5, dashPhase);
    }
    canvas.restore();
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint,
    double dash,
    double gap,
    double phase,
  ) {
    final period = dash + gap;
    for (final metric in path.computeMetrics()) {
      var dist = -phase % period;
      if (dist > 0) dist -= period;
      var draw = true;
      while (dist < metric.length) {
        final len = draw ? dash : gap;
        final start = math.max(0.0, dist);
        final next = math.min(dist + len, metric.length);
        if (draw && next > start) {
          canvas.drawPath(metric.extractPath(start, next), paint);
        }
        dist += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WiresPainter oldDelegate) => true;
}

class WireHitTester {
  static String? hit(
    FlowController c,
    Offset worldPos, {
    double threshold = 8,
  }) {
    final byId = {for (final n in c.nodes) n.id: n};
    for (final w in c.wires.reversed) {
      final a = byId[w.from];
      final b = byId[w.to];
      if (a == null || b == null) continue;
      final p1 = NodeCatalog.outPos(a, w.port);
      final p2 = NodeCatalog.inPos(b);
      final path = c.wirePath(p1.dx, p1.dy, p2.dx, p2.dy);
      for (final metric in path.computeMetrics()) {
        for (var d = 0.0; d < metric.length; d += 4) {
          final t = metric.getTangentForOffset(d);
          if (t != null && (t.position - worldPos).distance <= threshold) {
            return w.id;
          }
        }
      }
    }
    return null;
  }
}
