import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/network/network_info.dart';
import 'core/notifications/notification_action_handler.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/push_token_service.dart';
import 'core/sound/sound_service.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/delete_account.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/expenses/data/datasources/expense_database.dart';
import 'features/expenses/data/datasources/expense_local_data_source.dart';
import 'features/expenses/data/datasources/expense_remote_data_source.dart';
import 'features/expenses/data/repositories/expense_repository_impl.dart';
import 'features/expenses/data/sync/sync_coordinator.dart';
import 'features/expenses/domain/repositories/expense_repository.dart';
import 'features/expenses/domain/usecases/add_expense.dart';
import 'features/expenses/domain/usecases/get_expense_splits.dart';
import 'features/expenses/domain/usecases/get_expenses.dart';
import 'features/expenses/domain/usecases/record_expense_split.dart';
import 'features/expenses/domain/usecases/sync_expenses.dart';
import 'features/expenses/presentation/bloc/expenses_bloc.dart';

final GetIt sl = GetIt.instance;

final Map<String, String> _env = {};

/// Retrieves an environment variable from `flutter_dotenv` or the fallback map.
String getEnv(String key, {String fallback = ''}) {
  var value = _env[key];
  if ((value == null || value.isEmpty) && dotenv.isInitialized) {
    value = dotenv.maybeGet(key);
  }
  if (value == null) return fallback;
  var trimmed = value.trim();
  if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
      (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
    trimmed = trimmed.substring(1, trimmed.length - 1).trim();
  }
  return trimmed.isEmpty ? fallback : trimmed;
}

/// Parses raw `.env` content into [_env] as a fallback when `dotenv` is not loaded.
void parseEnvString(String raw) {
  for (final line in raw.replaceAll('\r\n', '\n').split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final idx = trimmed.indexOf('=');
    if (idx <= 0) continue;
    final key = trimmed.substring(0, idx).trim();
    final value = trimmed.substring(idx + 1).trim();
    _env[key] = value;
  }
}

Future<void> _loadEnv({String envPath = '.env'}) async {
  final candidates = <String>{envPath, '.env', 'assets/keys/.env'};
  for (final path in candidates) {
    try {
      await dotenv.load(fileName: path);
      if (dotenv.isInitialized && dotenv.env.isNotEmpty) {
        _env.addAll(dotenv.env);
        return;
      }
    } catch (_) {
      try {
        final raw = await rootBundle.loadString(path);
        parseEnvString(raw);
        if (_env.isNotEmpty) return;
      } catch (_) {}
    }
  }
  log('[Config] WARNING: No env vars loaded; check .env file.');
}

/// Initializes environment config, local persistence, Supabase, and GetIt DI.
Future<void> initInjection({
  bool initializeExternalServices = true,
}) async {
  if (initializeExternalServices) {
    await _loadEnv();
    await Hive.initFlutter();

    final supabaseUrl = getEnv('SUPABASE_URL');
    final supabaseAnonKey = getEnv('SUPABASE_ANON_KEY');
    if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          publishableKey: supabaseAnonKey,
        );
      } catch (_) {
        // Already initialized (e.g., hot reload).
      }
    }
  }

  // Core services
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<NotificationActionHandler>(
    () => NotificationActionHandler(),
  );
  sl.registerLazySingleton<SoundService>(() => SoundService());

  if (initializeExternalServices) {
    sl.registerLazySingleton<SupabaseClient>(() {
      try {
        return Supabase.instance.client;
      } catch (_) {
        final url = getEnv(
          'SUPABASE_URL',
          fallback: 'https://placeholder.supabase.co',
        );
        final anonKey = getEnv(
          'SUPABASE_ANON_KEY',
          fallback: 'placeholder-anon-key',
        );
        return SupabaseClient(
          url,
          anonKey,
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        );
      }
    });
    sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
    sl.registerLazySingleton<PushTokenService>(
      () => PushTokenService(sl<SupabaseClient>()),
    );
  }

  // Local database (single instance aliased across segregated interfaces)
  final expenseDb = PersistentExpenseDatabaseImpl();
  if (initializeExternalServices) {
    await expenseDb.init();
  }
  sl.registerLazySingleton<PersistentExpenseDatabaseImpl>(() => expenseDb);
  sl.registerLazySingleton<PersistentExpenseDatabase>(
    () => sl<PersistentExpenseDatabaseImpl>(),
  );
  sl.registerLazySingleton<ExpenseLocalDataSource>(
    () => sl<PersistentExpenseDatabaseImpl>(),
  );

  // Auth feature
  if (initializeExternalServices) {
    final webClientId = getEnv('GOOGLE_WEB_CLIENT_ID');
    final iosClientId = getEnv('GOOGLE_IOS_CLIENT_ID');

    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        supabaseClient: sl<SupabaseClient>(),
        googleSignIn: sl<GoogleSignIn>(),
        serverClientId: webClientId.isNotEmpty ? webClientId : null,
        clientId: iosClientId.isNotEmpty ? iosClientId : null,
      ),
    );
  }
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignInWithGoogle>(
    () => SignInWithGoogle(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignOut>(() => SignOut(sl<AuthRepository>()));
  sl.registerLazySingleton<DeleteAccount>(
    () => DeleteAccount(sl<AuthRepository>()),
  );
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      getCurrentUser: sl<GetCurrentUser>(),
      signInWithGoogle: sl<SignInWithGoogle>(),
      signOut: sl<SignOut>(),
      deleteAccount: sl<DeleteAccount>(),
    ),
  );

  // Expenses feature
  if (initializeExternalServices) {
    sl.registerLazySingleton<ExpenseRemoteDataSource>(
      () => ExpenseRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
    );
  }
  sl.registerLazySingleton<SyncCoordinator>(
    () => SyncCoordinator(
      localDatabase: sl<PersistentExpenseDatabase>(),
      remoteDataSource: sl<ExpenseRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(
      localDataSource: sl<ExpenseLocalDataSource>(),
      remoteDataSource: sl<ExpenseRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      syncCoordinator: sl<SyncCoordinator>(),
    ),
  );
  sl.registerLazySingleton<GetExpenses>(
    () => GetExpenses(sl<ExpenseRepository>()),
  );
  sl.registerLazySingleton<AddExpense>(
    () => AddExpense(sl<ExpenseRepository>()),
  );
  sl.registerLazySingleton<GetExpenseSplits>(
    () => GetExpenseSplits(sl<ExpenseRepository>()),
  );
  sl.registerLazySingleton<RecordExpenseSplit>(
    () => RecordExpenseSplit(sl<ExpenseRepository>()),
  );
  sl.registerLazySingleton<SyncExpenses>(
    () => SyncExpenses(sl<ExpenseRepository>()),
  );
  sl.registerFactory<ExpensesBloc>(
    () => ExpensesBloc(
      getExpenses: sl<GetExpenses>(),
      addExpense: sl<AddExpense>(),
      recordExpenseSplit: sl<RecordExpenseSplit>(),
      syncExpenses: sl<SyncExpenses>(),
      syncCoordinator: sl<SyncCoordinator>(),
    ),
  );
}
