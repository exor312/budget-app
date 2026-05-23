import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../data/budget_model.dart';

/// Transaction list item — shows amount, description, income/expense indicator, delete button.
class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.amount >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: FortunaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FortunaColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isIncome
                ? FortunaColors.tertiaryFixed.withValues(alpha: 0.15)
                : FortunaColors.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? FortunaColors.onTertiaryContainer : FortunaColors.error,
            size: 20,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: FortunaColors.onSurface,
          ),
        ),
        subtitle: Text(
          _formatDate(transaction.date),
          style: TextStyle(
            fontSize: 12,
            color: FortunaColors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${transaction.amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isIncome ? FortunaColors.onTertiaryContainer : FortunaColors.error,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: FortunaColors.onSurfaceVariant,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
