import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../settings/data/category_settings_model.dart';
import '../../../settings/data/account_settings_model.dart';
import '../widgets/category_list_item.dart';

/// Settings screen — manage custom expense/income categories and accounts.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String routePath = '/settings';
  static const String routeName = 'Settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _expenseController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  String _selectedAccountType = 'debit';

  @override
  void dispose() {
    _expenseController.dispose();
    _incomeController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: FortunaColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildAccountsSection(context),
                    const SizedBox(height: 32),
                    _buildExpenseSection(context),
                    const SizedBox(height: 32),
                    _buildIncomeSection(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Settings',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: FortunaColors.primary,
      ),
    );
  }

  Widget _buildAccountsSection(BuildContext context) {
    return Consumer<AccountSettingsModel>(
      builder: (context, model, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: FortunaColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildAddAccountRow(model),
            const SizedBox(height: 12),
            ...model.accounts.map((account) {
              final isDefault = account.id == 'cash';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      account.icon,
                      size: 20,
                      color: FortunaColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1C1B1F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            accountTypeLabel(account.type),
                            style: TextStyle(
                              fontSize: 12,
                              color: FortunaColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isDefault)
                      IconButton(
                        onPressed: () => model.removeAccount(account.id),
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFB3261E)),
                        tooltip: 'Delete account',
                      ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildAddAccountRow(AccountSettingsModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _accountController,
                decoration: InputDecoration(
                  hintText: 'Add account (e.g. Chase Debit)',
                  filled: true,
                  fillColor: FortunaColors.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: FortunaColors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: FortunaColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: FortunaColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _addAccount(model),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addAccount(model),
              style: ElevatedButton.styleFrom(
                backgroundColor: FortunaColors.primary,
                foregroundColor: FortunaColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Type selector
        Row(
          children: [
            Text(
              'Type: ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: FortunaColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedAccountType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: FortunaColors.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: FortunaColors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: FortunaColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: FortunaColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: accountTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      accountTypeLabel(type),
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedAccountType = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _addAccount(AccountSettingsModel model) async {
    final name = _accountController.text.trim();
    if (name.isEmpty) return;
    await model.addAccount(name: name, type: _selectedAccountType);
    _accountController.clear();
  }

  Widget _buildExpenseSection(BuildContext context) {
    return Consumer<CategorySettingsModel>(
      builder: (context, model, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: FortunaColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildAddRow(
              controller: _expenseController,
              hint: 'Add expense category',
              onAdd: () async {
                await model.addExpenseCategory(_expenseController.text);
                _expenseController.clear();
              },
            ),
            const SizedBox(height: 12),
            ...model.allExpenseCategories.map((name) {
              final isDefault = !model.customExpenseCategories.contains(name);
              return CategoryListItem(
                key: ValueKey('expense_$name'),
                name: name,
                isDeletable: !isDefault,
                onDelete: () => model.removeExpenseCategory(name),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildIncomeSection(BuildContext context) {
    return Consumer<CategorySettingsModel>(
      builder: (context, model, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: FortunaColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildAddRow(
              controller: _incomeController,
              hint: 'Add income category',
              onAdd: () async {
                await model.addIncomeCategory(_incomeController.text);
                _incomeController.clear();
              },
            ),
            const SizedBox(height: 12),
            ...model.allIncomeCategories.map((name) {
              final isDefault = !model.customIncomeCategories.contains(name);
              return CategoryListItem(
                key: ValueKey('income_$name'),
                name: name,
                isDeletable: !isDefault,
                onDelete: () => model.removeIncomeCategory(name),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildAddRow({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: FortunaColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: FortunaColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: FortunaColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: FortunaColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: FortunaColors.primary,
            foregroundColor: FortunaColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
