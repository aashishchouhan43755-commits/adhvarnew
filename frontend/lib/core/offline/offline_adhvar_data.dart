import 'dart:math' as math;

import '../models/building_model.dart';
import '../models/floor_model.dart';
import '../models/node_model.dart';
import '../models/room_search_result_model.dart';
import '../models/route_model.dart';

/// A directed edge in the navigation graph. Bidirectional edges are
/// expanded into two entries (one per direction) when the graph is built.
class _Edge {
  final int from;
  final int to;
  final double distance;

  const _Edge(this.from, this.to, this.distance);
}

/// Mirrors backend `core/seed_data.py` + `services/pathfinding_service.py`
/// in pure Dart, so the demo works fully offline: same building, same 3
/// floors, same 30 rooms, same 2 lifts / 2 staircases, same coordinate
/// system as the SVG floor plans, and the same Dijkstra + step-by-step
/// direction logic - just running on-device instead of over HTTP.
class OfflineAdhvarData {
  OfflineAdhvarData._();

  // ---------------------------------------------------------------------
  // Layout constants (identical to seed_data.py / the SVG generator)
  // ---------------------------------------------------------------------
  static const double _corridorY = 150;
  static const List<double> _corridorX = [40, 205, 370];
  static const double _roomTopY = 60;
  static const double _roomBottomY = 240;
  static const double _roomXStart = 70;
  static const double _roomXStep = 40;
  static const double _liftTransitionDistance = 15.0;
  static const double _stairTransitionDistance = 22.0;

  static const int buildingId = 1;
  static const String buildingName = "Adhvar Innovation Center";

  static const Map<int, String> _floorNames = {
    1: "Ground Floor",
    2: "First Floor",
    3: "Second Floor",
  };

  // room_number, room_name, room_type
  static const Map<int, List<List<String>>> _floorRooms = {
    1: [
      ["G01", "Reception", "reception"],
      ["G02", "Help Desk", "office"],
      ["G03", "Visitor Lounge", "lounge"],
      ["G04", "Security Office", "office"],
      ["G05", "Cafeteria", "cafeteria"],
      ["G06", "Server Room", "utility"],
      ["G07", "IT Support Desk", "office"],
      ["G08", "Store Room", "utility"],
      ["G09", "Admin Office", "office"],
      ["G10", "Guest Waiting Area", "lounge"],
    ],
    2: [
      ["101", "Conference Room A", "meeting"],
      ["102", "Conference Room B", "meeting"],
      ["103", "Manager Cabin 1", "office"],
      ["104", "Manager Cabin 2", "office"],
      ["105", "HR Office", "office"],
      ["106", "Finance Office", "office"],
      ["107", "Training Room", "classroom"],
      ["108", "Meeting Pod 1", "meeting"],
      ["109", "Meeting Pod 2", "meeting"],
      ["110", "Open Workspace", "workspace"],
    ],
    3: [
      ["201", "Innovation Lab", "lab"],
      ["202", "Design Studio", "studio"],
      ["203", "R&D Lab 1", "lab"],
      ["204", "R&D Lab 2", "lab"],
      ["205", "Robotics Lab", "lab"],
      ["206", "AI Research Lab", "lab"],
      ["207", "Library", "library"],
      ["208", "Seminar Hall", "hall"],
      ["209", "Director Cabin", "office"],
      ["210", "Board Room", "meeting"],
    ],
  };

  static const Set<String> _transitionNodeTypes = {"lift", "staircase"};
  static const double _walkingSpeedMps = 1.4;

  // ---------------------------------------------------------------------
  // Built once, lazily, on first access.
  // ---------------------------------------------------------------------
  static final List<BuildingModel> buildings = [
    BuildingModel(
      id: buildingId,
      name: buildingName,
      code: "AIC",
      description:
          "Flagship demo building for the Adhvar indoor navigation system.",
      image: '',
      totalFloors: 3,
      latitude: 0,
      longitude: 0,
    ),
  ];

  static final List<FloorModel> floors = _buildFloors();
  static final List<NodeModel> nodes = _buildNodes();
  static final List<RoomSearchResultModel> rooms = _buildRooms();
  static final List<_Edge> _edges = _buildEdges();
  static final Map<int, List<_Edge>> _graph = _buildGraph();

