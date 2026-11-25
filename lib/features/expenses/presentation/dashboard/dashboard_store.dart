import 'package:flutter/foundation.dart';

import '../../../../core/sound/sound_service.dart';
import '../../domain/entities/expense_entity.dart';
import 'expense_item.dart';

/// ChangeNotifier for optimistic UI updates, filtering, and sound triggers.
class DashboardStore extends ChangeNotifier {
  final SoundService soundService;
  List<ExpenseItem> _items = const [];

  DashboardStore({required this.soundService});

  List<ExpenseItem> get items => _items;

  void setExpenses(List<ExpenseEntity> expenses) {
    _items = expenses.map((e) => ExpenseItem(expense: e)).toList();
    notifyListeners();
  }
}
