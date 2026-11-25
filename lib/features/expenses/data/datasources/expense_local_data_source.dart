import '../models/expense_model.dart';
import '../models/expense_split_model.dart';

/// Local read/write interface for offline-first expense persistence.
abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<ExpenseModel> saveExpense(ExpenseModel expense);
  Future<List<ExpenseSplitModel>> getExpenseSplits(String expenseId);
  Future<ExpenseSplitModel> saveExpenseSplit(ExpenseSplitModel split);
}
