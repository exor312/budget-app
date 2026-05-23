import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';

/// Total Net Worth card — large balance display with trend indicator and mini chart.
class NetWorthCard extends StatelessWidget {
  const NetWorthCard({
    super.key,
    required this.balance,
    this.trendPercentage = 4.2,
  });

  final double balance;
  final double trendPercentage;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FortunaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FortunaColors.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: FortunaColors.primary.withValues(alpha: 0.05),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Net Worth',
                    style: FortunaTextStyles.labelCaps.copyWith(
                      color: FortunaColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_formatCurrency(balance)}',
                    style: isDesktop
                        ? FortunaTextStyles.displayLarge.copyWith(
                            color: FortunaColors.primary,
                            fontSize: 48,
                          )
                        : FortunaTextStyles.headlineLg.copyWith(
                            color: FortunaColors.primary,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: FortunaColors.onTertiaryContainer,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${trendPercentage.toStringAsFixed(1)}% from last month',
                        style: FortunaTextStyles.labelCaps.copyWith(
                          color: FortunaColors.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FortunaColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: FortunaColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Mini area chart placeholder
          SizedBox(
            height: 80,
            width: double.infinity,
            child: CustomPaint(
              painter: _MiniAreaChartPainter(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final abs = value.abs();
    final parts = abs.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    // Add commas for thousands
    String formatted = '';
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) formatted += ',';
      formatted += intPart[i];
    }
    return '$formatted.$decPart';
  }
}

class _MiniAreaChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          FortunaColors.primary.withValues(alpha: 0.1),
          FortunaColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = FortunaColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.25, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.85),
      Offset(size.width * 0.75, size.height * 0.4),
      Offset(size.width, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Fill area
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, gradientPaint);

    // Draw line
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
