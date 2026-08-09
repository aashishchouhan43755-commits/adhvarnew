class RoutePathNodeModel {
  final int id;
  final String name;
  final String nodeType;
  final int floorId;
  final int floorNumber;
  final double x;
  final double y;

  const RoutePathNodeModel({
    required this.id,
    required this.name,
    required this.nodeType,
    required this.floorId,
    required this.floorNumber,
    required this.x,
    required this.y,
  });

  factory RoutePathNodeModel.fromJson(Map<String, dynamic> json) {
    return RoutePathNodeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nodeType: json['node_type'] ?? '',
      floorId: json['floor_id'] ?? 0,
      floorNumber: json['floor_number'] ?? 0,
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RouteModel {
  final double distance;
  final double estimatedTimeSeconds;
  final int startNodeId;
  final int endNodeId;
  final List<int> floorsTraversed;
  final List<RoutePathNodeModel> path;
  final List<String> steps;

  const RouteModel({
    required this.distance,
    required this.estimatedTimeSeconds,
    required this.startNodeId,
    required this.endNodeId,
    required this.floorsTraversed,
    required this.path,
    required this.steps,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      estimatedTimeSeconds:
          (json['estimated_time_seconds'] as num?)?.toDouble() ?? 0,
      startNodeId: json['start_node_id'] ?? 0,
      endNodeId: json['end_node_id'] ?? 0,
      floorsTraversed: List<int>.from(json['floors_traversed'] ?? []),
      path: (json['path'] as List<dynamic>? ?? [])
          .map((e) => RoutePathNodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: List<String>.from(json['steps'] ?? []),
    );
  }

  /// Nodes belonging to a single floor, in path order - used to render
  /// the route segment that lives on that floor's SVG.
  List<RoutePathNodeModel> nodesForFloor(int floorNumber) {
    return path.where((n) => n.floorNumber == floorNumber).toList();
  }

  String get formattedDistance => '${distance.round()} m';

  String get formattedTime {
    final minutes = (estimatedTimeSeconds / 60).ceil();
    if (minutes < 1) return '< 1 min';
    return '$minutes min';
  }
}
