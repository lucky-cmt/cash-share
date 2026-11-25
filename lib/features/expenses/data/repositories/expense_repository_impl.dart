import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_split_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../datasources/expense_remote_data_source.dart';
import '../models/expense_model.dart';
import '../models/expense_split_model.dart';
import '../sync/sync_coordinator.dart';

/// Offline-first repository implementation with dirty tracking and sync fallback.
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final ExpenseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SyncCoordinator syncCoordinator;

  const ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.syncCoordinator,
  });

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses() async {
    try {
      final local = await localDataSource.getExpenses();
      return Right(local.map((e) => e.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> addExpense(
    ExpenseEntity expense,
  ) async {
    try {
      final model = ExpenseModel.fromEntity(expense, isDirty: 1);
      final saved = await localDataSource.saveExpense(model);
      if (await networkInfo.isConnected) {
        // Trigger background sync without blocking immediate local return.
        await syncCoordinator.syncPending();
      }
      return Right(saved.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseSplitEntity>>> getExpenseSplits(
    String expenseId,
  ) async {
    try {
      final splits = await localDataSource.getExpenseSplits(expenseId);
      return Right(splits.map((s) => s.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseSplitEntity>> recordExpenseSplit(
    ExpenseSplitEntity split,
  ) async {
    try {
      final model = ExpenseSplitModel.fromEntity(split, isDirty: 1);
      final saved = await localDataSource.saveExpenseSplit(model);
      if (await networkInfo.isConnected) {
        await syncCoordinator.syncPending();
      }
      return Right(saved.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncExpenses() async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }
      await syncCoordinator.syncPending();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
