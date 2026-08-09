abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = "Server Failure"]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = "No Internet Connection"]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = "Cache Failure"]);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = "Authentication Failed"]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = "Validation Failed"]);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = "Permission Denied"]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = "Resource Not Found"]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = "Something went wrong"]);
}
