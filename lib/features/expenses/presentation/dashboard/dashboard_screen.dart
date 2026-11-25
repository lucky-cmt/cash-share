import 'package:flutter/material.dart';

import 'dash_theme.dart';
import 'dashboard_store.dart';

/// Main shared expenses dashboard screen.
class DashboardScreen extends StatelessWidget {
  final DashboardStore store;
  final VoidCallback? onSignOut;

  const DashboardScreen({super.key, required this.store, this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final dashTheme = DashTheme.of(context);
    return Scaffold(
      backgroundColor: dashTheme.surface,
      appBar: AppBar(
        title: const Text('Cash Distro'),
        actions: [
          if (onSignOut != null)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Sign out',
              onPressed: onSignOut,
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          if (store.items.isEmpty) {
            return const Center(
              child: Text('No shared expenses yet.'),
            );
          }
          return ListView.builder(
            itemCount: store.items.length,
            itemBuilder: (context, index) {
              final expense = store.items[index].expense;
              return ListTile(
                title: Text(expense.title),
                trailing: Text(expense.amount.toStringAsFixed(2)),
              );
            },
          );
        },
      ),
    );
  }
}
