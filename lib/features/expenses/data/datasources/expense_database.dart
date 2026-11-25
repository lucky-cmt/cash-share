import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense_model.dart';
import '../models/expense_split_model.dart';
import 'expense_local_data_source.dart';

/// Canonical Hive table names for offline-first expense storage.
class ExpenseDatabaseSchema {
  ExpenseDatabaseSchema._();

  static const String expensesBox = 'expenses_table';
  static const String expenseSplitsBox = 'expense_splits_table';
}

/// Abstract local database contract for expenses and splits.
abstract class PersistentExpenseDatabase implements ExpenseLocalDataSource {
  Future<void> init();
  Future<List<ExpenseModel>> getUnsyncedExpenses();
  Future<List<ExpenseSplitModel>> getUnsyncedExpenseSplits();
  Future<void> markExpenseSynced(String id);
  Future<void> markExpenseSplitSynced(String id);
  Future<void> updateSplitExpenseId(String oldExpenseId, String newExpenseId);
  Future<void> deleteExpense(String id);
}

/// Hive-backed implementation of [PersistentExpenseDatabase].
class PersistentExpenseDatabaseImpl implements PersistentExpenseDatabase {
  Box<Map>? _expensesBox;
  Box<Map>? _splitsBox;

  @override
  Future<void> init() async {
    _expensesBox ??= await Hive.openBox<Map>(ExpenseDatabaseSchema.expensesBox);
    _splitsBox ??=
        await Hive.openBox<Map>(ExpenseDatabaseSchema.expenseSplitsBox);
  }

  Box<Map> get _expenses {
    final box = _expensesBox;
    if (box == null) {
      throw StateError('Expenses Hive box has not been initialized.');
    }
    return box;
  }

  Box<Map> get _splits {
    final box = _splitsBox;
    if (box == null) {
      throw StateError('Expense splits Hive box has not been initialized.');
    }
    return box;
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    return _expenses.values
        .map((raw) => ExpenseModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((e) => !e.archived)
        .toList();
  }

  @override
  Future<ExpenseModel> saveExpense(ExpenseModel expense) async {
    await _expenses.put(expense.id, expense.toJson());
    return expense;
  }

  @override
  Future<List<ExpenseSplitModel>> getExpenseSplits(String expenseId) async {
    return _splits.values
        .map(
          (raw) => ExpenseSplitModel.fromJson(Map<String, dynamic>.from(raw)),
        )
        .where((s) => s.expenseId == expenseId)
        .toList();
  }

  @override
  Future<ExpenseSplitModel> saveExpenseSplit(ExpenseSplitModel split) async {
    await _splits.put(split.id, split.toJson());
    return split;
  }

  @override
  Future<List<ExpenseModel>> getUnsyncedExpenses() async {
    return _expenses.values
        .map((raw) => ExpenseModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((e) => e.isDirty == 1 && !e.archived)
        .toList();
  }

  @override
  Future<List<ExpenseSplitModel>> getUnsyncedExpenseSplits() async {
    return _splits.values
        .map(
          (raw) => ExpenseSplitModel.fromJson(Map<String, dynamic>.from(raw)),
        )
        .where((s) => s.isDirty == 1)
        .toList();
  }

  @override
  Future<void> markExpenseSynced(String id) async {
    final raw = _expenses.get(id);
    if (raw == null) return;
    final model = ExpenseModel.fromJson(Map<String, dynamic>.from(raw));
    await _expenses.put(
      id,
      ExpenseModel.fromEntity(model, isDirty: 0).toJson(),
    );
  }

  @override
  Future<void> markExpenseSplitSynced(String id) async {
    final raw = _splits.get(id);
    if (raw == null) return;
    final model = ExpenseSplitModel.fromJson(Map<String, dynamic>.from(raw));
    await _splits.put(
      id,
      ExpenseSplitModel.fromEntity(model, isDirty: 0).toJson(),
    );
  }

  @override
  Future<void> updateSplitExpenseId(
    String oldExpenseId,
    String newExpenseId,
  ) async {
    final matching = _splits.values
        .map(
          (raw) => ExpenseSplitModel.fromJson(Map<String, dynamic>.from(raw)),
        )
        .where((s) => s.expenseId == oldExpenseId)
        .toList();

    for (final split in matching) {
      final updated = ExpenseSplitModel(
        id: split.id,
        expenseId: newExpenseId,
        userId: split.userId,
        shareAmount: split.shareAmount,
        isSettled: split.isSettled,
        updatedAt: split.updatedAt,
        isDirty: split.isDirty,
      );
      await _splits.put(updated.id, updated.toJson());
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _expenses.delete(id);
  }
}
