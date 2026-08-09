import 'package:dio/dio.dart';

class NetworkExceptions {
  NetworkExceptions._();

  static String getMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "Connection timeout.";

        case DioExceptionType.sendTimeout:
          return "Request timeout.";

        case DioExceptionType.receiveTimeout:
          return "Server response timeout.";

        case DioExceptionType.connectionError:
          return "Unable to connect to the server.";

        case DioExceptionType.badCertificate:
          return "Invalid server certificate.";

        case DioExceptionType.cancel:
          return "Request cancelled.";

        case DioExceptionType.badResponse:
          return _handleStatusCode(
            error.response?.statusCode,
            error.response?.data,
          );

        case DioExceptionType.transformTimeout:
          return "Data transformation timeout.";

        case DioExceptionType.unknown:
          return "Unexpected network error.";
      }
    }

    return "Something went wrong.";
  }

  static String _handleStatusCode(int? statusCode, dynamic data) {
    switch (statusCode) {
      case 400:
        return data?["detail"]?.toString() ?? "Bad request.";

      case 401:
        return "Unauthorized.";

      case 403:
        return "Access denied.";

      case 404:
        return "Resource not found.";

      case 409:
        return "Conflict occurred.";

      case 500:
        return "Internal server error.";

      default:
        return "Unexpected server error.";
    }
  }
}
