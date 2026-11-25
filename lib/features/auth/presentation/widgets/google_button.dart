import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'fancy_spinner.dart';

export 'fancy_spinner.dart';

abstract final class _GoogleButtonColors {
  static const slate = Color(0xFF1A2234);
  static const emerald = Color(0xFF22C55E);
  static const mint = Color(0xFF86EFAC);
  static const text = Color(0xFFF8FAFC);
}

/// 58dp button with animated emerald sheen border, press squash, and spinner.
class GoogleButton extends StatefulWidget {
  const GoogleButton({
    super.key,
    required this.busy,
    required this.onTap,
    this.mark,
    this.label = 'Continue with Google',
  });

  final bool busy;
  final VoidCallback onTap;
  final Widget? mark;
  final String label;

  @override
  State<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton>
    with SingleTickerProviderStateMixin {
  bool _down = false;
  late final AnimationController _sheen =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark;
    final btnBg = isDark ? _GoogleButtonColors.slate : const Color(0xFFFFFFFF);
    final btnTextColor =
        isDark ? _GoogleButtonColors.text : const Color(0xFF0F172A);

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: widget.busy ? null : (_) => setState(() => _down = true),
        onTapCancel: widget.busy ? null : () => setState(() => _down = false),
        onTapUp: widget.busy
            ? null
            : (_) {
                setState(() => _down = false);
                HapticFeedback.mediumImpact();
                widget.onTap();
              },
        child: AnimatedScale(
          scale: (_down && !widget.busy) ? 0.96 : 1.0,
          duration: Duration(milliseconds: _down ? 90 : 260),
          curve: _down ? Curves.easeOut : Curves.easeOutBack,
          child: AnimatedBuilder(
            animation: _sheen,
            builder: (context, child) => CustomPaint(
              foregroundPainter: _SheenBorderPainter(
                _sheen.value,
                isDark: isDark,
              ),
              child: child,
            ),
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: btnBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.85, end: 1.0).animate(animation),
                    child: child,
                  ),
                ),
                child: widget.busy
                    ? const FancySpinner(
                        key: ValueKey('busy_spinner'),
                        size: 26,
                        strokeWidth: 2.8,
                        primaryColor: _GoogleButtonColors.emerald,
                        glowColor: _GoogleButtonColors.mint,
                      )
                    : Row(
                        key: const ValueKey('idle'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.mark ?? const _GoogleMark(),
                          const SizedBox(width: 12),
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: btnTextColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  static const String assetPath =
      'assets/icons/google-logo-search-new-svgrepo-com.svg';

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        assetPath,
        width: 22,
        height: 22,
      );
}

class _SheenBorderPainter extends CustomPainter {
  _SheenBorderPainter(this.t, {this.isDark = true});

  final double t;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.75),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = isDark
            ? _GoogleButtonColors.emerald.withAlpha(110)
            : const Color(0xFFCBD5E1),
    );
    final p = t / 0.4;
    if (p >= 1.0) return;
    final x = -size.width * 0.2 + p * size.width * 1.4;
    final band = Rect.fromLTWH(x - 70, 0, 140, size.height);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = LinearGradient(
          colors: [
            _GoogleButtonColors.mint.withAlpha(0),
            _GoogleButtonColors.mint,
            _GoogleButtonColors.mint.withAlpha(0),
          ],
        ).createShader(band),
    );
  }

  @override
  bool shouldRepaint(covariant _SheenBorderPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.isDark != isDark;
}
