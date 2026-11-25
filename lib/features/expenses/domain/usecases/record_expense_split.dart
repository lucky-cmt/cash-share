import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/expense_split_entity.dart';
import '../repositories/expense_repository.dart';

class RecordExpenseSplit
    implements UseCase<ExpenseSplitEntity, ExpenseSplitEntity> {
  final ExpenseRepository repository;

  const RecordExpenseSplit(this.repository);

  @override
  Future<Either<Failure, ExpenseSplitEntity>> call(ExpenseSplitEntity params) {
    return repository.recordExpenseSplit(params);
  }
}
