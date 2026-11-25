import 'package:flutter/material.dart';

/// Brand logo widget for Cash Distro.
class CashDistroLogo extends StatelessWidget {
  final double size;

  const CashDistroLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Icon(
      Icons.account_balance_wallet_rounded,
      size: size,
      color: colorScheme.primary,
    );
  }
}
