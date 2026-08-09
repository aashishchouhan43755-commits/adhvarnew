class MapMarkerModel {
  final int id;
  final int buildingId;
  final int floorId;
  final String name;
  final String type;
  final double xCoordinate;
  final double yCoordinate;
  final String icon;
  final bool isVisible;

  const MapMarkerModel({
    required this.id,
    required this.buildingId,
    required this.floorId,
    required this.name,
    required this.type,
    required this.xCoordinate,
    required this.yCoordinate,
    required this.icon,
    this.isVisible = true,
  });

  factory MapMarkerModel.fromJson(Map<String, dynamic> json) {
    return MapMarkerModel(
      id: json['id'] ?? 0,
      buildingId: json['building_id'] ?? 0,
      floorId: json['floor_id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      xCoordinate: (json['x_coordinate'] ?? 0).toDouble(),
      yCoordinate: (json['y_coordinate'] ?? 0).toDouble(),
      icon: json['icon'] ?? '',
      isVisible: json['is_visible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'building_id': buildingId,
      'floor_id': floorId,
      'name': name,
      'type': type,
      'x_coordinate': xCoordinate,
      'y_coordinate': yCoordinate,
      'icon': icon,
      'is_visible': isVisible,
    };
  }

  MapMarkerModel copyWith({
    int? id,
    int? buildingId,
    int? floorId,
    String? name,
    String? type,
    double? xCoordinate,
    double? yCoordinate,
    String? icon,
    bool? isVisible,
  }) {
    return MapMarkerModel(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      floorId: floorId ?? this.floorId,
      name: name ?? this.name,
      type: type ?? this.type,
      xCoordinate: xCoordinate ?? this.xCoordinate,
      yCoordinate: yCoordinate ?? this.yCoordinate,
      icon: icon ?? this.icon,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  String toString() {
    return 'MapMarkerModel(id: $id, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MapMarkerModel &&
        other.id == id &&
        other.buildingId == buildingId &&
        other.floorId == floorId &&
        other.name == name &&
        other.type == type &&
        other.xCoordinate == xCoordinate &&
        other.yCoordinate == yCoordinate &&
        other.icon == icon &&
        other.isVisible == isVisible;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      buildingId,
      floorId,
      name,
      type,
      xCoordinate,
      yCoordinate,
      icon,
      isVisible,
    );
  }
}
