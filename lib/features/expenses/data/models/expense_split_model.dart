import '../../domain/entities/expense_split_entity.dart';

/// Data model for [ExpenseSplitEntity] with JSON/Hive map serialization.
class ExpenseSplitModel extends ExpenseSplitEntity {
  final int isDirty;

  const ExpenseSplitModel({
    required super.id,
    required super.expenseId,
    required super.userId,
    required super.shareAmount,
    super.isSettled = false,
    required super.updatedAt,
    this.isDirty = 0,
  });

  factory ExpenseSplitModel.fromEntity(
    ExpenseSplitEntity entity, {
    int isDirty = 0,
  }) {
    return ExpenseSplitModel(
      id: entity.id,
      expenseId: entity.expenseId,
      userId: entity.userId,
      shareAmount: entity.shareAmount,
      isSettled: entity.isSettled,
      updatedAt: entity.updatedAt,
      isDirty: isDirty,
    );
  }

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      id: json['id'] as String,
      expenseId: json['expense_id'] as String,
      userId: json['user_id'] as String,
      shareAmount: (json['share_amount'] as num).toDouble(),
      isSettled: (json['is_settled'] as int? ?? 0) == 1 ||
          (json['is_settled'] as bool? ?? false),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDirty: json['is_dirty'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson({bool includeSyncFields = true}) {
    final map = <String, dynamic>{
      'id': id,
      'expense_id': expenseId,
      'user_id': userId,
      'share_amount': shareAmount,
      'is_settled': isSettled ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
    if (includeSyncFields) {
      map['is_dirty'] = isDirty;
    }
    return map;
  }

  ExpenseSplitEntity toEntity() => ExpenseSplitEntity(
        id: id,
        expenseId: expenseId,
        userId: userId,
        shareAmount: shareAmount,
        isSettled: isSettled,
        updatedAt: updatedAt,
      );
}
