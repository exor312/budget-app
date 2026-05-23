import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';

/// A summary card showing total monthly budget limit, spent, percentage,
/// and remaining amount with a progress bar.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.totalLimit,
    required this.totalSpent,
  });

  final double totalLimit;
  final double totalSpent;

  double get _utilizationPercent =>
      totalLimit > 0 ? (totalSpent / totalLimit * 100).round().toDouble() : 0.0;

  double get _remaining => totalLimit - totalSpent;

  @override
  Widget build(BuildContext context) {
    final barWidth =
        (_utilizationPercent / 100).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: FortunaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FortunaColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: FortunaColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Text(
                  'Total Monthly Limit',
                  style: FortunaTextStyles.labelCaps.copyWith(
                    color: FortunaColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                _buildAmountRow(),
                const SizedBox(height: 24),
                _buildProgressBar(barWidth),
                const SizedBox(height: 4),
                _buildFooter(),
              ],
            ),
          ),
    );
  }

  Widget _buildAmountRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${_formatAmount(totalLimit)}',
          style: FortunaTextStyles.displayLarge.copyWith(
            color: FortunaColors.primary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '/ \$${_formatAmount(totalSpent)} spent',
          style: FortunaTextStyles.titleMd.copyWith(
            color: FortunaColors.onTertiaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double barWidth) {
    return SizedBox(
      width: double.infinity,
      height: 12,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: FortunaColors.surfaceContainer,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          FractionallySizedBox(
            widthFactor: barWidth,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: FortunaColors.onTertiaryContainer,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                    color:
                        FortunaColors.onTertiaryContainer
                            .withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_utilizationPercent.round()}% utilized',
          style: FortunaTextStyles.bodySm.copyWith(
            color: FortunaColors.onSurfaceVariant,
          ),
        ),
        Text(
          '\$${_formatAmount(_remaining)} remaining',
          style: FortunaTextStyles.bodySm.copyWith(
            color: FortunaColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }
    return amount.toStringAsFixed(2);
  }
}
