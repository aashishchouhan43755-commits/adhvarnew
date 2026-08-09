import '../../../../core/models/floor_model.dart';

class FloorResponseModel {
  final bool success;
  final String message;
  final List<FloorModel> floors;

  const FloorResponseModel({
    required this.success,
    required this.message,
    required this.floors,
  });

  factory FloorResponseModel.fromJson(Map<String, dynamic> json) {
    return FloorResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      floors: (json['data'] as List<dynamic>? ?? [])
          .map((e) => FloorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': floors.map((floor) => floor.toJson()).toList(),
    };
  }

  FloorResponseModel copyWith({
    bool? success,
    String? message,
    List<FloorModel>? floors,
  }) {
    return FloorResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      floors: floors ?? this.floors,
    );
  }

  @override
  String toString() {
    return 'FloorResponseModel(success: $success, floors: ${floors.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FloorResponseModel &&
        other.success == success &&
        other.message == message &&
        other.floors == floors;
  }

  @override
  int get hashCode {
    return Object.hash(success, message, floors);
  }
}
