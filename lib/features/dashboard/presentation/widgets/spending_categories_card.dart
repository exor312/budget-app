import 'package:flutter/material.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../transactions/data/budget_model.dart';

/// Top Spending Categories card — category icons, names, percentages, progress bars.
class SpendingCategoriesCard extends StatelessWidget {
  SpendingCategoriesCard({
    super.key,
    required this.categories,
  });

  final List<SpendingCategory> categories;

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
                'Top Spending Categories',
                style: FortunaTextStyles.titleMd.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'ALL CATEGORIES',
                  style: FortunaTextStyles.labelCaps.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...categories.take(3).map((category) => _CategoryRow(category: category)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  _CategoryRow({required this.category});

  final SpendingCategory category;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final amountStr = '\$${_formatAmount(category.amount)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category.icon,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category.name,
                    style: FortunaTextStyles.bodyLg,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountStr,
                    style: FortunaTextStyles.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${category.percentage}%',
                    style: FortunaTextStyles.bodySm.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: category.percentage / 100,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatAmount(double value) {
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
