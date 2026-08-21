import 'dart:ui';

import 'package:flutter/animation.dart' show Curve, Cubic;
import 'package:fl_nodes_visual_scripting/fl_nodes_visual_scripting.dart';

/// **DESIGN SOURCE: magicui's `AnimatedBeam`** (React + SVG + `motion`),
/// handed over by the owner on 2026-08-21 as the look the placed lines should
/// have. What it draws is two paths on top of each other: the link itself,
/// held at ~20% opacity so the graph still reads when nothing is moving, and
/// a **travelling gradient window** — a comet with an opaque head and a tail
/// that fades out — sliding from the source end to the target end on a five
/// second `easeOutExpo`, forever.
///
/// The numbers below are the React component's own defaults, kept so the two
/// can be compared side by side: `duration: 5`, `delay: 0`, `repeatDelay: 0`,
/// a beam window 10% of the run, and the four gradient stops
/// `[head, head, 32.5% tail, tail@0]`.
///
/// ## The one deliberate deviation: it travels in PATH space, not in x
///
/// `AnimatedBeam` animates an SVG `linearGradient`'s `x1`/`x2` in user space,
/// so the beam sweeps left to right **across the container** and the curve is
/// only what the sweep happens to be clipped to. That is fine for the marketing
/// diagram it was written for, where every beam runs roughly horizontally into
/// one hub. On a node canvas it degenerates: a link that drops straight down
/// (an if/else's two arms, a node dragged under its source) has no x extent to
/// sweep along, so every pixel of it would sit at the same gradient offset and
/// the whole wire would flash as one block instead of a beam running along it.
///
/// So the window is measured in **arc length** via [PathMetric]: the head is
/// `d` along the curve and the tail is `d - beam`, whichever way the wire
/// bends. On a horizontal link this is pixel-for-pixel what the React version
/// does; on a vertical one it is the thing the React version was trying to be.
///
/// ## And one thing deliberately NOT taken: a glow
///
/// The obvious reach is a blurred copy of the segment under the beam. The
/// canvas ground is `slate50` — near white — and additive light on a near-white
/// ground has no darkness to fill, so a glow renders as a grey smear around the
/// wire rather than as light. (Same finding as RepairX's boot splash, which had
/// to mask its glow's alpha for exactly this reason.) The head being fully
/// opaque against a 20% path is what reads as brightness here.
class BeamLinkEffect implements FlLinkEffect {
  const BeamLinkEffect({
    required this.headColor,
    required this.tailColor,
    this.duration = 5.0,
    this.delay = 0.0,
    this.repeatDelay = 0.0,
    this.beamFraction = 0.1,
    this.tailStop = 0.325,
    this.reverse = false,
    this.strokeWidth,
    this.minBeamLength = 24.0,
  });

  /// The comet's leading edge — opaque. `gradientStartColor`, `#ffaa40`.
  final Color headColor;

  /// What it fades through and out into. `gradientStopColor`, `#9c40ff`.
  final Color tailColor;

  /// Seconds for one end-to-end pass. `duration`.
  final double duration;

  /// Seconds before the first pass. Stagger sibling links with this rather
  /// than with a per-link ticker: every link shares the controller's one
  /// clock, so a delay is the only phase control there is.
  final double delay;

  /// Dead time between passes. `repeatDelay`.
  final double repeatDelay;

  /// Beam length as a fraction of the link's own length. The React version's
  /// 10% is a fraction of the *container*, which is why short links there get
  /// a beam longer than themselves; here it is per link.
  final double beamFraction;

  /// Where [tailColor] reaches full strength, measured from the head.
  final double tailStop;

  /// Run target → source. `reverse`.
  final bool reverse;

  /// Defaults to the link's own width — the React component draws base and
  /// beam at the same `pathWidth`.
  final double? strokeWidth;

  /// A floor for [beamFraction] on very short links, where 10% of the run is
  /// a dot and reads as a rendering fault rather than as motion.
  final double minBeamLength;

  /// `cubic-bezier(0.16, 1, 0.3, 1)` — easings.net's easeOutExpo, the curve
  /// the React component names. Flutter's own `Curves.easeOutExpo` is a
  /// different cubic (0.19, 1, 0.22, 1); this is the one in the source.
  static const Curve easeOutExpo = Cubic(0.16, 1, 0.3, 1);

  @override
  void paint(
    Canvas canvas,
    Path path,
    Paint basePaint,
    double animationValue,
  ) {
    // [animationValue] is continuous seconds from the controller's ticker, not
    // a 0..1 loop — the modulo is ours to do, and doing it here is what lets
    // [delay] mean what it means in the React component.
    final double elapsed = animationValue - delay;
    if (elapsed < 0) return;

    final double cycle = duration + repeatDelay;
    if (cycle <= 0 || duration <= 0) return;
    final double inCycle = elapsed % cycle;
    if (inCycle > duration) return; // resting between passes

    final double total = _length(path);
    if (total <= 0) return;

    final double beam = (total * beamFraction).clamp(
      minBeamLength.clamp(0.0, total),
      total,
    );
    final double eased = easeOutExpo.transform((inCycle / duration).clamp(0.0, 1.0));

    // At t=0 the window sits with its tail on the start and its head one beam
    // in; at t=1 the tail is on the end and the head a beam past it. Exactly
    // the x2: 0%→100% / x1: 10%→110% pair the SVG animates.
    final double tail = eased * total;
    final double head = tail + beam;

    final double from = (reverse ? total - head : tail).clamp(0.0, total);
    final double to = (reverse ? total - tail : head).clamp(0.0, total);
    if (to - from <= 0.01) return;

    final Path segment = _extract(path, from, to);
    final Offset? headPoint = _pointAt(path, reverse ? from : to);
    final Offset? tailPoint = _pointAt(path, reverse ? to : from);
    if (headPoint == null || tailPoint == null) return;
    if ((headPoint - tailPoint).distance < 0.5) return;

    canvas.drawPath(
      segment,
      Paint()
        ..shader = Gradient.linear(
          headPoint,
          tailPoint,
          <Color>[
            headColor,
            tailColor,
            tailColor.withValues(alpha: 0),
          ],
          <double>[0.0, tailStop, 1.0],
        )
        ..strokeWidth = strokeWidth ?? basePaint.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }

  double _length(Path path) {
    var total = 0.0;
    for (final PathMetric metric in path.computeMetrics()) {
      total += metric.length;
    }
    return total;
  }

  /// [PathMetrics] is single-pass, so every read re-computes. A link is one or
  /// two segments, so this is cheap; it is the reason the helpers take a
  /// [Path] rather than a metric.
  Path _extract(Path path, double from, double to) {
    final Path out = Path();
    var walked = 0.0;
    for (final PathMetric metric in path.computeMetrics()) {
      final double start = from - walked;
      final double end = to - walked;
      if (end > 0 && start < metric.length) {
        out.addPath(
          metric.extractPath(
            start.clamp(0.0, metric.length),
            end.clamp(0.0, metric.length),
          ),
          Offset.zero,
        );
      }
      walked += metric.length;
    }
    return out;
  }

  Offset? _pointAt(Path path, double distance) {
    var walked = 0.0;
    for (final PathMetric metric in path.computeMetrics()) {
      if (distance <= walked + metric.length) {
        return metric.getTangentForOffset(distance - walked)?.position;
      }
      walked += metric.length;
    }
    return null;
  }
}
