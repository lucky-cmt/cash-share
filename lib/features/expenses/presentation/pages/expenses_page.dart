import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/sound/sound_service.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';
import '../bloc/expenses_bloc.dart';
import '../bloc/expenses_event.dart';
import '../bloc/expenses_state.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/dashboard_store.dart';

/// Bridges [ExpensesBloc] and [DashboardStore].
class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  late final DashboardStore _store;

  @override
  void initState() {
    super.initState();
    _store = DashboardStore(soundService: sl<SoundService>());
    context.read<ExpensesBloc>().add(const LoadExpensesRequested());
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ExpensesBloc, ExpensesState>(
          listener: (context, state) {
            if (state is ExpensesLoaded) {
              _store.setExpenses(state.expenses);
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SignInPage()),
              );
            }
          },
        ),
      ],
      child: DashboardScreen(
        store: _store,
        onSignOut: () =>
            context.read<AuthBloc>().add(const AuthSignOutRequested()),
      ),
    );
  }
}
