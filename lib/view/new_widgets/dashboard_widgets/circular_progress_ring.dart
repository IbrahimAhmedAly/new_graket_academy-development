import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_dimentions.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/colors.dart';

/// A large progress ring with a sweeping gradient.
///
/// Hand-drawn rather than pulled from a package so the stroke can carry the
/// app's purple gradient and animate from zero on first paint, matching the
/// gradient treatment used elsewhere for headline figures.
class CircularProgressRing extends StatefulWidget {
  final int percent;
  final String label;
  final double size;

  const CircularProgressRing({
    super.key,
    required this.percent,
    this.label = 'Completed',
    this.size = 180,
  });

  @override
  State<CircularProgressRing> createState() => _CircularProgressRingState();
}

class _CircularProgressRingState extends State<CircularProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _animation = _buildAnimation(0, widget.percent.toDouble());
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CircularProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate from wherever the ring currently sits, so a refresh eases to the
    // new value instead of snapping back to zero first.
    if (oldWidget.percent != widget.percent) {
      _animation = _buildAnimation(_animation.value, widget.percent.toDouble());
      _controller.forward(from: 0);
    }
  }

  Animation<double> _buildAnimation(double from, double to) {
    return Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final side = widget.size.w;

    return SizedBox(
      width: side,
      height: side,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final value = _animation.value.clamp(0, 100).toDouble();

          return CustomPaint(
            painter: _RingPainter(
              percent: value,
              trackColor: theme.isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : AppColor.gray.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${value.round()}%',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: theme.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: AppHeight.h4),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize13,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color trackColor;

  _RingPainter({required this.percent, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.09;
    final radius = (size.width - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    if (percent <= 0) return;

    // Start at 12 o'clock and sweep clockwise.
    const startAngle = -math.pi / 2;
    final sweepAngle = (percent / 100) * 2 * math.pi;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final progress = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + 2 * math.pi,
        colors: const [
          AppColor.primaryColor,
          AppColor.accentBlue,
          AppColor.primaryDark,
          AppColor.primaryColor,
        ],
        stops: const [0.0, 0.4, 0.75, 1.0],
        transform: GradientRotation(startAngle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progress);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.trackColor != trackColor;
}
