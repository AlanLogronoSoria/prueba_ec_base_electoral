class ServerException implements Exception {
  final String message;
  final int? code;
  final String? type;
  const ServerException(this.message, {this.code, this.type});
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}

class PermissionException implements Exception {
  final String message;
  const PermissionException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
}
