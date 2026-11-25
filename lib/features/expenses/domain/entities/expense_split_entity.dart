import 'package:equatable/equatable.dart';

/// Pure domain representation of an individual friend's share/split of an expense.
class ExpenseSplitEntity extends Equatable {
  final String id;
  final String expenseId;
  final String userId;
  final double shareAmount;
  final bool isSettled;
  final DateTime updatedAt;

  const ExpenseSplitEntity({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.shareAmount,
    this.isSettled = false,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        expenseId,
        userId,
        shareAmount,
        isSettled,
        updatedAt,
      ];
}
