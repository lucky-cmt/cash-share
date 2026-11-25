import 'package:flutter/material.dart';

/// Feature-level theme tokens for the expenses dashboard (light/dark reactive).
class DashTheme {
  final bool isDark;
  final Color surface;
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color accent;

  const DashTheme._({
    required this.isDark,
    required this.surface,
    required this.cardBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
  });

  factory DashTheme.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark;
    if (isDark) {
      return const DashTheme._(
        isDark: true,
        surface: Color(0xFF0F1419),
        cardBackground: Color(0xFF1A222B),
        primaryText: Color(0xFFF3F4F6),
        secondaryText: Color(0xFF9CA3AF),
        accent: Color(0xFF10B981),
      );
    }
    return const DashTheme._(
      isDark: false,
      surface: Color(0xFFF9FAFB),
      cardBackground: Color(0xFFFFFFFF),
      primaryText: Color(0xFF111827),
      secondaryText: Color(0xFF6B7280),
      accent: Color(0xFF0E9F6E),
    );
  }
}
