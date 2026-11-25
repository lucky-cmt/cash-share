import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Modern circular spinner with sweep-gradient arc, orbital pip, and center glow.
class FancySpinner extends StatefulWidget {
  const FancySpinner({
    super.key,
    this.size = 26.0,
    this.strokeWidth = 2.8,
    this.primaryColor = const Color(0xFF22C55E),
    this.glowColor = const Color(0xFF86EFAC),
    this.trackColor,
  });

  final double size;
  final double strokeWidth;
  final Color primaryColor;
  final Color glowColor;
  final Color? trackColor;

  @override
  State<FancySpinner> createState() => _FancySpinnerState();
}

class _FancySpinnerState extends State<FancySpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTrack =
        widget.trackColor ?? widget.primaryColor.withAlpha(35);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _FancySpinnerPainter(
            progress: _controller.value,
            strokeWidth: widget.strokeWidth,
            primaryColor: widget.primaryColor,
            glowColor: widget.glowColor,
            trackColor: effectiveTrack,
          ),
        );
      },
    );
  }
}

class _FancySpinnerPainter extends CustomPainter {
  _FancySpinnerPainter({
    required this.progress,
    required this.strokeWidth,
    required this.primaryColor,
    required this.glowColor,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color primaryColor;
  final Color glowColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    if (radius <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final pulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);
    final centerGlowPaint = Paint()
      ..color = glowColor.withAlpha((20 + 25 * pulse).toInt())
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    canvas.drawCircle(center, radius * 0.45, centerGlowPaint);

    const sweepAngle = 1.35 * math.pi;
    final startAngle = progress * 2 * math.pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(startAngle);
    canvas.translate(-center.dx, -center.dy);

    final sweepGradient = SweepGradient(
      startAngle: 0.0,
      endAngle: sweepAngle,
      colors: [
        primaryColor.withAlpha(0),
        primaryColor.withAlpha(120),
        primaryColor,
        glowColor,
      ],
      stops: const [0.0, 0.35, 0.75, 1.0],
    );

    final arcPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0.0, sweepAngle, false, arcPaint);

    final tipX = center.dx + radius * math.cos(sweepAngle);
    final tipY = center.dy + radius * math.sin(sweepAngle);
    final tipOffset = Offset(tipX, tipY);

    final tipGlowPaint = Paint()
      ..color = glowColor.withAlpha(190)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawCircle(tipOffset, strokeWidth * 0.9, tipGlowPaint);

    final tipCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(tipOffset, strokeWidth * 0.5, tipCorePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FancySpinnerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
