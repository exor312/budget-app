import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../settings/data/account_settings_model.dart';
import '../../../transactions/data/budget_model.dart';
import '../widgets/account_transaction_list.dart';
import '../widgets/account_statistics_card.dart';
import '../widgets/adjustment_dialog.dart';
import '../widgets/transfer_dialog.dart';

/// Account Detail screen showing transaction history, statistics,
/// and actions for adjustments and transfers.
class AccountDetailScreen extends StatelessWidget {
  const AccountDetailScreen({
    super.key,
    required this.accountId,
  });

  final String accountId;

  static const String routePath = '/accounts/:accountId';
  static const String routeName = 'AccountDetail';

  @override
  Widget build(BuildContext context) {
    return Consumer2<BudgetModel, AccountSettingsModel>(
      builder: (context, budgetModel, accountModel, _) {
        final account = accountModel.findById(accountId);
        final balance = budgetModel.getBalancePerAccount()[account.id] ?? 0.0;
        final transactions = budgetModel.transactions;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Column(
            children: [
              _buildHeader(context, account, balance),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        children: [
                          AccountStatisticsCard(
                            accountId: account.id,
                            transactions: transactions,
                          ),
                          const SizedBox(height: 8),
                          // Action buttons
                          _buildActionButtons(context, account),
                          const SizedBox(height: 16),
                          // Transaction list
                          AccountTransactionList(
                            accountId: account.id,
                            transactions: transactions,
                            onDelete: (originalIndex) {
                              budgetModel.removeTransaction(originalIndex);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Account account,
    double balance,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isNegative = balance < 0;

    return Container(
      color: cs.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: cs.primary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                            letterSpacing: -0.02,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          accountTypeLabel(account.type),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '\$${_formatCurrency(balance)}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: isNegative
                        ? cs.error
                        : cs.onSurface,
                    letterSpacing: -0.02,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Account account) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ChangeNotifierProvider.value(
                    value: context.read<BudgetModel>(),
                    child: ChangeNotifierProvider.value(
                      value: context.read<AccountSettingsModel>(),
                      child: AdjustmentDialog(
                        accountId: account.id,
                        accountName: account.name,
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Adjust'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.surfaceContainerHighest,
                foregroundColor: cs.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ChangeNotifierProvider.value(
                    value: context.read<BudgetModel>(),
                    child: ChangeNotifierProvider.value(
                      value: context.read<AccountSettingsModel>(),
                      child: TransferDialog(
                        sourceAccountId: account.id,
                        sourceAccountName: account.name,
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('Transfer'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.surface,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
