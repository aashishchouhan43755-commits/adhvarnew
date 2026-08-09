class NavigationRouteModel {
  final int id;
  final int buildingId;
  final int floorId;
  final String startLocation;
  final String destination;
  final double distance;
  final int estimatedTime;
  final List<String> navigationSteps;
  final bool isAccessible;

  const NavigationRouteModel({
    required this.id,
    required this.buildingId,
    required this.floorId,
    required this.startLocation,
    required this.destination,
    required this.distance,
    required this.estimatedTime,
    required this.navigationSteps,
    this.isAccessible = false,
  });

  factory NavigationRouteModel.fromJson(Map<String, dynamic> json) {
    return NavigationRouteModel(
      id: json['id'] ?? 0,
      buildingId: json['building_id'] ?? 0,
      floorId: json['floor_id'] ?? 0,
      startLocation: json['start_location'] ?? '',
      destination: json['destination'] ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      estimatedTime: json['estimated_time'] ?? 0,
      navigationSteps: List<String>.from(json['navigation_steps'] ?? []),
      isAccessible: json['is_accessible'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'building_id': buildingId,
      'floor_id': floorId,
      'start_location': startLocation,
      'destination': destination,
      'distance': distance,
      'estimated_time': estimatedTime,
      'navigation_steps': navigationSteps,
      'is_accessible': isAccessible,
    };
  }

  NavigationRouteModel copyWith({
    int? id,
    int? buildingId,
    int? floorId,
    String? startLocation,
    String? destination,
    double? distance,
    int? estimatedTime,
    List<String>? navigationSteps,
    bool? isAccessible,
  }) {
    return NavigationRouteModel(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      floorId: floorId ?? this.floorId,
      startLocation: startLocation ?? this.startLocation,
      destination: destination ?? this.destination,
      distance: distance ?? this.distance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      navigationSteps: navigationSteps ?? this.navigationSteps,
      isAccessible: isAccessible ?? this.isAccessible,
    );
  }

  @override
  String toString() {
    return 'NavigationRouteModel(id: $id, destination: $destination)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NavigationRouteModel &&
        other.id == id &&
        other.buildingId == buildingId &&
        other.floorId == floorId &&
        other.startLocation == startLocation &&
        other.destination == destination &&
        other.distance == distance &&
        other.estimatedTime == estimatedTime &&
        other.navigationSteps == navigationSteps &&
        other.isAccessible == isAccessible;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      buildingId,
      floorId,
      startLocation,
      destination,
      distance,
      estimatedTime,
      navigationSteps,
      isAccessible,
    );
  }
}
