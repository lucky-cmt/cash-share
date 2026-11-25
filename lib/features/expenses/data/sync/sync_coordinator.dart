import 'dart:async';

import '../../../../core/network/network_info.dart';
import '../datasources/expense_database.dart';
import '../datasources/expense_remote_data_source.dart';

/// Result emitted after a sync pass completes.
class SyncResult {
  final int syncedExpenses;
  final int syncedSplits;
  final Object? error;

  const SyncResult({
    this.syncedExpenses = 0,
    this.syncedSplits = 0,
    this.error,
  });

  bool get hasError => error != null;
}

/// Connectivity-driven batch sync engine (`is_dirty` -> Supabase).
class SyncCoordinator {
  final PersistentExpenseDatabase localDatabase;
  final ExpenseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  final StreamController<SyncResult> _syncController =
      StreamController<SyncResult>.broadcast();
  StreamSubscription<bool>? _connectivitySub;
  bool _isSyncing = false;

  SyncCoordinator({
    required this.localDatabase,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Stream<SyncResult> get onSyncCompleted => _syncController.stream;

  void startListening() {
    _connectivitySub ??= networkInfo.onConnectivityChanged.listen((online) {
      if (online) {
        syncPending();
      }
    });
  }

  Future<SyncResult> syncPending() async {
    if (_isSyncing) return const SyncResult();
    _isSyncing = true;
    try {
      final unsyncedExpenses = await localDatabase.getUnsyncedExpenses();
      final unsyncedSplits = await localDatabase.getUnsyncedExpenseSplits();

      // TODO: Batch upsert unsyncedExpenses and unsyncedSplits via remoteDataSource,
      // re-bind temporary local IDs via updateSplitExpenseId, and clear is_dirty.
      final result = SyncResult(
        syncedExpenses: unsyncedExpenses.length,
        syncedSplits: unsyncedSplits.length,
      );
      _syncController.add(result);
      return result;
    } catch (e) {
      final result = SyncResult(error: e);
      _syncController.add(result);
      return result;
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    await _syncController.close();
  }
}
