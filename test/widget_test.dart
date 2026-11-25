import 'package:cash_distro/core/presentation/widgets/cash_distro_logo.dart';
import 'package:cash_distro/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CashDistroLogo renders inside MaterialApp', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(child: CashDistroLogo()),
        ),
      ),
    );

    expect(find.byType(CashDistroLogo), findsOneWidget);
  });
}
