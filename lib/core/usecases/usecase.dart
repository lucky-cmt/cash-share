import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

/// Base contract for all domain use cases.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Marker parameter class for use cases that take no arguments.
class NoParams {
  const NoParams();
}
