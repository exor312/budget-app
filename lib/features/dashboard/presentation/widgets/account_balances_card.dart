import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../settings/data/account_settings_model.dart';
import '../../../transactions/data/budget_model.dart';

/// Compact card for the Dashboard showing per-account balance summary.
class AccountBalancesCard extends StatelessWidget {
  AccountBalancesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AccountSettingsModel, BudgetModel>(
      builder: (context, accountModel, budgetModel, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final balances = budgetModel.getBalancePerAccount();
        final accounts = accountModel.accounts;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.05),
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
                    'Account Balances',
                    style: FortunaTextStyles.titleMd.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/accounts'),
                    child: Text(
                      'VIEW ALL',
                      style: FortunaTextStyles.labelCaps.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...accounts.map((account) {
                final balance = balances[account.id] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        account.icon,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          account.name,
                          style: FortunaTextStyles.bodySm.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        '\$${_formatCurrency(balance)}',
                        style: FortunaTextStyles.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: balance < 0
                              ? colorScheme.error
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  static String _formatCurrency(double value) {
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
