import 'package:flutter/material.dart';
import '../../../../core/theme/text_styles.dart';
import '../../data/budget_goals_model.dart';

/// A compact card displaying a budget category with progress bar and action buttons.
class BudgetCategoryCard extends StatelessWidget {
  const BudgetCategoryCard({
    super.key,
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  final BudgetCategory category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final status = category.status;
    final isCritical = status == BudgetStatus.critical;
    final isWarning = status == BudgetStatus.warning;

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCritical
              ? colorScheme.error.withValues(alpha: 0.2)
              : colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isCritical, isWarning),
                const SizedBox(height: 8),
                _buildAmounts(context),
                const SizedBox(height: 6),
                _buildProgressBar(context, status),
                const SizedBox(height: 4),
                _buildStatusRow(context, status),
              ],
            ),
          ),
          if (isCritical) _buildOverLimitBadge(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCritical, bool isWarning) {
    final colorScheme = Theme.of(context).colorScheme;
    Color iconBgColor;
    Color iconColor;

    if (isCritical) {
      iconBgColor = colorScheme.errorContainer;
      iconColor = colorScheme.error;
    } else if (isWarning) {
      iconBgColor = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFE65100);
    } else {
      iconBgColor = colorScheme.onTertiaryContainer.withValues(alpha: 0.1);
      iconColor = colorScheme.onTertiaryContainer;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(category.icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            category.name,
            style: FortunaTextStyles.titleSm,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            iconSize: 18,
            color: colorScheme.outline,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
    );
  }

  Widget _buildAmounts(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '\$${_formatAmount(category.spent)}',
          style: FortunaTextStyles.numericMd.copyWith(
            color: category.status == BudgetStatus.critical
                ? colorScheme.error
                : colorScheme.primary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'of \$${_formatAmount(category.limit)}',
          style: FortunaTextStyles.bodyXs.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, BudgetStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    final ratio = category.utilizationPercent / 100;
    final barWidth = ratio.clamp(0.0, 1.0);

    Color barColor;
    switch (status) {
      case BudgetStatus.healthy:
        barColor = colorScheme.onTertiaryContainer;
        break;
      case BudgetStatus.warning:
        barColor = const Color(0xFFFF9800);
        break;
      case BudgetStatus.critical:
        barColor = colorScheme.error;
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 4,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          FractionallySizedBox(
            widthFactor: barWidth,
            child: Container(
              height: 4,
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

  Widget _buildStatusRow(BuildContext context, BudgetStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    IconData statusIcon;
    String statusText;
    Color textColor;

    switch (status) {
      case BudgetStatus.healthy:
        statusIcon = Icons.check_circle;
        statusText = 'On track';
        textColor = colorScheme.onTertiaryContainer;
        break;
      case BudgetStatus.warning:
        statusIcon = Icons.warning;
        statusText = '${category.utilizationPercent.round()}% used';
        textColor = const Color(0xFFE65100);
        break;
      case BudgetStatus.critical:
        statusIcon = Icons.error;
        statusText = '\$${_formatAmount(category.overLimitAmount)} over';
        textColor = colorScheme.error;
        break;
    }

    return Row(
      children: [
        Icon(statusIcon, color: textColor, size: 12),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            statusText,
            style: FortunaTextStyles.bodyXs.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverLimitBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(6),
            topRight: Radius.circular(10),
          ),
        ),
        child: Text(
          'Over',
          style: FortunaTextStyles.bodyXs.copyWith(
            color: colorScheme.onError,
            fontWeight: FontWeight.bold,
            fontSize: 9,
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
