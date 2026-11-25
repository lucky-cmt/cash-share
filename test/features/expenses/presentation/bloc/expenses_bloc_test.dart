import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cash_distro/core/usecases/usecase.dart';
import 'package:cash_distro/features/expenses/data/sync/sync_coordinator.dart';
import 'package:cash_distro/features/expenses/domain/entities/expense_entity.dart';
import 'package:cash_distro/features/expenses/domain/usecases/add_expense.dart';
import 'package:cash_distro/features/expenses/domain/usecases/get_expenses.dart';
import 'package:cash_distro/features/expenses/domain/usecases/record_expense_split.dart';
import 'package:cash_distro/features/expenses/domain/usecases/sync_expenses.dart';
import 'package:cash_distro/features/expenses/presentation/bloc/expenses_bloc.dart';
import 'package:cash_distro/features/expenses/presentation/bloc/expenses_event.dart';
import 'package:cash_distro/features/expenses/presentation/bloc/expenses_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetExpenses extends Mock implements GetExpenses {}

class MockAddExpense extends Mock implements AddExpense {}

class MockRecordExpenseSplit extends Mock implements RecordExpenseSplit {}

class MockSyncExpenses extends Mock implements SyncExpenses {}

class MockSyncCoordinator extends Mock implements SyncCoordinator {}

void main() {
  late MockGetExpenses mockGetExpenses;
  late MockAddExpense mockAddExpense;
  late MockRecordExpenseSplit mockRecordExpenseSplit;
  late MockSyncExpenses mockSyncExpenses;
  late MockSyncCoordinator mockSyncCoordinator;
  late StreamController<SyncResult> syncController;

  final testExpense = ExpenseEntity(
    id: 'exp-1',
    title: 'Dinner',
    amount: 48.50,
    paidByUserId: 'user-1',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockGetExpenses = MockGetExpenses();
    mockAddExpense = MockAddExpense();
    mockRecordExpenseSplit = MockRecordExpenseSplit();
    mockSyncExpenses = MockSyncExpenses();
    mockSyncCoordinator = MockSyncCoordinator();
    syncController = StreamController<SyncResult>.broadcast();

    when(() => mockSyncCoordinator.onSyncCompleted)
        .thenAnswer((_) => syncController.stream);
  });

  tearDown(() async {
    await syncController.close();
  });

  blocTest<ExpensesBloc, ExpensesState>(
    'emits [ExpensesLoading, ExpensesLoaded] on LoadExpensesRequested',
    build: () {
      when(() => mockGetExpenses(any()))
          .thenAnswer((_) async => Right([testExpense]));
      return ExpensesBloc(
        getExpenses: mockGetExpenses,
        addExpense: mockAddExpense,
        recordExpenseSplit: mockRecordExpenseSplit,
        syncExpenses: mockSyncExpenses,
        syncCoordinator: mockSyncCoordinator,
        syncInterval: Duration.zero,
      );
    },
    act: (bloc) => bloc.add(const LoadExpensesRequested()),
    expect: () => [
      const ExpensesLoading(),
      ExpensesLoaded([testExpense]),
    ],
  );
}
