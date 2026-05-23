import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../data/budget_model.dart';

/// Transaction list item — matches the Fortuna reference design.
/// Shows category icon in colored circle, merchant name, time + category,
/// colored amount, and a small label tag.
class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback onDelete;

  /// Map category to icon.
  IconData get _categoryIcon {
    final cat = transaction.category.toLowerCase();
    if (cat.contains('grocery') || cat.contains('food') || cat.contains('dining')) {
      return Icons.restaurant;
    }
    if (cat.contains('transport') || cat.contains('gas') || cat.contains('auto')) {
      return Icons.local_gas_station;
    }
    if (cat.contains('shop') || cat.contains('buy')) {
      return Icons.shopping_bag;
    }
    if (cat.contains('entertainment') || cat.contains('subscription') || cat.contains('netflix')) {
      return Icons.subscriptions;
    }
    if (cat.contains('health') || cat.contains('gym') || cat.contains('fitness')) {
      return Icons.fitness_center;
    }
    if (cat.contains('income') || cat.contains('salary') || cat.contains('deposit')) {
      return Icons.payments;
    }
    return Icons.receipt;
  }

  /// Map category to label text.
  String get _categoryLabel {
    final cat = transaction.category.toLowerCase();
    if (cat.contains('grocery') || cat.contains('food') || cat.contains('dining')) {
      return 'Groceries';
    }
    if (cat.contains('transport') || cat.contains('gas')) {
      return 'Transport';
    }
    if (cat.contains('shop')) {
      return 'Shopping';
    }
    if (cat.contains('entertainment') || cat.contains('subscription')) {
      return 'Entertainment';
    }
    if (cat.contains('health') || cat.contains('gym') || cat.contains('fitness')) {
      return 'Health';
    }
    if (cat.contains('income') || cat.contains('salary') || cat.contains('deposit')) {
      return 'Income';
    }
    return 'Personal';
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.amount >= 0;
    final amountStr =
        '${isIncome ? '+' : '-'}\$${transaction.amount.abs().toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: FortunaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FortunaColors.outlineVariant.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: FortunaColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category icon in colored circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isIncome
                        ? FortunaColors.tertiaryFixed
                        : FortunaColors.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _categoryIcon,
                    color: isIncome
                        ? FortunaColors.onTertiaryFixedVariant
                        : FortunaColors.onSecondaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Merchant name + time/category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: FortunaColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatTime(transaction.date)} • ${_categoryLabel}',
                        style: TextStyle(
                          fontSize: 14,
                          color: FortunaColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount + label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amountStr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isIncome
                            ? FortunaColors.onTertiaryContainer
                            : FortunaColors.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _categoryLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.05,
                        color: FortunaColors.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // Delete button
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: FortunaColors.onSurfaceVariant,
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }
}
