import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../transactions/data/budget_model.dart';
import '../../../transactions/presentation/widgets/transaction_list_item.dart';

/// Displays a filtered list of transactions for a specific account,
/// grouped by date (Today, Yesterday, date header).
class AccountTransactionList extends StatelessWidget {
  const AccountTransactionList({
    super.key,
    required this.accountId,
    required this.transactions,
    required this.onDelete,
  });

  final String accountId;
  final List<Transaction> transactions;
  final void Function(int originalIndex) onDelete;

  List<Transaction> get _filtered =>
      transactions.where((t) => t.accountId == accountId).toList();

  Map<String, List<Transaction>> _groupTransactions(List<Transaction> txns) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<Transaction>> groups = {};

    for (final t in txns.reversed) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);

      String groupKey;
      if (tDate == today) {
        groupKey = 'Today';
      } else if (tDate == yesterday) {
        groupKey = 'Yesterday';
      } else {
        groupKey = _formatDateHeader(t.date);
      }

      groups.putIfAbsent(groupKey, () => []);
      groups[groupKey]!.add(t);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    if (filtered.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: FortunaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: FortunaColors.outlineVariant.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: FortunaColors.onSurfaceVariant,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No transactions for this account',
              style: TextStyle(
                color: FortunaColors.onSurfaceVariant,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add a transaction or make an adjustment',
              style: TextStyle(
                color: FortunaColors.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final groups = _groupTransactions(filtered);
    final groupKeys = groups.keys.toList();
    final reversedTxns = transactions.reversed.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...groupKeys.map((groupKey) {
            final txns = groups[groupKey]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    groupKey,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: FortunaColors.onSurfaceVariant,
                      letterSpacing: 0.05,
                    ),
                  ),
                ),
                ...txns.map((t) {
                  final originalIndex = transactions.length -
                      1 -
                      reversedTxns.indexOf(t);
                  return TransactionListItem(
                    transaction: t,
                    onDelete: () => onDelete(originalIndex),
                  );
                }),
              ],
            );
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
