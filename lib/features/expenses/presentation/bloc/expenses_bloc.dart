import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../data/sync/sync_coordinator.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/record_expense_split.dart';
import '../../domain/usecases/sync_expenses.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final GetExpenses getExpenses;
  final AddExpense addExpense;
  final RecordExpenseSplit recordExpenseSplit;
  final SyncExpenses syncExpenses;
  final SyncCoordinator syncCoordinator;

  Timer? _syncTimer;
  StreamSubscription<SyncResult>? _syncSub;

  ExpensesBloc({
    required this.getExpenses,
    required this.addExpense,
    required this.recordExpenseSplit,
    required this.syncExpenses,
    required this.syncCoordinator,
    Duration syncInterval = const Duration(seconds: 15),
  }) : super(const ExpensesInitial()) {
    on<LoadExpensesRequested>(_onLoadExpensesRequested);
    on<AddExpenseSubmitted>(_onAddExpenseSubmitted);
    on<RecordSplitSubmitted>(_onRecordSplitSubmitted);
    on<SyncExpensesRequested>(_onSyncExpensesRequested);

    _syncSub = syncCoordinator.onSyncCompleted.listen((result) {
      if (!result.hasError) {
        add(const LoadExpensesRequested());
      }
    });

    if (syncInterval > Duration.zero) {
      _syncTimer = Timer.periodic(syncInterval, (_) {
        add(const SyncExpensesRequested());
      });
    }
  }

  Future<void> _onLoadExpensesRequested(
    LoadExpensesRequested event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(const ExpensesLoading());
    final result = await getExpenses(const NoParams());
    result.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (expenses) => emit(ExpensesLoaded(expenses)),
    );
  }

  Future<void> _onAddExpenseSubmitted(
    AddExpenseSubmitted event,
    Emitter<ExpensesState> emit,
  ) async {
    final result = await addExpense(event.expense);
    await result.fold(
      (failure) async => emit(ExpensesError(failure.message)),
      (_) async => add(const LoadExpensesRequested()),
    );
  }

  Future<void> _onRecordSplitSubmitted(
    RecordSplitSubmitted event,
    Emitter<ExpensesState> emit,
  ) async {
    final result = await recordExpenseSplit(event.split);
    result.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (_) => add(const LoadExpensesRequested()),
    );
  }

  Future<void> _onSyncExpensesRequested(
    SyncExpensesRequested event,
    Emitter<ExpensesState> emit,
  ) async {
    await syncExpenses(const NoParams());
  }

  @override
  Future<void> close() async {
    _syncTimer?.cancel();
    await _syncSub?.cancel();
    return super.close();
  }
}
