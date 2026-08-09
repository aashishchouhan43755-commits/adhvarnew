class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() {
    if (code != null) {
      return "AppException($code): $message";
    }
    return "AppException: $message";
  }
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = "No Internet Connection",
    super.code = "NETWORK_ERROR",
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message = "Server Error",
    super.code = "SERVER_ERROR",
  });
}

class AuthenticationException extends AppException {
  const AuthenticationException({
    super.message = "Authentication Failed",
    super.code = "AUTH_ERROR",
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = "VALIDATION_ERROR",
  });
}

class CacheException extends AppException {
  const CacheException({
    super.message = "Cache Error",
    super.code = "CACHE_ERROR",
  });
}

class UnknownException extends AppException {
  const UnknownException({
    super.message = "Something went wrong",
    super.code = "UNKNOWN_ERROR",
  });
}
