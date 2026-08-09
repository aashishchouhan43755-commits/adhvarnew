import '../../../../core/models/building_model.dart';

class BuildingResponseModel {
  final bool success;
  final String message;
  final List<BuildingModel> buildings;

  const BuildingResponseModel({
    required this.success,
    required this.message,
    required this.buildings,
  });

  factory BuildingResponseModel.fromJson(Map<String, dynamic> json) {
    return BuildingResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      buildings: (json['data'] as List<dynamic>? ?? [])
          .map((e) => BuildingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': buildings.map((building) => building.toJson()).toList(),
    };
  }

  BuildingResponseModel copyWith({
    bool? success,
    String? message,
    List<BuildingModel>? buildings,
  }) {
    return BuildingResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      buildings: buildings ?? this.buildings,
    );
  }

  @override
  String toString() {
    return 'BuildingResponseModel(success: $success, buildings: ${buildings.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BuildingResponseModel &&
        other.success == success &&
        other.message == message &&
        other.buildings == buildings;
  }

  @override
  int get hashCode {
    return Object.hash(success, message, buildings);
  }
}
