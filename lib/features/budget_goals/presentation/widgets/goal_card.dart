import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../data/budget_goals_model.dart';

/// A card showing the active savings goal with progress.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
  });

  final ActiveGoal goal;

  @override
  Widget build(BuildContext context) {
    final barWidth =
        (goal.percentComplete / 100).clamp(0.0, 1.0);

    return Container(
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          Text(
            goal.name,
            style: FortunaTextStyles.titleMd.copyWith(
              color: FortunaColors.primaryFixed,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Target: \$${_formatAmount(goal.targetAmount)}',
            style: FortunaTextStyles.bodySm.copyWith(
              color: FortunaColors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          _buildProgressBar(barWidth),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          Icons.savings,
          color: FortunaColors.tertiaryFixedDim,
          size: 32,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: FortunaColors.onTertiaryFixedVariant,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            'Active Goal',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
              color: FortunaColors.tertiaryFixed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double barWidth) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${_formatAmount(goal.currentAmount)}',
              style: FortunaTextStyles.numericDisplay.copyWith(
                color: FortunaColors.primaryFixed,
              ),
            ),
            Text(
              '${goal.percentComplete}%',
              style: FortunaTextStyles.bodySm.copyWith(
                color: FortunaColors.primaryFixedDim,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 6,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: FortunaColors.surfaceContainerLowest
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              FractionallySizedBox(
                widthFactor: barWidth,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: FortunaColors.tertiaryFixedDim,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            ],
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
