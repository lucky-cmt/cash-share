import '../../domain/entities/expense_entity.dart';

/// Data model for [ExpenseEntity] with JSON/Hive map serialization.
class ExpenseModel extends ExpenseEntity {
  final int isDirty;

  const ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.paidByUserId,
    super.groupId,
    required super.createdAt,
    required super.updatedAt,
    super.archived = false,
    this.isDirty = 0,
  });

  factory ExpenseModel.fromEntity(ExpenseEntity entity, {int isDirty = 0}) {
    return ExpenseModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      paidByUserId: entity.paidByUserId,
      groupId: entity.groupId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      archived: entity.archived,
      isDirty: isDirty,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidByUserId: json['paid_by_user_id'] as String,
      groupId: json['group_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      archived: (json['archived'] as int? ?? 0) == 1 ||
          (json['archived'] as bool? ?? false),
      isDirty: json['is_dirty'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson({bool includeSyncFields = true}) {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'amount': amount,
      'paid_by_user_id': paidByUserId,
      'group_id': groupId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'archived': archived ? 1 : 0,
    };
    if (includeSyncFields) {
      map['is_dirty'] = isDirty;
    }
    return map;
  }

  ExpenseEntity toEntity() => ExpenseEntity(
        id: id,
        title: title,
        amount: amount,
        paidByUserId: paidByUserId,
        groupId: groupId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        archived: archived,
      );
}
