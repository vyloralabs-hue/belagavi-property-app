/// Base application exception interface
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => '$runtimeType: $message (code: ${statusCode ?? 'N/A'})';
}

class ServerException extends AppException {
  const ServerException([super.message = 'A server error occurred', super.statusCode]);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection available']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Local cache read/write failed']);
}

class SecureStorageException extends AppException {
  const SecureStorageException([super.message = 'Secure storage operation failed']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized access', super.statusCode = 401]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Requested resource not found', super.statusCode = 404]);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed', super.statusCode = 400]);
}

class AIException extends AppException {
  const AIException([super.message = 'AI service interaction failed']);
}
