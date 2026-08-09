import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/constants/map_constants.dart';
import '../../../../core/models/node_model.dart';
import '../../../../core/models/route_model.dart';

/// Google Maps-style animated route painter.
///
/// Features:
///  • Glowing teal route line that draws in progressively (path-reveal).
///  • A white/teal "moving dot" that tracks along the full path in real time.
///  • Pulsing halo on the origin (blue) and destination (red) nodes.
///  • Semi-transparent white guide shadow drawn under the active line.
class MapOverlayPainter extends CustomPainter {
  final List<NodeModel> nodes;
  final List<RoutePathNodeModel> routeNodesOnFloor;
  final int? startNodeId;
  final int? destinationNodeId;

  /// Animation value 0.0 → 1.0 drives both the route reveal AND the moving dot.
  final double routeProgress;

  /// A secondary pulse oscillator (0.0 → 1.0, looping) for the halo rings.
  final double pulseValue;

  MapOverlayPainter({
    required this.nodes,
    required this.routeNodesOnFloor,
    required this.startNodeId,
    required this.destinationNodeId,
    required this.routeProgress,
    required this.pulseValue,
  });

  Offset _pt(double x, double y) =>
      Offset(MapConstants.toCanvasX(x), MapConstants.toCanvasY(y));

  // ── Teal palette (matches Google Maps navigation colour) ───────────────
  static const Color _routeColor     = Color(0xFF00B2B2);  // teal
  static const Color _routeGlow      = Color(0x5500E5E5);  // translucent cyan glow
  static const Color _shadowColor    = Color(0x33000000);  // route shadow
  static const Color _dotColor       = Color(0xFFFFFFFF);  // moving-dot centre
  static const Color _dotBorder      = Color(0xFF00B2B2);  // moving-dot ring
  static const Color _originColor    = Color(0xFF1A73E8);  // start: Google-blue
  static const Color _destColor      = Color(0xFFEA4335);  // dest:  Google-red

  @override
  void paint(Canvas canvas, Size size) {
    if (routeNodesOnFloor.length < 2) {
      // Even without a route, still paint the nodes.
      _paintNodes(canvas);
      return;
    }

    // Build the complete path from route nodes.
    final path = _buildPath();
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) {
      _paintNodes(canvas);
      return;
    }

    final totalLength =
        metrics.fold<double>(0.0, (sum, m) => sum + m.length);

    // ── 1. Faint shadow underneath (depth effect) ─────────────────────
    _drawShadow(canvas, path, totalLength, metrics);

    // ── 2. Full guide line (very faint – shows full path) ─────────────
    _drawGuide(canvas, path);

    // ── 3. Revealed portion of the glowing teal line ──────────────────
    _drawRevealedLine(canvas, metrics, totalLength);

    // ── 4. Moving "you are here" dot along the revealed route ─────────
    _drawMovingDot(canvas, metrics, totalLength);

