import 'dart:async';

import 'package:cash_distro/core/network/network_info.dart';
import 'package:cash_distro/features/expenses/data/datasources/expense_database.dart';
import 'package:cash_distro/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:cash_distro/features/expenses/data/sync/sync_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPersistentExpenseDatabase extends Mock
    implements PersistentExpenseDatabase {}

class MockExpenseRemoteDataSource extends Mock
    implements ExpenseRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockPersistentExpenseDatabase mockDb;
  late MockExpenseRemoteDataSource mockRemote;
  late MockNetworkInfo mockNetworkInfo;
  late StreamController<bool> connectivityController;
  late SyncCoordinator coordinator;

  setUp(() {
    mockDb = MockPersistentExpenseDatabase();
    mockRemote = MockExpenseRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    connectivityController = StreamController<bool>.broadcast();

    when(() => mockNetworkInfo.onConnectivityChanged)
        .thenAnswer((_) => connectivityController.stream);

    coordinator = SyncCoordinator(
      localDatabase: mockDb,
      remoteDataSource: mockRemote,
      networkInfo: mockNetworkInfo,
    );
  });

  tearDown(() async {
    await coordinator.dispose();
    await connectivityController.close();
  });

  test('syncPending queries unsynced expenses and splits', () async {
    when(() => mockDb.getUnsyncedExpenses()).thenAnswer((_) async => []);
    when(() => mockDb.getUnsyncedExpenseSplits()).thenAnswer((_) async => []);

    final result = await coordinator.syncPending();

    expect(result.hasError, isFalse);
    expect(result.syncedExpenses, 0);
    expect(result.syncedSplits, 0);
    verify(() => mockDb.getUnsyncedExpenses()).called(1);
    verify(() => mockDb.getUnsyncedExpenseSplits()).called(1);
  });
}
