import 'package:flutter/material.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../settings/data/account_settings_model.dart';

/// Card widget showing an account's icon, name, type label, and formatted balance.
class AccountBalanceCard extends StatelessWidget {
  AccountBalanceCard({
    super.key,
    required this.account,
    required this.balance,
  });

  final Account account;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final isNegative = balance < 0;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              account.icon,
              color: cs.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: FortunaTextStyles.bodyLg.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  accountTypeLabel(account.type),
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${_formatCurrency(balance)}',
            style: FortunaTextStyles.titleMd.copyWith(
              color: isNegative ? cs.error : cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
