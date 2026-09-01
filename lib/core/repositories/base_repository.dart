import 'package:fpdart/fpdart.dart';
import '../error/error_handler.dart';
import '../utils/typedefs.dart';

/// Base Repository class providing safe execution of remote/local data operations
abstract class BaseRepository {
  const BaseRepository();

  /// Wraps an asynchronous operation in a safe try-catch block returning [FutureEither<T>].
  FutureEither<T> safeCall<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Right(result);
    } catch (e, stackTrace) {
      final failure = ErrorHandler.handleException(e, stackTrace);
      return Left(failure);
    }
  }
}
