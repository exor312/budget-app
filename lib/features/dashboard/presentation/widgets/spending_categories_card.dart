import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../transactions/data/budget_model.dart';

/// Top Spending Categories card — category icons, names, percentages, progress bars.
class SpendingCategoriesCard extends StatelessWidget {
  const SpendingCategoriesCard({
    super.key,
    required this.categories,
  });

  final List<SpendingCategory> categories;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Spending Categories',
                style: FortunaTextStyles.titleMd.copyWith(
                  color: FortunaColors.primary,
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
                    color: FortunaColors.onSecondaryContainer,
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
  const _CategoryRow({required this.category});

  final SpendingCategory category;

  @override
  Widget build(BuildContext context) {
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
                      color: FortunaColors.secondaryFixedDim.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category.icon,
                      color: FortunaColors.primary,
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
              Text(
                '${category.percentage}%',
                style: FortunaTextStyles.bodyLg.copyWith(
                  color: FortunaColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: category.percentage / 100,
              minHeight: 6,
              backgroundColor: FortunaColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(FortunaColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
