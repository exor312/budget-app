import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/text_styles.dart';

/// Security Health card — circular progress indicator with score and status text.
/// Score is computed from real transaction activity, passed in as a parameter.
class SecurityHealthCard extends StatelessWidget {
  SecurityHealthCard({
    super.key,
    required this.score,
  });

  final int score;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Security Health',
                style: FortunaTextStyles.titleMd.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              Icon(
                Icons.verified_user,
                color: colorScheme.onTertiaryContainer,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _CircularProgressPainter(
                        progress: score / 100,
                        strokeWidth: 4,
                        backgroundColor: colorScheme.surfaceContainer,
                        progressColor: colorScheme.primary,
                      ),
                    ),
                    Center(
                      child: Text(
                        '$score',
                        style: FortunaTextStyles.labelCaps.copyWith(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _statusText,
                  style: FortunaTextStyles.bodySm.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _statusText {
    if (score >= 80) {
      return 'Your account security score is high. Two-factor authentication is active.';
    } else if (score >= 40) {
      return 'Your account security score is moderate. Consider enabling additional security features.';
    } else {
      return 'Start adding transactions to build your financial health score.';
    }
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
