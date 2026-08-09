import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/map_constants.dart';
import '../../../../core/models/node_model.dart';
import '../../../../core/models/route_model.dart';
import 'map_overlay_painter.dart';

class MapCanvas extends StatelessWidget {
  final String svgAssetPath;
  final List<NodeModel> nodes;
  final List<RoutePathNodeModel> routeNodesOnFloor;
  final int? startNodeId;
  final int? destinationNodeId;
  final double routeProgress;

  /// Drives the pulsing halo animation (0.0 → 1.0, looping).
  final double pulseValue;

  final void Function(NodeModel node)? onNodeTap;

  const MapCanvas({
    super.key,
    required this.svgAssetPath,
    required this.nodes,
    this.routeNodesOnFloor = const [],
    this.startNodeId,
    this.destinationNodeId,
    this.routeProgress = 1.0,
    this.pulseValue = 0.0,
    this.onNodeTap,
  });

  NodeModel? _nearestNode(Offset tapPosition) {
    NodeModel? nearest;
    double nearestDistance = 22; // tap tolerance in canvas px

    for (final node in nodes) {
      final dx = MapConstants.toCanvasX(node.x) - tapPosition.dx;
      final dy = MapConstants.toCanvasY(node.y) - tapPosition.dy;
      final distance = (dx * dx + dy * dy);

      if (distance < nearestDistance * nearestDistance) {
        nearestDistance = distance;
        nearest = node;
      }
    }

    return nearest;
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4,
      boundaryMargin: const EdgeInsets.all(80),
      child: SizedBox(
        width: MapConstants.canvasWidth,
        height: MapConstants.canvasHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                svgAssetPath,
                fit: BoxFit.fill,
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTapUp: onNodeTap == null
                    ? null
                    : (details) {
                        final node = _nearestNode(details.localPosition);
                        if (node != null) onNodeTap!(node);
                      },
                child: CustomPaint(
                  painter: MapOverlayPainter(
                    nodes: nodes,
                    routeNodesOnFloor: routeNodesOnFloor,
                    startNodeId: startNodeId,
                    destinationNodeId: destinationNodeId,
                    routeProgress: routeProgress,
                    pulseValue: pulseValue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
