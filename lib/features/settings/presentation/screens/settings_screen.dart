import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_model.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildThemeSection(context),
                    const SizedBox(height: 32),
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

  Widget _buildThemeSection(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              themeModel,
              ThemeMode.light,
              Icons.light_mode_outlined,
              'Light',
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              context,
              themeModel,
              ThemeMode.dark,
              Icons.dark_mode_outlined,
              'Dark',
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              context,
              themeModel,
              ThemeMode.system,
              Icons.brightness_auto,
              'System',
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeModel themeModel,
    ThemeMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = themeModel.themeMode == mode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => themeModel.setThemeMode(mode),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                : Theme.of(context).colorScheme.surfaceContainerLowest,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Settings',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
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
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildAddAccountRow(context, model),
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            accountTypeLabel(account.type),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isDefault)
                      IconButton(
                        onPressed: () => model.removeAccount(account.id),
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
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

  Widget _buildAddAccountRow(BuildContext context, AccountSettingsModel model) {
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
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedAccountType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
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
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildAddRow(
              context: context,
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
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildAddRow(
              context: context,
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
    required BuildContext context,
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
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
