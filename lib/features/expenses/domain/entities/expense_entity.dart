import 'package:equatable/equatable.dart';

/// Pure domain representation of a shared expense between friends.
class ExpenseEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String paidByUserId;
  final String? groupId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;

  const ExpenseEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidByUserId,
    this.groupId,
    required this.createdAt,
    required this.updatedAt,
    this.archived = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        paidByUserId,
        groupId,
        createdAt,
        updatedAt,
        archived,
      ];
}
