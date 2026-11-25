import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/expense_repository.dart';

class SyncExpenses implements UseCase<void, NoParams> {
  final ExpenseRepository repository;

  const SyncExpenses(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.syncExpenses();
  }
}
