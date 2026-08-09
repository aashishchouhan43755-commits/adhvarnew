class ApiErrorModel {
  final int? statusCode;
  final String message;
  final String? error;
  final Map<String, dynamic>? details;

  const ApiErrorModel({
    this.statusCode,
    required this.message,
    this.error,
    this.details,
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      statusCode: json['status_code'] ?? json['status'],
      message: json['message']?.toString() ?? 'Something went wrong.',
      error: json['error']?.toString(),
      details: json['details'] is Map<String, dynamic>
          ? json['details'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'message': message,
      'error': error,
      'details': details,
    };
  }

  ApiErrorModel copyWith({
    int? statusCode,
    String? message,
    String? error,
    Map<String, dynamic>? details,
  }) {
    return ApiErrorModel(
      statusCode: statusCode ?? this.statusCode,
      message: message ?? this.message,
      error: error ?? this.error,
      details: details ?? this.details,
    );
  }

  @override
  String toString() {
    return 'ApiErrorModel(statusCode: $statusCode, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApiErrorModel &&
        other.statusCode == statusCode &&
        other.message == message &&
        other.error == error &&
        other.details == details;
  }

  @override
  int get hashCode {
    return Object.hash(statusCode, message, error, details);
  }
}
