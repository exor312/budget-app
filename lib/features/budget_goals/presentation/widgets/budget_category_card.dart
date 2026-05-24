import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../data/budget_goals_model.dart';

/// A card displaying a budget category with progress bar and status indicator.
class BudgetCategoryCard extends StatelessWidget {
  const BudgetCategoryCard({
    super.key,
    required this.category,
  });

  final BudgetCategory category;

  @override
  Widget build(BuildContext context) {
    final status = category.status;
    final isCritical = status == BudgetStatus.critical;
    final isWarning = status == BudgetStatus.warning;

    return Container(
      decoration: BoxDecoration(
        color: FortunaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical
              ? FortunaColors.error.withValues(alpha: 0.2)
              : FortunaColors.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: FortunaColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isCritical, isWarning),
                const SizedBox(height: 12),
                _buildAmounts(),
                const SizedBox(height: 12),
                _buildProgressBar(status),
                const SizedBox(height: 12),
                _buildStatusRow(status),
              ],
            ),
          ),
          if (isCritical) _buildOverLimitBadge(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isCritical, bool isWarning) {
    Color iconBgColor;
    Color iconColor;

    if (isCritical) {
      iconBgColor = FortunaColors.errorContainer;
      iconColor = FortunaColors.error;
    } else if (isWarning) {
      iconBgColor = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFE65100);
    } else {
      iconBgColor =
          FortunaColors.onTertiaryContainer.withValues(alpha: 0.1);
      iconColor = FortunaColors.onTertiaryContainer;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category.icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: FortunaTextStyles.titleMd,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      category.description,
                      style: FortunaTextStyles.bodySm.copyWith(
                        color: FortunaColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
          color: FortunaColors.outline,
          iconSize: 20,
        ),
      ],
    );
  }

  Widget _buildAmounts() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '\$${_formatAmount(category.spent)}',
          style: FortunaTextStyles.numericDisplay.copyWith(
            color:
                category.status == BudgetStatus.critical
                    ? FortunaColors.error
                    : FortunaColors.primary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'of \$${_formatAmount(category.limit)}',
          style: FortunaTextStyles.bodySm.copyWith(
            color: FortunaColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BudgetStatus status) {
    final ratio = category.utilizationPercent / 100;
    final barWidth = ratio.clamp(0.0, 1.0);

    Color barColor;
    switch (status) {
      case BudgetStatus.healthy:
        barColor = FortunaColors.onTertiaryContainer;
        break;
      case BudgetStatus.warning:
        barColor = const Color(0xFFFF9800);
        break;
      case BudgetStatus.critical:
        barColor = FortunaColors.error;
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 8,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: FortunaColors.surfaceContainer,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          FractionallySizedBox(
            widthFactor: barWidth,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(BudgetStatus status) {
    IconData statusIcon;
    String statusText;
    Color textColor;

    switch (status) {
      case BudgetStatus.healthy:
        statusIcon = Icons.check_circle;
        statusText = 'Under budget';
        textColor = FortunaColors.onTertiaryContainer;
        break;
      case BudgetStatus.warning:
        statusIcon = Icons.warning;
        statusText =
            '${category.utilizationPercent.round()}% utilized \u2022 Careful!';
        textColor = const Color(0xFFE65100);
        break;
      case BudgetStatus.critical:
        statusIcon = Icons.error;
        statusText =
            '\$${_formatAmount(category.overLimitAmount)} over limit';
        textColor = FortunaColors.error;
        break;
    }

    return Row(
      children: [
        Icon(statusIcon, color: textColor, size: 16),
        const SizedBox(width: 4),
        Text(
          statusText,
          style: FortunaTextStyles.bodySm.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOverLimitBadge() {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: FortunaColors.error,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            topRight: Radius.circular(12),
          ),
        ),
        child: Text(
          'Over Limit',
          style: FortunaTextStyles.bodySm.copyWith(
            color: FortunaColors.onError,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 0.02,
          ),
        ),
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
