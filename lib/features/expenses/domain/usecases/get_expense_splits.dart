import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/expense_split_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpenseSplits implements UseCase<List<ExpenseSplitEntity>, String> {
  final ExpenseRepository repository;

  const GetExpenseSplits(this.repository);

  @override
  Future<Either<Failure, List<ExpenseSplitEntity>>> call(String expenseId) {
    return repository.getExpenseSplits(expenseId);
  }
}
