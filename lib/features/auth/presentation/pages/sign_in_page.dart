import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/presentation/widgets/cash_distro_logo.dart';
import '../../../../core/presentation/widgets/custom_snack_bar.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../expenses/presentation/pages/expenses_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/google_button.dart';

/// Sign-in / Sign-up screen for Cash Distro using Google OAuth + Supabase.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark;
    final canvasColor =
        isDark ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC);
    const mintColor = Color(0xFF86EFAC);
    const emeraldColor = Color(0xFF22C55E);
    final textColor =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final mutedColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final faintColor =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final linkColor = isDark ? mintColor : const Color(0xFF16A34A);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ExpensesPage()),
          );
        } else if (state is AuthError) {
          CustomSnackBar.show(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: canvasColor,
          body: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _ambient,
                  builder: (context, _) {
                    final b =
                        0.5 - 0.5 * math.cos(2 * math.pi * _ambient.value);
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.45),
                          radius: 0.85 + 0.08 * b,
                          colors: [
                            mintColor.withAlpha(
                              (isDark ? (26 + 14 * b) : (30 + 10 * b)).round(),
                            ),
                            emeraldColor.withAlpha(isDark ? 8 : 12),
                            canvasColor.withAlpha(0),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      const CashDistroLogo(size: 112),
                      const SizedBox(height: 28),
                      Text(
                        'Cash Distro',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Split and settle shared expenses with friends',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: mutedColor,
                        ),
                      ),
                      const Spacer(flex: 2),
                      GoogleButton(
                        busy: isLoading,
                        onTap: () {
                          context.read<AuthBloc>().add(
                                const AuthSignInWithGoogleRequested(),
                              );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_rounded, size: 13, color: faintColor),
                          const SizedBox(width: 5),
                          Text(
                            'Secured by Supabase Auth',
                            style: TextStyle(fontSize: 12, color: faintColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Works offline • Syncs automatically with your group',
                        style: TextStyle(fontSize: 12, color: faintColor),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => UrlLauncherHelper.openPrivacyAndTerms(),
                        child: Text(
                          'Privacy Policy & Terms of Service',
                          style: TextStyle(
                            fontSize: 12,
                            color: linkColor,
                            decoration: TextDecoration.underline,
                            decorationColor: linkColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
