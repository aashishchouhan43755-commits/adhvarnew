import 'pagination_model.dart';

class BaseResponseModel<T> {
  final bool success;
  final String message;
  final T? data;
  final PaginationModel? pagination;

  const BaseResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.pagination,
  });

  factory BaseResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return BaseResponseModel<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T value) toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
      'pagination': pagination?.toJson(),
    };
  }

  BaseResponseModel<T> copyWith({
    bool? success,
    String? message,
    T? data,
    PaginationModel? pagination,
  }) {
    return BaseResponseModel<T>(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
      pagination: pagination ?? this.pagination,
    );
  }

  @override
  String toString() {
    return 'BaseResponseModel('
        'success: $success, '
        'message: $message, '
        'data: $data'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BaseResponseModel<T> &&
        other.success == success &&
        other.message == message &&
        other.data == data &&
        other.pagination == pagination;
  }

  @override
  int get hashCode {
    return Object.hash(success, message, data, pagination);
  }
}
