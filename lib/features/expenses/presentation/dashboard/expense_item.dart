import '../../domain/entities/expense_entity.dart';

/// UI view-model adapter for [ExpenseEntity] and its split summary.
class ExpenseItem {
  final ExpenseEntity expense;

  const ExpenseItem({required this.expense});
}
