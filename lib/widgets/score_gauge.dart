import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Medidor circular animado que muestra una puntuación de 0 a 100.
class ScoreGauge extends StatefulWidget {
  final double score;
  final String label;
  final double size;
  final bool animate;

  const ScoreGauge({
    super.key,
    required this.score,
    this.label = '',
    this.size = 140,
    this.animate = true,
  });

  @override
  State<ScoreGauge> createState() => _ScoreGaugeState();
}

class _ScoreGaugeState extends State<ScoreGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: widget.score)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant ScoreGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _scoreAnimation = Tween<double>(
        begin: _scoreAnimation.value,
        end: widget.score,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(widget.score);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _scoreAnimation,
        builder: (context, _) {
          return CustomPaint(
            painter: _GaugePainter(
              score: _scoreAnimation.value,
              color: color,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _scoreAnimation.value.round().toString(),
                    style: TextStyle(
                      fontSize: widget.size * 0.28,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: widget.size * 0.09,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodySmall?.color,
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

class _GaugePainter extends CustomPainter {
  final double score;
  final Color color;

  _GaugePainter({required this.score, required this.color});

  // Arco de 270° empezando desde 135° (abajo-izquierda).
  static const double _startAngle = 0.75 * math.pi;
  static const double _sweepAngle = 1.5 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Pista de fondo
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweepAngle,
      false,
      trackPaint,
    );

    // Arco de progreso
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final progressSweep = _sweepAngle * (score / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      progressSweep,
      false,
      progressPaint,
    );

    // Marcadores (ticks)
    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i <= 4; i++) {
      final angle = _startAngle + (_sweepAngle * i / 4);
      final inner = radius - 5;
      final outer = radius + 5;
      canvas.drawLine(
        Offset(
          center.dx + inner * math.cos(angle),
          center.dy + inner * math.sin(angle),
        ),
        Offset(
          center.dx + outer * math.cos(angle),
          center.dy + outer * math.sin(angle),
        ),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
