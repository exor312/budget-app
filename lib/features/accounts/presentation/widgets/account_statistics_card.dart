import 'package:flutter/material.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../transactions/data/budget_model.dart';

/// Shows income/expense statistics for a specific account.
class AccountStatisticsCard extends StatelessWidget {
  const AccountStatisticsCard({
    super.key,
    required this.accountId,
    required this.transactions,
  });

  final String accountId;
  final List<Transaction> transactions;

  List<Transaction> get _accountTransactions =>
      transactions.where((t) => t.accountId == accountId).toList();

  double get _totalIncome => _accountTransactions
      .where((t) => t.amount > 0)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalExpense => _accountTransactions
      .where((t) => t.amount < 0)
      .fold(0.0, (sum, t) => sum + t.amount.abs());

  double get _netChange => _totalIncome - _totalExpense;

  int get _transactionCount => _accountTransactions.length;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
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
          Text(
            'Statistics',
            style: FortunaTextStyles.titleMd.copyWith(
              color: FortunaColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Income',
                  amount: _totalIncome,
                  color: FortunaColors.onTertiaryContainer,
                  icon: Icons.arrow_downward,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Expenses',
                  amount: _totalExpense,
                  color: FortunaColors.error,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Net Change',
                  amount: _netChange,
                  color: _netChange >= 0
                      ? FortunaColors.onTertiaryContainer
                      : FortunaColors.error,
                  icon: _netChange >= 0 ? Icons.trending_up : Icons.trending_down,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Transactions',
                  amount: _transactionCount.toDouble(),
                  color: FortunaColors.onSurface,
                  icon: Icons.receipt_long,
                  isCount: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.isCount = false,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: FortunaColors.onSurfaceVariant,
                  letterSpacing: 0.05,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isCount ? amount.toInt().toString() : '\$${_formatCurrency(amount)}',
                style: FortunaTextStyles.titleMd.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    final isNeg = value < 0;
    final abs = value.abs();
    final parts = abs.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    String formatted = '';
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) formatted += ',';
      formatted += intPart[i];
    }
    return '${isNeg ? '-' : ''}$formatted.$decPart';
  }
}
