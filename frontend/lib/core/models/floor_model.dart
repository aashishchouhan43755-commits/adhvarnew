class FloorModel {
  final int id;
  final int buildingId;
  final String name;
  final int floorNumber;
  final String mapImage;
  final bool isActive;

  const FloorModel({
    required this.id,
    required this.buildingId,
    required this.name,
    required this.floorNumber,
    required this.mapImage,
    this.isActive = true,
  });

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      id: json['id'] ?? 0,
      buildingId: json['building_id'] ?? 0,
      name: json['name'] ?? '',
      floorNumber: json['floor_number'] ?? 0,
      mapImage: json['map_image'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'building_id': buildingId,
      'name': name,
      'floor_number': floorNumber,
      'map_image': mapImage,
      'is_active': isActive,
    };
  }

  FloorModel copyWith({
    int? id,
    int? buildingId,
    String? name,
    int? floorNumber,
    String? mapImage,
    bool? isActive,
  }) {
    return FloorModel(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      name: name ?? this.name,
      floorNumber: floorNumber ?? this.floorNumber,
      mapImage: mapImage ?? this.mapImage,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'FloorModel(id: $id, name: $name, floorNumber: $floorNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FloorModel &&
        other.id == id &&
        other.buildingId == buildingId &&
        other.name == name &&
        other.floorNumber == floorNumber &&
        other.mapImage == mapImage &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(id, buildingId, name, floorNumber, mapImage, isActive);
  }
}
