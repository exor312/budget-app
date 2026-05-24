import 'package:flutter/material.dart';
import '../../../../core/theme/text_styles.dart';
import '../../data/savings_goal_model.dart';

/// A compact card showing a single savings goal with progress.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    this.onDelete,
  });

  final SavingsGoal goal;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final barWidth = (goal.percentComplete / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.savings, color: colorScheme.tertiary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.name,
                  style: FortunaTextStyles.titleSm.copyWith(
                    color: colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 18,
                  color: colorScheme.error.withValues(alpha: 0.7),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_formatAmount(goal.currentAmount)}',
                style: FortunaTextStyles.numericMd.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              Text(
                'of \$${_formatAmount(goal.targetAmount)}',
                style: FortunaTextStyles.bodyXs.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 4,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: barWidth,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.percentComplete.round()}% complete',
                style: FortunaTextStyles.bodyXs.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }
    return amount.toStringAsFixed(2);
  }
}
