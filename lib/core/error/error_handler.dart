import 'package:dio/dio.dart';
import '../utils/app_logger.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  ErrorHandler._();

  static Failure handleException(dynamic exception, [StackTrace? stackTrace]) {
    AppLogger.e('Exception captured in ErrorHandler: $exception', exception, stackTrace);

    if (exception is AppException) {
      return switch (exception) {
        ServerException e => ServerFailure(e.message, e.statusCode),
        NetworkException e => NetworkFailure(e.message),
        CacheException e => CacheFailure(e.message),
        SecureStorageException e => SecureStorageFailure(e.message),
        UnauthorizedException e => UnauthorizedFailure(e.message, e.statusCode),
        NotFoundException e => NotFoundFailure(e.message, e.statusCode),
        ValidationException e => ValidationFailure(e.message, e.statusCode),
        AIException e => AIFailure(e.message),
        _ => UnexpectedFailure(exception.message),
      };
    }

    if (exception is DioException) {
      return switch (exception.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError =>
          const NetworkFailure('Unable to connect right now. Check your internet connection and try again.'),
        DioExceptionType.badResponse => ServerFailure(
            exception.response?.statusMessage ?? 'Unable to complete request. Please try again.',
            exception.response?.statusCode,
          ),
        DioExceptionType.cancel => const UnexpectedFailure('Request was cancelled'),
        _ => const NetworkFailure('Unable to connect right now. Check your internet connection and try again.'),
      };
    }

    final errStr = exception?.toString() ?? '';
    if (errStr.contains('SocketException') ||
        errStr.contains('Failed host lookup') ||
        errStr.contains('ClientException') ||
        errStr.contains('NetworkException') ||
        errStr.contains('TimeoutException') ||
        errStr.contains('Connection refused') ||
        errStr.contains('HandshakeException')) {
      return const NetworkFailure('Unable to connect right now. Check your internet connection and try again.');
    }

    if (errStr.contains('PostgrestException') ||
        errStr.contains('StorageException') ||
        errStr.contains('supabase') ||
        errStr.contains('postgres') ||
        errStr.contains('http://') ||
        errStr.contains('https://')) {
      return const ServerFailure('Unable to load data right now. Please try again shortly.', 500);
    }

    if (exception is Exception) {
      final msg = exception.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
      if (msg.isNotEmpty && !msg.startsWith('Instance of')) {
        return UnexpectedFailure(msg);
      }
    }

    return const UnexpectedFailure('An unexpected error occurred. Please try again.');
  }
}
