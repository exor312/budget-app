import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';

/// Monthly Budget progress card — spent vs budget with progress bar.
class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    super.key,
    required this.spentAmount,
    required this.totalBudget,
  });

  final double spentAmount;
  final double totalBudget;

  @override
  Widget build(BuildContext context) {
    final progress = totalBudget > 0 ? (spentAmount / totalBudget).clamp(0.0, 1.0) : 0.0;
    final remaining = (totalBudget - spentAmount).clamp(0.0, totalBudget);
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FortunaColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: FortunaColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Budget',
                    style: FortunaTextStyles.labelCaps.copyWith(
                      color: FortunaColors.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  Icon(
                    Icons.payments,
                    color: FortunaColors.onPrimary.withValues(alpha: 0.7),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '\$${_formatCurrency(spentAmount)}',
                      style: FortunaTextStyles.numericDisplay.copyWith(
                        color: FortunaColors.onPrimary,
                      ),
                    ),
                    TextSpan(
                      text: ' of \$${_formatCurrency(totalBudget)}',
                      style: FortunaTextStyles.bodySm.copyWith(
                        color: FortunaColors.onPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: FortunaColors.onPrimary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    FortunaColors.tertiaryFixedDim,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$percentage% consumed',
                    style: FortunaTextStyles.bodySm.copyWith(
                      color: FortunaColors.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '\$${_formatCurrency(remaining)} remaining',
                    style: FortunaTextStyles.bodySm.copyWith(
                      color: FortunaColors.tertiaryFixedDim,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: FortunaColors.onPrimary.withValues(alpha: 0.1)),
                backgroundColor: FortunaColors.onPrimary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'VIEW BUDGET DETAILS',
                style: FortunaTextStyles.labelCaps.copyWith(
                  color: FortunaColors.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
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
