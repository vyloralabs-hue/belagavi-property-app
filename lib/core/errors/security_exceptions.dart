import '../error/exceptions.dart';

/// Security Exception thrown when a user attempts an unauthorized operation
class AccessDeniedException extends AppException {
  final String? code;

  const AccessDeniedException(String message, {this.code}) : super(message, 403);

  @override
  String toString() => 'AccessDeniedException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when protected data is accessed without a valid property unlock
class ProtectedDataLockedException implements Exception {
  final String message;
  final String propertyId;

  const ProtectedDataLockedException({
    this.message = 'Protected property data requires a valid property unlock.',
    required this.propertyId,
  });

  @override
  String toString() => 'ProtectedDataLockedException: $message (Property: $propertyId)';
}