    // ── 5. Node markers (start, end, route waypoints, all others) ─────
    _paintNodes(canvas);
  }

  // ── Path helpers ────────────────────────────────────────────────────────

  Path _buildPath() {
    final path = Path();
    final first = routeNodesOnFloor.first;
    path.moveTo(_pt(first.x, first.y).dx, _pt(first.x, first.y).dy);
    for (final node in routeNodesOnFloor.skip(1)) {
      final p = _pt(node.x, node.y);
      path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  // ── Draw calls ──────────────────────────────────────────────────────────

  void _drawShadow(Canvas canvas, Path path, double totalLength,
      List<ui.PathMetric> metrics) {
    final revealLen = totalLength * routeProgress.clamp(0.0, 1.0);
    double consumed = 0;
    for (final metric in metrics) {
      if (consumed >= revealLen) break;
      final extract = math.min(revealLen - consumed, metric.length);
      final seg = metric.extractPath(0, extract);
      canvas.drawPath(
        seg,
        Paint()
          ..color = _shadowColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      consumed += metric.length;
    }
  }

  void _drawGuide(Canvas canvas, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..color = _routeColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawRevealedLine(
      Canvas canvas, List<ui.PathMetric> metrics, double totalLength) {
    final revealLen = totalLength * routeProgress.clamp(0.0, 1.0);

    // Outer glow pass
    double consumed = 0;
    for (final metric in metrics) {
      if (consumed >= revealLen) break;
      final extract = math.min(revealLen - consumed, metric.length);
      canvas.drawPath(
        metric.extractPath(0, extract),
        Paint()
          ..color = _routeGlow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      consumed += metric.length;
    }

    // Core teal line
    consumed = 0;
    for (final metric in metrics) {
      if (consumed >= revealLen) break;
      final extract = math.min(revealLen - consumed, metric.length);
      canvas.drawPath(
        metric.extractPath(0, extract),
        Paint()
          ..color = _routeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      consumed += metric.length;
    }

    // White centre highlight
    consumed = 0;
    for (final metric in metrics) {
      if (consumed >= revealLen) break;
      final extract = math.min(revealLen - consumed, metric.length);
      canvas.drawPath(
        metric.extractPath(0, extract),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      consumed += metric.length;
    }
  }

  void _drawMovingDot(
      Canvas canvas, List<ui.PathMetric> metrics, double totalLength) {
    if (routeProgress <= 0.0) return;

    // The dot travels slightly behind the tip of the revealed line to look
    // like it's pulling the line (classic Google Maps behaviour).
    final dotProgress = (routeProgress - 0.04).clamp(0.0, 1.0);
    final dotDistance = totalLength * dotProgress;

    // Find the tangent position along the multi-segment path.
    Offset? dotPos;
    double consumed = 0;
    for (final metric in metrics) {
      final segEnd = consumed + metric.length;
      if (dotDistance <= segEnd) {
        final localDist = dotDistance - consumed;
        final tangent = metric.getTangentForOffset(localDist);
        if (tangent != null) dotPos = tangent.position;
        break;
      }
      consumed = segEnd;
    }
    if (dotPos == null) return;

    // Outer pulsing ring (cycles with pulseValue).
    final pulseRadius = 14 + 6 * pulseValue;
    canvas.drawCircle(
      dotPos,
      pulseRadius,
      Paint()
        ..color =
            _routeColor.withValues(alpha: (0.35 * (1 - pulseValue)).clamp(0, 1))
        ..style = PaintingStyle.fill,
    );

    // White filled dot.
    canvas.drawCircle(
      dotPos,
      9,
      Paint()
        ..color = _dotColor
        ..style = PaintingStyle.fill,
    );
    // Teal border ring.
    canvas.drawCircle(
      dotPos,
      9,
      Paint()
        ..color = _dotBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    // Inner teal core.
    canvas.drawCircle(
      dotPos,
      4,
      Paint()
        ..color = _dotBorder
        ..style = PaintingStyle.fill,
    );
  }

  // ── Node painting ────────────────────────────────────────────────────────

  void _paintNodes(Canvas canvas) {
    final routeNodeIds = routeNodesOnFloor.map((n) => n.id).toSet();
    final routeComplete = routeProgress >= 1.0;

    for (final node in nodes) {
      final center = _pt(node.x, node.y);
      final isStart = node.id == startNodeId;
      final isDestination = node.id == destinationNodeId;
      final isOnRoute = routeNodeIds.contains(node.id);
      final isTransition =
          node.nodeType == 'lift' || node.nodeType == 'staircase';

      // ── Origin node: blue pulsing ──────────────────────────────────
      if (isStart) {
        _drawPulsingMarker(canvas, center, _originColor);
        continue;
      }

      // ── Destination node: red pulsing (after animation completes) ──
      if (isDestination) {
        _drawPulsingMarker(
          canvas,
          center,
          _destColor,
          showPulse: routeComplete,
        );
        continue;
      }

      // ── On-route transition nodes (lift/stair) ─────────────────────
      if (isOnRoute && isTransition) {
        _drawTransitionMarker(canvas, center, node.nodeType);
        continue;
      }

      // ── All other nodes ────────────────────────────────────────────
      final color = _colorForType(node.nodeType);
      final radius = node.nodeType == 'corridor' ? 2.5 : 5.0;

      canvas.drawCircle(center, radius, Paint()..color = color);
    }
  }

  void _drawPulsingMarker(Canvas canvas, Offset center, Color color,
      {bool showPulse = true}) {
    if (showPulse) {
      // Outermost pulsing ring.
      final outerR = 20 + 8 * pulseValue;
      canvas.drawCircle(
        center,
        outerR,
        Paint()
          ..color = color
              .withValues(alpha: (0.20 * (1 - pulseValue)).clamp(0, 1)),
      );
      // Middle ring.
      canvas.drawCircle(
        center,
        14,
        Paint()..color = color.withValues(alpha: 0.25),
      );
    }

    // Filled circle.
    canvas.drawCircle(center, 10, Paint()..color = color);
    // White border.
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // White inner dot.
    canvas.drawCircle(
      center,
      4,
      Paint()..color = Colors.white,
    );
  }

  void _drawTransitionMarker(Canvas canvas, Offset center, String nodeType) {
    final color = _colorForType(nodeType);
    // Outer halo.
    canvas.drawCircle(
      center,
      13,
      Paint()..color = color.withValues(alpha: 0.22),
    );
    // Border ring.
    canvas.drawCircle(
      center,
      9,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // Fill.
    canvas.drawCircle(
      center,
      7,
      Paint()..color = color.withValues(alpha: 0.85),
    );
    // White centre.
    canvas.drawCircle(
      center,
      3,
      Paint()..color = Colors.white,
    );
  }

  Color _colorForType(String nodeType) {
    switch (nodeType) {
      case 'lift':
        return const Color(0xFF3E7CB1);
      case 'staircase':
        return const Color(0xFFB5563A);
      case 'washroom':
        return const Color(0xFF4E8B5C);
      case 'emergency_exit':
        return const Color(0xFFB23A3A);
      case 'reception':
        return const Color(0xFFD48806);
      case 'corridor':
        return Colors.grey.shade400;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  bool shouldRepaint(covariant MapOverlayPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.routeNodesOnFloor != routeNodesOnFloor ||
        oldDelegate.startNodeId != startNodeId ||
        oldDelegate.destinationNodeId != destinationNodeId ||
        oldDelegate.routeProgress != routeProgress ||
        oldDelegate.pulseValue != pulseValue;
  }
}
