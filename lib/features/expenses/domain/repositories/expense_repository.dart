import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';
import '../entities/expense_split_entity.dart';

/// Abstract repository contract for offline-first shared expenses.
abstract class ExpenseRepository {
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses();
  Future<Either<Failure, ExpenseEntity>> addExpense(ExpenseEntity expense);
  Future<Either<Failure, List<ExpenseSplitEntity>>> getExpenseSplits(
    String expenseId,
  );
  Future<Either<Failure, ExpenseSplitEntity>> recordExpenseSplit(
    ExpenseSplitEntity split,
  );
  Future<Either<Failure, void>> syncExpenses();
}