  static List<FloorModel> _buildFloors() {
    return _floorNames.entries
        .map(
          (e) => FloorModel(
            id: e.key,
            buildingId: buildingId,
            name: e.value,
            floorNumber: e.key,
            mapImage: "assets/maps/floor_${e.key}.svg",
          ),
        )
        .toList();
  }

  static int _nearestCorridorIndex(double x) {
    var best = 0;
    var bestDist = (x - _corridorX[0]).abs();
    for (var i = 1; i < _corridorX.length; i++) {
      final d = (x - _corridorX[i]).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  static List<NodeModel> _buildNodes() {
    final result = <NodeModel>[];
    var nid = 1;

    for (final floorNumber in [1, 2, 3]) {
      final corridorIds = <int>[];

      for (final x in _corridorX) {
        result.add(
          NodeModel(
            id: nid,
            floorId: floorNumber,
            name: _corridorLabel(x),
            x: x,
            y: _corridorY,
            nodeType: "corridor",
          ),
        );
        corridorIds.add(nid);
        nid++;
      }

      for (var i = 0; i < _floorRooms[floorNumber]!.length; i++) {
        final roomType = _floorRooms[floorNumber]![i][2];
        final rx = _roomXStart + _roomXStep * i;
        final ry = i % 2 == 0 ? _roomTopY : _roomBottomY;

        result.add(
          NodeModel(
            id: nid,
            floorId: floorNumber,
            roomId: nid, // 1:1 room-node mapping in this offline dataset
            name: _floorRooms[floorNumber]![i][1],
            x: rx,
            y: ry,
            nodeType: roomType == "reception" ? "reception" : "room",
          ),
        );
        nid++;
      }

      for (final entry in {
        "Lift 1": _roomTopY,
        "Lift 2": _roomBottomY,
      }.entries) {
        result.add(
          NodeModel(
            id: nid,
            floorId: floorNumber,
            name: "${entry.key} - Floor $floorNumber",
            x: 40,
            y: entry.value,
            nodeType: "lift",
          ),
        );
        nid++;
      }

      for (final entry in {
        "Staircase 1": _roomTopY,
        "Staircase 2": _roomBottomY,
      }.entries) {
        result.add(
          NodeModel(
            id: nid,
            floorId: floorNumber,
            name: "${entry.key} - Floor $floorNumber",
            x: 370,
            y: entry.value,
            nodeType: "staircase",
          ),
        );
        nid++;
      }

      for (final label in ["Washroom - Male", "Washroom - Female"]) {
        result.add(
          NodeModel(
            id: nid,
            floorId: floorNumber,
            name: "$label (Floor $floorNumber)",
            x: label.contains("Male") ? 185 : 225,
            y: _roomBottomY,
            nodeType: "washroom",
          ),
        );
        nid++;
      }

      result.add(
        NodeModel(
          id: nid,
          floorId: floorNumber,
          name: "Emergency Exit (Floor $floorNumber)",
          x: 370,
          y: _corridorY + 60,
          nodeType: "emergency_exit",
        ),
      );
      nid++;
    }

    return result;
  }

  static String _corridorLabel(double x) {
    final index = _corridorX.indexOf(x);
    return "Corridor ${String.fromCharCode(65 + index)}"; // A, B, C
  }

  static List<RoomSearchResultModel> _buildRooms() {
    final result = <RoomSearchResultModel>[];

    for (final floorNumber in [1, 2, 3]) {
      final floorRooms = _floorRooms[floorNumber]!;

      for (var i = 0; i < floorRooms.length; i++) {
        final roomNumber = floorRooms[i][0];
        final roomName = floorRooms[i][1];
        final roomType = floorRooms[i][2];

        final node = nodes.firstWhere(
          (n) =>
              n.floorId == floorNumber &&
              n.name == roomName &&
              (n.nodeType == "room" || n.nodeType == "reception"),
        );

        result.add(
          RoomSearchResultModel(
            id: node.id,
            roomNumber: roomNumber,
            roomName: roomName,
            roomType: roomType,
            floorId: floorNumber,
            floorNumber: floorNumber,
            floorName: _floorNames[floorNumber]!,
            buildingId: buildingId,
            buildingName: buildingName,
            nodeId: node.id,
            x: node.x,
            y: node.y,
          ),
        );
      }
    }

    return result;
  }

  static List<_Edge> _buildEdges() {
    final edges = <_Edge>[];
    final liftNodesByLabel = <String, List<int>>{"Lift 1": [], "Lift 2": []};
    final stairNodesByLabel = <String, List<int>>{
      "Staircase 1": [],
      "Staircase 2": [],
    };

    for (final floorNumber in [1, 2, 3]) {
      final floorNodes = nodes.where((n) => n.floorId == floorNumber).toList();
      final corridorNodes = floorNodes
          .where((n) => n.nodeType == "corridor")
          .toList()
        ..sort((a, b) => a.x.compareTo(b.x));

      for (var i = 0; i < corridorNodes.length - 1; i++) {
        edges.add(
          _Edge(
            corridorNodes[i].id,
            corridorNodes[i + 1].id,
            (corridorNodes[i].x - corridorNodes[i + 1].x).abs(),
          ),
        );
      }

      NodeModel nearestCorridor(double x) {
        final index = _nearestCorridorIndex(x);
        return corridorNodes[index];
      }

      double dist(NodeModel a, NodeModel b) {
        final dx = a.x - b.x;
        final dy = a.y - b.y;
        return math.sqrt(dx * dx + dy * dy);
      }

      for (final n in floorNodes) {
        if (n.nodeType == "corridor") continue;

        if (n.nodeType == "lift") {
          final c = corridorNodes.first; // Corridor A
          edges.add(_Edge(n.id, c.id, dist(n, c)));
          if (n.name.startsWith("Lift 1")) {
            liftNodesByLabel["Lift 1"]!.add(n.id);
          } else {
            liftNodesByLabel["Lift 2"]!.add(n.id);
          }
        } else if (n.nodeType == "staircase") {
          final c = corridorNodes.last; // Corridor C
          edges.add(_Edge(n.id, c.id, dist(n, c)));
          if (n.name.startsWith("Staircase 1")) {
            stairNodesByLabel["Staircase 1"]!.add(n.id);
          } else {
            stairNodesByLabel["Staircase 2"]!.add(n.id);
          }
        } else if (n.nodeType == "washroom") {
          final c = corridorNodes[1]; // Corridor B
          edges.add(_Edge(n.id, c.id, dist(n, c)));
        } else if (n.nodeType == "emergency_exit") {
          final c = corridorNodes.last; // Corridor C
          edges.add(_Edge(n.id, c.id, (c.y - n.y).abs()));
        } else {
          // room / reception
          final c = nearestCorridor(n.x);
          edges.add(_Edge(n.id, c.id, dist(n, c)));
        }
      }
    }

    for (final ids in liftNodesByLabel.values) {
      for (var i = 0; i < ids.length - 1; i++) {
        edges.add(_Edge(ids[i], ids[i + 1], _liftTransitionDistance));
      }
    }
    for (final ids in stairNodesByLabel.values) {
      for (var i = 0; i < ids.length - 1; i++) {
        edges.add(_Edge(ids[i], ids[i + 1], _stairTransitionDistance));
      }
    }

    return edges;
  }

  static Map<int, List<_Edge>> _buildGraph() {
    final graph = <int, List<_Edge>>{};

    for (final e in _edges) {
      graph.putIfAbsent(e.from, () => []).add(e);
      graph.putIfAbsent(e.to, () => []).add(_Edge(e.to, e.from, e.distance));
    }

    return graph;
  }

  // ---------------------------------------------------------------------
  // Public: search
  // ---------------------------------------------------------------------
  static List<RoomSearchResultModel> searchRooms(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    return rooms
        .where(
          (r) =>
              r.roomName.toLowerCase().contains(q) ||
              r.roomNumber.toLowerCase().contains(q) ||
              r.roomType.toLowerCase().contains(q),
        )
        .toList();
  }

  static List<NodeModel> nodesByFloor(int floorId) {
    return nodes.where((n) => n.floorId == floorId).toList();
  }

  static List<FloorModel> floorsByBuilding(int buildingId) {
    final result = floors.where((f) => f.buildingId == buildingId).toList()
      ..sort((a, b) => a.floorNumber.compareTo(b.floorNumber));
    return result;
  }

  // ---------------------------------------------------------------------
  // Public: Dijkstra + step-by-step directions
  // (ported from pathfinding_service.py, including the departure-before-
  // landing fix for 3+ floor routes)
  // ---------------------------------------------------------------------
  static RouteModel findRoute(int startNodeId, int endNodeId) {
    final distances = <int, double>{startNodeId: 0};
    final previous = <int, int>{};
    final visited = <int>{};
    final frontier = <int>{startNodeId};

    while (frontier.isNotEmpty) {
      int? current;
      double bestDist = double.infinity;
      for (final n in frontier) {
        final d = distances[n]!;
        if (d < bestDist) {
          bestDist = d;
          current = n;
        }
      }

      if (current == null) break;
      frontier.remove(current);

      if (visited.contains(current)) continue;
      visited.add(current);

      if (current == endNodeId) break;

      for (final edge in _graph[current] ?? const <_Edge>[]) {
        final newDist = distances[current]! + edge.distance;
        if (newDist < (distances[edge.to] ?? double.infinity)) {
          distances[edge.to] = newDist;
          previous[edge.to] = current;
          frontier.add(edge.to);
        }
      }
    }

    if (!distances.containsKey(endNodeId)) {
      throw Exception("No route found");
    }

    final pathIds = <int>[];
    var node = endNodeId;
    while (node != startNodeId) {
      pathIds.add(node);
      node = previous[node]!;
    }
    pathIds.add(startNodeId);
    final path = pathIds.reversed.toList();

    final pathNodes = path.map((id) => nodes.firstWhere((n) => n.id == id)).toList();

    final floorsTraversed = <int>[];
    for (final n in pathNodes) {
      if (floorsTraversed.isEmpty || floorsTraversed.last != n.floorId) {
        floorsTraversed.add(n.floorId);
      }
    }

    return RouteModel(
      distance: distances[endNodeId]!,
      estimatedTimeSeconds: distances[endNodeId]! / _walkingSpeedMps,
      startNodeId: startNodeId,
      endNodeId: endNodeId,
      floorsTraversed: floorsTraversed,
      path: pathNodes
          .map(
            (n) => RoutePathNodeModel(
              id: n.id,
              name: n.name,
              nodeType: n.nodeType,
              floorId: n.floorId,
              floorNumber: n.floorId,
              x: n.x,
              y: n.y,
            ),
          )
          .toList(),
      steps: _buildSteps(pathNodes),
    );
  }

  static List<String> _buildSteps(List<NodeModel> pathNodes) {
    if (pathNodes.length < 2) return ["You have arrived."];

    final steps = <String>["Start at ${pathNodes.first.name}."];
    final lastIndex = pathNodes.length - 1;

    for (var i = 1; i < pathNodes.length; i++) {
      final previousNode = pathNodes[i - 1];
      final currentNode = pathNodes[i];
      final isLast = i == lastIndex;

      final isDeparture = _transitionNodeTypes.contains(currentNode.nodeType) &&
          i + 1 <= lastIndex &&
          pathNodes[i + 1].floorId != currentNode.floorId;

      final isLanding = _transitionNodeTypes.contains(previousNode.nodeType) &&
          currentNode.nodeType == previousNode.nodeType &&
          currentNode.floorId != previousNode.floorId;

      // Departure is checked first: on a 3+ floor route via the same
      // shaft, a node can be both the landing from below AND the
      // departure to above - if landing were checked first, that second
      // hop would be silently dropped.
      if (isDeparture) {
        final nextNode = pathNodes[i + 1];
        final verb = currentNode.nodeType == "lift"
            ? "Take the lift"
            : "Take the stairs";
        final direction = nextNode.floorId > currentNode.floorId ? "up" : "down";
        final shaftLabel = currentNode.name.split(" - ").first;
        final floorName = _floorNames[nextNode.floorId] ?? "Floor ${nextNode.floorId}";

        steps.add("$verb $direction to $floorName via $shaftLabel.");
        continue;
      }

      if (isLanding) {
        if (isLast) steps.add("You have arrived at ${currentNode.name}.");
        continue;
      }

      if (isLast) {
        steps.add("You have arrived at ${currentNode.name}.");
      } else if (currentNode.nodeType == "corridor") {
        continue;
      } else {
        steps.add("Head to ${currentNode.name}.");
      }
    }

    return steps;
  }
}
