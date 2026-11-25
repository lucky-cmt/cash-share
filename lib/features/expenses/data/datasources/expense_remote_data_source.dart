import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/expense_model.dart';
import '../models/expense_split_model.dart';

/// Remote data source backed by Supabase Postgres tables.
abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> fetchExpenses();
  Future<List<ExpenseModel>> upsertExpenses(List<ExpenseModel> expenses);
  Future<List<ExpenseSplitModel>> upsertExpenseSplits(
    List<ExpenseSplitModel> splits,
  );
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final SupabaseClient supabaseClient;

  const ExpenseRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ExpenseModel>> fetchExpenses() async {
    // TODO: Query Supabase `expenses` table for the current user's groups.
    throw const ServerException('Remote fetchExpenses not yet implemented.');
  }

  @override
  Future<List<ExpenseModel>> upsertExpenses(List<ExpenseModel> expenses) async {
    // TODO: Batch upsert expenses to Supabase.
    throw const ServerException('Remote upsertExpenses not yet implemented.');
  }

  @override
  Future<List<ExpenseSplitModel>> upsertExpenseSplits(
    List<ExpenseSplitModel> splits,
  ) async {
    // TODO: Batch upsert expense splits to Supabase.
    throw const ServerException(
      'Remote upsertExpenseSplits not yet implemented.',
    );
  }
}
