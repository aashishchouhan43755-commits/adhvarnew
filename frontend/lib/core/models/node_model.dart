class NodeModel {
  final int id;
  final int floorId;
  final int? roomId;
  final String name;
  final double x;
  final double y;
  final String nodeType;

  const NodeModel({
    required this.id,
    required this.floorId,
    this.roomId,
    required this.name,
    required this.x,
    required this.y,
    required this.nodeType,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['id'] ?? 0,
      floorId: json['floor_id'] ?? 0,
      roomId: json['room_id'],
      name: json['name'] ?? '',
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      nodeType: json['node_type'] ?? 'corridor',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floor_id': floorId,
      'room_id': roomId,
      'name': name,
      'x': x,
      'y': y,
      'node_type': nodeType,
    };
  }

  @override
  String toString() => 'NodeModel(id: $id, name: $name, type: $nodeType)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NodeModel &&
        other.id == id &&
        other.floorId == floorId &&
        other.roomId == roomId &&
        other.name == name &&
        other.x == x &&
        other.y == y &&
        other.nodeType == nodeType;
  }

  @override
  int get hashCode => Object.hash(id, floorId, roomId, name, x, y, nodeType);
}
