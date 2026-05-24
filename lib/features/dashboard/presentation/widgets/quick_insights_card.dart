import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';

/// Quick Insights card — Savings Goal and Bills Due.
/// All values are computed from real transaction data, passed in as parameters.
class QuickInsightsCard extends StatelessWidget {
  const QuickInsightsCard({
    super.key,
    required this.savingsAmount,
    required this.billsDueLabel,
  });

  final double savingsAmount;
  final String billsDueLabel;

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
                        'Savings',
                        style: FortunaTextStyles.bodySm.copyWith(
                          color: FortunaColors.onTertiaryFixedVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_formatCurrency(savingsAmount)}',
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
                        billsDueLabel,
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

  static String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    String formatted = '';
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) formatted += ',';
      formatted += intPart[i];
    }
    return '$formatted.$decPart';
  }
}
