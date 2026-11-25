import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class AddExpense implements UseCase<ExpenseEntity, ExpenseEntity> {
  final ExpenseRepository repository;

  const AddExpense(this.repository);

  @override
  Future<Either<Failure, ExpenseEntity>> call(ExpenseEntity params) {
    return repository.addExpense(params);
  }
}
