import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpenses implements UseCase<List<ExpenseEntity>, NoParams> {
  final ExpenseRepository repository;

  const GetExpenses(this.repository);

  @override
  Future<Either<Failure, List<ExpenseEntity>>> call(NoParams params) {
    return repository.getExpenses();
  }
}
