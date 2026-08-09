class RoomModel {
  final int id;
  final int buildingId;
  final int floorId;
  final String roomNumber;
  final String roomName;
  final String roomType;
  final String description;
  final double xCoordinate;
  final double yCoordinate;
  final bool isAvailable;

  const RoomModel({
    required this.id,
    required this.buildingId,
    required this.floorId,
    required this.roomNumber,
    required this.roomName,
    required this.roomType,
    required this.description,
    required this.xCoordinate,
    required this.yCoordinate,
    this.isAvailable = true,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      buildingId: json['building_id'] ?? 0,
      floorId: json['floor_id'] ?? 0,
      roomNumber: json['room_number'] ?? '',
      roomName: json['room_name'] ?? '',
      roomType: json['room_type'] ?? '',
      description: json['description'] ?? '',
      xCoordinate: (json['x_coordinate'] ?? 0).toDouble(),
      yCoordinate: (json['y_coordinate'] ?? 0).toDouble(),
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'building_id': buildingId,
      'floor_id': floorId,
      'room_number': roomNumber,
      'room_name': roomName,
      'room_type': roomType,
      'description': description,
      'x_coordinate': xCoordinate,
      'y_coordinate': yCoordinate,
      'is_available': isAvailable,
    };
  }

  RoomModel copyWith({
    int? id,
    int? buildingId,
    int? floorId,
    String? roomNumber,
    String? roomName,
    String? roomType,
    String? description,
    double? xCoordinate,
    double? yCoordinate,
    bool? isAvailable,
  }) {
    return RoomModel(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      floorId: floorId ?? this.floorId,
      roomNumber: roomNumber ?? this.roomNumber,
      roomName: roomName ?? this.roomName,
      roomType: roomType ?? this.roomType,
      description: description ?? this.description,
      xCoordinate: xCoordinate ?? this.xCoordinate,
      yCoordinate: yCoordinate ?? this.yCoordinate,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  String toString() {
    return 'RoomModel(id: $id, roomNumber: $roomNumber, roomName: $roomName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RoomModel &&
        other.id == id &&
        other.buildingId == buildingId &&
        other.floorId == floorId &&
        other.roomNumber == roomNumber &&
        other.roomName == roomName &&
        other.roomType == roomType &&
        other.description == description &&
        other.xCoordinate == xCoordinate &&
        other.yCoordinate == yCoordinate &&
        other.isAvailable == isAvailable;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      buildingId,
      floorId,
      roomNumber,
      roomName,
      roomType,
      description,
      xCoordinate,
      yCoordinate,
      isAvailable,
    );
  }
}
