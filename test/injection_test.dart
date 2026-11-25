import 'package:cash_distro/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:cash_distro/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cash_distro/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:cash_distro/features/expenses/presentation/bloc/expenses_bloc.dart';
import 'package:cash_distro/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockExpenseRemoteDataSource extends Mock
    implements ExpenseRemoteDataSource {}

void main() {
  setUp(() async {
    await sl.reset();
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => MockAuthRemoteDataSource(),
    );
    sl.registerLazySingleton<ExpenseRemoteDataSource>(
      () => MockExpenseRemoteDataSource(),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  test('parseEnvString parses key=value pairs and ignores comments', () {
    parseEnvString('''
# Comment line
SUPABASE_URL=https://example.supabase.co
SUPABASE_ANON_KEY=test-anon-key
''');

    expect(getEnv('SUPABASE_URL'), 'https://example.supabase.co');
    expect(getEnv('SUPABASE_ANON_KEY'), 'test-anon-key');
  });

  test('initInjection registers AuthBloc and ExpensesBloc as factories', () async {
    await initInjection(initializeExternalServices: false);

    final authBloc1 = sl<AuthBloc>();
    final authBloc2 = sl<AuthBloc>();
    expect(identical(authBloc1, authBloc2), isFalse);

    final expensesBloc1 = sl<ExpensesBloc>();
    final expensesBloc2 = sl<ExpensesBloc>();
    expect(identical(expensesBloc1, expensesBloc2), isFalse);

    await authBloc1.close();
    await authBloc2.close();
    await expensesBloc1.close();
    await expensesBloc2.close();
  });
}
