class BuildingModel {
  final int id;
  final String name;
  final String code;
  final String description;
  final String image;
  final int totalFloors;
  final double latitude;
  final double longitude;

  const BuildingModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.image,
    required this.totalFloors,
    required this.latitude,
    required this.longitude,
  });

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    return BuildingModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      totalFloors: json['total_floors'] ?? 0,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'image': image,
      'total_floors': totalFloors,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  BuildingModel copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    String? image,
    int? totalFloors,
    double? latitude,
    double? longitude,
  }) {
    return BuildingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      image: image ?? this.image,
      totalFloors: totalFloors ?? this.totalFloors,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'BuildingModel(id: $id, name: $name, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BuildingModel &&
        other.id == id &&
        other.name == name &&
        other.code == code &&
        other.description == description &&
        other.image == image &&
        other.totalFloors == totalFloors &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      code,
      description,
      image,
      totalFloors,
      latitude,
      longitude,
    );
  }
}
