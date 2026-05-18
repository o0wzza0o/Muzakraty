import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                Color(0xFF0D1235),
                AppColors.background,
              ],
            ),
          ),
        ),
        // Animated orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _OrbPainter(_controller.value),
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double progress;
  _OrbPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Orb 1
    paint.shader = RadialGradient(
      colors: [
        AppColors.primary.withValues(alpha: 0.15),
        AppColors.primary.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(
        size.width * 0.2 + sin(progress * 2 * pi) * 30,
        size.height * 0.3 + cos(progress * 2 * pi) * 20,
      ),
      radius: 150,
    ));
    canvas.drawCircle(
      Offset(
        size.width * 0.2 + sin(progress * 2 * pi) * 30,
        size.height * 0.3 + cos(progress * 2 * pi) * 20,
      ),
      150,
      paint,
    );

    // Orb 2
    paint.shader = RadialGradient(
      colors: [
        AppColors.accent.withValues(alpha: 0.1),
        AppColors.accent.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(
        size.width * 0.8 + cos(progress * 2 * pi) * 25,
        size.height * 0.7 + sin(progress * 2 * pi) * 35,
      ),
      radius: 120,
    ));
    canvas.drawCircle(
      Offset(
        size.width * 0.8 + cos(progress * 2 * pi) * 25,
        size.height * 0.7 + sin(progress * 2 * pi) * 35,
      ),
      120,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
