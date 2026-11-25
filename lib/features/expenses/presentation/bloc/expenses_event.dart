import 'package:equatable/equatable.dart';

import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_split_entity.dart';

abstract class ExpensesEvent extends Equatable {
  const ExpensesEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpensesRequested extends ExpensesEvent {
  const LoadExpensesRequested();
}

class AddExpenseSubmitted extends ExpensesEvent {
  final ExpenseEntity expense;

  const AddExpenseSubmitted(this.expense);

  @override
  List<Object?> get props => [expense];
}

class RecordSplitSubmitted extends ExpensesEvent {
  final ExpenseSplitEntity split;

  const RecordSplitSubmitted(this.split);

  @override
  List<Object?> get props => [split];
}

class SyncExpensesRequested extends ExpensesEvent {
  const SyncExpensesRequested();
}
