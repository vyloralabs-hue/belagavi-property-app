import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';

/// Type alias for Future operations returning Either Failure or Success T
typedef FutureEither<T> = Future<Either<Failure, T>>;

/// Type alias for synchronous operations returning Either Failure or Success T
typedef EitherResult<T> = Either<Failure, T>;

/// Type alias for JSON maps
typedef JsonMap = Map<String, dynamic>;
