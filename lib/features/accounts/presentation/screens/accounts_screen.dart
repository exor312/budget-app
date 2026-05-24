import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../settings/data/account_settings_model.dart';
import '../../../transactions/data/budget_model.dart';
import '../widgets/account_balance_card.dart';

/// Dedicated Accounts page showing all accounts with computed balances.
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  static const String routePath = '/accounts';
  static const String routeName = 'Accounts';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: FortunaColors.surface,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer2<AccountSettingsModel, BudgetModel>(
              builder: (context, accountModel, budgetModel, _) {
                final balances = budgetModel.getBalancePerAccount();
                final accounts = accountModel.accounts;

                if (accounts.length == 1 && (balances[accounts.first.id] ?? 0.0) == 0.0) {
                  return _buildEmptyState();
                }

                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 48 : 0,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            ...accounts.map((account) {
                              final balance = balances[account.id] ?? 0.0;
                              return GestureDetector(
                                onTap: () {
                                  context.push('/accounts/${account.id}');
                                },
                                child: AccountBalanceCard(
                                  account: account,
                                  balance: balance,
                                ),
                              );
                            }),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: FortunaColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: FortunaColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: FortunaColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Accounts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: FortunaColors.primary,
                      letterSpacing: -0.02,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: FortunaColors.onSurfaceVariant,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No accounts yet',
            style: TextStyle(
              color: FortunaColors.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add accounts in Settings to track balances',
            style: TextStyle(
              color: FortunaColors.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
