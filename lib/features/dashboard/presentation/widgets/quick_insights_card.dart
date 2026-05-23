import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';

/// Quick Insights card — Savings Goal and Bills Due in a 2-column grid.
class QuickInsightsCard extends StatelessWidget {
  const QuickInsightsCard({
    super.key,
    this.savingsGoal = 12000,
    this.billsDueDays = 3,
  });

  final double savingsGoal;
  final int billsDueDays;

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Quick Insights',
            style: FortunaTextStyles.titleMd.copyWith(
              color: FortunaColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FortunaColors.tertiaryFixed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: FortunaColors.tertiaryFixed.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.savings,
                        color: FortunaColors.onTertiaryFixedVariant,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Savings Goal',
                        style: FortunaTextStyles.bodySm.copyWith(
                          color: FortunaColors.onTertiaryFixedVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_formatCurrency(savingsGoal)}',
                        style: FortunaTextStyles.titleMd.copyWith(
                          color: FortunaColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FortunaColors.errorContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: FortunaColors.errorContainer.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning,
                        color: FortunaColors.error,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bills Due',
                        style: FortunaTextStyles.bodySm.copyWith(
                          color: FortunaColors.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$billsDueDays Days',
                        style: FortunaTextStyles.titleMd.copyWith(
                          color: FortunaColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final intPart = value.toInt().toString();
    String formatted = '';
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) formatted += ',';
      formatted += intPart[i];
    }
    return formatted;
  }
}
