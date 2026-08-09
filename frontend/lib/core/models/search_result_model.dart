class SearchResultModel {
  final int id;
  final int buildingId;
  final int floorId;
  final String title;
  final String subtitle;
  final String type;
  final String description;
  final double xCoordinate;
  final double yCoordinate;

  const SearchResultModel({
    required this.id,
    required this.buildingId,
    required this.floorId,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.description,
    required this.xCoordinate,
    required this.yCoordinate,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] ?? 0,
      buildingId: json['building_id'] ?? 0,
      floorId: json['floor_id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      xCoordinate: (json['x_coordinate'] ?? 0).toDouble(),
      yCoordinate: (json['y_coordinate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'building_id': buildingId,
      'floor_id': floorId,
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'description': description,
      'x_coordinate': xCoordinate,
      'y_coordinate': yCoordinate,
    };
  }

  SearchResultModel copyWith({
    int? id,
    int? buildingId,
    int? floorId,
    String? title,
    String? subtitle,
    String? type,
    String? description,
    double? xCoordinate,
    double? yCoordinate,
  }) {
    return SearchResultModel(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      floorId: floorId ?? this.floorId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      description: description ?? this.description,
      xCoordinate: xCoordinate ?? this.xCoordinate,
      yCoordinate: yCoordinate ?? this.yCoordinate,
    );
  }

  @override
  String toString() {
    return 'SearchResultModel(id: $id, title: $title, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchResultModel &&
        other.id == id &&
        other.buildingId == buildingId &&
        other.floorId == floorId &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.type == type &&
        other.description == description &&
        other.xCoordinate == xCoordinate &&
        other.yCoordinate == yCoordinate;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      buildingId,
      floorId,
      title,
      subtitle,
      type,
      description,
      xCoordinate,
      yCoordinate,
    );
  }
}
