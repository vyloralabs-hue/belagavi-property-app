import 'package:equatable/equatable.dart';
import 'typedefs.dart';

/// Clean Architecture UseCase contract
abstract class UseCase<T, Params> {
  FutureEither<T> call(Params params);
}

/// NoParams helper class for UseCases that require no arguments
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
