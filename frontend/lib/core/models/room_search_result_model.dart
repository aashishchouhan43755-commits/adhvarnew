class RoomSearchResultModel {
  final int id;
  final String roomNumber;
  final String roomName;
  final String roomType;

  final int floorId;
  final int floorNumber;
  final String floorName;

  final int buildingId;
  final String buildingName;

  final int? nodeId;
  final double? x;
  final double? y;

  const RoomSearchResultModel({
    required this.id,
    required this.roomNumber,
    required this.roomName,
    required this.roomType,
    required this.floorId,
    required this.floorNumber,
    required this.floorName,
    required this.buildingId,
    required this.buildingName,
    this.nodeId,
    this.x,
    this.y,
  });

  factory RoomSearchResultModel.fromJson(Map<String, dynamic> json) {
    return RoomSearchResultModel(
      id: json['id'] ?? 0,
      roomNumber: json['room_number'] ?? '',
      roomName: json['room_name'] ?? '',
      roomType: json['room_type'] ?? '',
      floorId: json['floor_id'] ?? 0,
      floorNumber: json['floor_number'] ?? 0,
      floorName: json['floor_name'] ?? '',
      buildingId: json['building_id'] ?? 0,
      buildingName: json['building_name'] ?? '',
      nodeId: json['node_id'],
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_number': roomNumber,
      'room_name': roomName,
      'room_type': roomType,
      'floor_id': floorId,
      'floor_number': floorNumber,
      'floor_name': floorName,
      'building_id': buildingId,
      'building_name': buildingName,
      'node_id': nodeId,
      'x': x,
      'y': y,
    };
  }

  /// Encodes this room as `<prefix>Id`, `<prefix>RoomName`, etc. so it can
  /// be carried through a GoRouter query string (e.g. from search results
  /// straight into the indoor map, without a second API round trip).
  Map<String, String> toQueryParams({String prefix = 'dest'}) {
    return {
      '${prefix}Id': '$id',
      '${prefix}RoomNumber': roomNumber,
      '${prefix}RoomName': roomName,
      '${prefix}RoomType': roomType,
      '${prefix}FloorId': '$floorId',
      '${prefix}FloorNumber': '$floorNumber',
      '${prefix}FloorName': floorName,
      '${prefix}BuildingId': '$buildingId',
      '${prefix}BuildingName': buildingName,
      if (nodeId != null) '${prefix}NodeId': '$nodeId',
      if (x != null) '${prefix}X': '$x',
      if (y != null) '${prefix}Y': '$y',
    };
  }

  /// Reconstructs a room from query params written by [toQueryParams].
  /// Returns null if the required fields aren't present.
  static RoomSearchResultModel? fromQueryParams(
    Map<String, String> params, {
    String prefix = 'dest',
  }) {
    final idStr = params['${prefix}Id'];
    final nodeIdStr = params['${prefix}NodeId'];

    if (idStr == null || nodeIdStr == null) return null;

    return RoomSearchResultModel(
      id: int.tryParse(idStr) ?? 0,
      roomNumber: params['${prefix}RoomNumber'] ?? '',
      roomName: params['${prefix}RoomName'] ?? '',
      roomType: params['${prefix}RoomType'] ?? '',
      floorId: int.tryParse(params['${prefix}FloorId'] ?? '') ?? 0,
      floorNumber: int.tryParse(params['${prefix}FloorNumber'] ?? '') ?? 0,
      floorName: params['${prefix}FloorName'] ?? '',
      buildingId: int.tryParse(params['${prefix}BuildingId'] ?? '') ?? 0,
      buildingName: params['${prefix}BuildingName'] ?? '',
      nodeId: int.tryParse(nodeIdStr),
      x: double.tryParse(params['${prefix}X'] ?? ''),
      y: double.tryParse(params['${prefix}Y'] ?? ''),
    );
  }

  @override
  String toString() {
    return 'RoomSearchResultModel(id: $id, roomName: $roomName, buildingName: $buildingName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RoomSearchResultModel &&
        other.id == id &&
        other.roomNumber == roomNumber &&
        other.roomName == roomName &&
        other.roomType == roomType &&
        other.floorId == floorId &&
        other.floorNumber == floorNumber &&
        other.floorName == floorName &&
        other.buildingId == buildingId &&
        other.buildingName == buildingName &&
        other.nodeId == nodeId &&
        other.x == x &&
        other.y == y;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      roomNumber,
      roomName,
      roomType,
      floorId,
      floorNumber,
      floorName,
      buildingId,
      buildingName,
      nodeId,
      x,
      y,
    );
  }
}
