import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/notifications/notification_action_handler.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/expenses/data/sync/sync_coordinator.dart';
import 'features/expenses/presentation/bloc/expenses_bloc.dart';
import 'injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjection();
  runApp(const CashDistroApp());
  unawaited(_initBackgroundServices());
}

Future<void> _initBackgroundServices() async {
  final notificationService = sl<NotificationService>();
  final actionHandler = sl<NotificationActionHandler>();
  await notificationService.initialize(
    onDidReceiveNotificationResponse: actionHandler.handleResponse,
  );
  await notificationService.requestPermissions();
  sl<SyncCoordinator>().startListening();
}

class CashDistroApp extends StatefulWidget {
  const CashDistroApp({super.key});

  @override
  State<CashDistroApp> createState() => _CashDistroAppState();
}

class _CashDistroAppState extends State<CashDistroApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final themeMode = brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<ExpensesBloc>(create: (_) => sl<ExpensesBloc>()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const SplashPage(),
      ),
    );
  }
}
