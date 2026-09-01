import 'package:equatable/equatable.dart';

/// Clean Architecture Failure hierarchy for domain / presentation layer.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred', super.statusCode]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection unavailable']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache error occurred']);
}

class SecureStorageFailure extends Failure {
  const SecureStorageFailure([super.message = 'Secure storage error occurred']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access', super.statusCode = 401]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found', super.statusCode = 404]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid data provided', super.statusCode = 400]);
}

class AIFailure extends Failure {
  const AIFailure([super.message = 'AI service failure']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}
