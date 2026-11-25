import 'package:equatable/equatable.dart';

/// Domain-layer failure contract returned via `Either<Failure, T>`.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server failure occurred.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure occurred.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection unavailable.']);
}
