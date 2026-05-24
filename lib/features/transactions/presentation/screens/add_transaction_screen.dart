import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../transactions/data/budget_model.dart';
import '../../../settings/data/category_settings_model.dart';
import '../../../settings/data/account_settings_model.dart';

/// Full-screen Add Transaction page.
/// Matches the reference design: expense/income toggle, custom keypad,
/// category chips, account selector, and submit button.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  static const String routePath = '/add-transaction';
  static const String routeName = 'AddTransaction';

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isExpense = true;
  String _currentAmount = '0';
  String? _selectedCategory;
  String _selectedAccountId = 'cash';
  DateTime _selectedDateTime = DateTime.now();

  /// Maps a category display name to its icon.
  IconData _iconForCategory(String name) {
    const iconMap = <String, IconData>{
      'Groceries': Icons.shopping_basket,
      'Fun': Icons.sports_esports,
      'Health': Icons.medical_services,
      'Rent': Icons.home,
      'Transport': Icons.directions_car,
      'Subs': Icons.subscriptions,
      'Food & Dining': Icons.restaurant,
      'Shopping': Icons.shopping_bag,
      'Entertainment': Icons.movie,
      'Bills': Icons.receipt,
      'Other': Icons.category,
      'Salary': Icons.payments,
      'Business': Icons.business_center,
      'Investment': Icons.trending_up,
    };
    return iconMap[name] ?? Icons.category;
  }

  /// Build the expense category list from defaults + custom categories.
  List<_CategoryInfo> _buildExpenseCategories(CategorySettingsModel settings) {
    final all = settings.allExpenseCategories;
    return all.map((name) {
      return _CategoryInfo(
        name: name,
        icon: _iconForCategory(name),
        categoryName: name,
      );
    }).toList();
  }

  /// Build the income category list from defaults + custom categories.
  List<_CategoryInfo> _buildIncomeCategories(CategorySettingsModel settings) {
    final all = settings.allIncomeCategories;
    return all.map((name) {
      return _CategoryInfo(
        name: name,
        icon: _iconForCategory(name),
        categoryName: name,
      );
    }).toList();
  }

  void _appendNum(String num) {
    setState(() {
      if (_currentAmount == '0' && num != '.') {
        _currentAmount = num;
      } else {
        if (num == '.' && _currentAmount.contains('.')) return;
        _currentAmount += num;
      }
    });
  }

  void _clearNum() {
    setState(() {
      if (_currentAmount.length > 1) {
        _currentAmount = _currentAmount.substring(0, _currentAmount.length - 1);
      } else {
        _currentAmount = '0';
      }
    });
  }

  Future<void> _submitTransaction(
    CategorySettingsModel categorySettings,
    AccountSettingsModel accountSettings,
  ) async {
    final amount = double.tryParse(_currentAmount);
    if (amount == null || amount <= 0) return;

    final signedAmount = _isExpense ? -amount : amount;

    // Look up the category name from the dynamic list
    final categories = _isExpense
        ? _buildExpenseCategories(categorySettings)
        : _buildIncomeCategories(categorySettings);
    final defaultCategory = 'Other';
    final selectedName = _selectedCategory ?? defaultCategory;

    // Verify the selected category exists in the list; fallback if not
    final matchedCategory = categories.firstWhere(
      (c) => c.name == selectedName,
      orElse: () =>
          _CategoryInfo(name: defaultCategory, icon: Icons.category, categoryName: defaultCategory),
    );

    // Validate the account exists
    final account = accountSettings.findById(_selectedAccountId);

    await context.read<BudgetModel>().addTransaction(
          amount: signedAmount,
          description: matchedCategory.categoryName,
          category: matchedCategory.categoryName,
          accountId: account.id,
          date: _selectedDateTime,
        );

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Consumer2<CategorySettingsModel, AccountSettingsModel>(
      builder: (context, categorySettings, accountSettings, _) {
        return Scaffold(
          backgroundColor: FortunaColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 48 : 20,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            _buildTypeToggle(),
                            const SizedBox(height: 32),
                            _buildAmountDisplay(),
                            const SizedBox(height: 24),
                            _buildDateTimeSection(),
                            const SizedBox(height: 16),
                            _buildAccountSection(accountSettings),
                            const SizedBox(height: 16),
                            _buildCategorySection(categorySettings),
                            const SizedBox(height: 24),
                            _buildKeypad(),
                            const SizedBox(height: 16),
                            _buildSubmitButton(categorySettings, accountSettings),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
            color: FortunaColors.onSurface,
          ),
          const Expanded(
            child: Center(
              child: Text(
                'New Entry',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.01,
                  color: FortunaColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: FortunaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(9999),
      ),
      constraints: const BoxConstraints(maxWidth: 320),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: 'Expense',
              isSelected: _isExpense,
              onTap: () {
                setState(() {
                  _isExpense = true;
                  _selectedCategory = null;
                });
              },
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: 'Income',
              isSelected: !_isExpense,
              onTap: () {
                setState(() {
                  _isExpense = false;
                  _selectedCategory = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '\$',
              style: FortunaTextStyles.displayLarge.copyWith(
                color: FortunaColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _currentAmount,
              style: FortunaTextStyles.displayLarge.copyWith(
                color: FortunaColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Enter amount',
          style: FortunaTextStyles.bodySm.copyWith(
            color: FortunaColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(AccountSettingsModel accountSettings) {
    final accounts = accountSettings.accounts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Account',
            style: FortunaTextStyles.labelCaps.copyWith(
              color: FortunaColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: accounts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final account = accounts[index];
              final isSelected = _selectedAccountId == account.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAccountId = account.id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? FortunaColors.secondaryContainer
                        : FortunaColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? FortunaColors.primary
                          : FortunaColors.outlineVariant.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        account.icon,
                        size: 20,
                        color: isSelected
                            ? FortunaColors.primary
                            : FortunaColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? FortunaColors.primary
                                  : FortunaColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            accountTypeLabel(account.type),
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? FortunaColors.primary.withValues(alpha: 0.7)
                                  : FortunaColors.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      } else {
        // User picked date but cancelled time — still update date
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            _selectedDateTime.hour,
            _selectedDateTime.minute,
          );
        });
      }
    }
  }

  Widget _buildDateTimeSection() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthStr = months[_selectedDateTime.month - 1];
    final dayStr = _selectedDateTime.day.toString();
    final yearStr = _selectedDateTime.year.toString();
    final hour = _selectedDateTime.hour;
    final minute = _selectedDateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final timeStr = '$displayHour:$minute $period';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Date & Time',
            style: FortunaTextStyles.labelCaps.copyWith(
              color: FortunaColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDateTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: FortunaColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: FortunaColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: FortunaColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$monthStr $dayStr, $yearStr  •  $timeStr',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: FortunaColors.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: FortunaColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(CategorySettingsModel settings) {
    final categories = _isExpense
        ? _buildExpenseCategories(settings)
        : _buildIncomeCategories(settings);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Select Category',
            style: FortunaTextStyles.labelCaps.copyWith(
              color: FortunaColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat.name;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _CategoryChip(
                  category: cat,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedCategory = isSelected ? null : cat.name;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          children: [
            _buildKeypadButton('1'),
            _buildKeypadButton('2'),
            _buildKeypadButton('3'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildKeypadButton('4'),
            _buildKeypadButton('5'),
            _buildKeypadButton('6'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildKeypadButton('7'),
            _buildKeypadButton('8'),
            _buildKeypadButton('9'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildKeypadButton('.'),
            _buildKeypadButton('0'),
            _buildBackspaceButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GestureDetector(
          onTap: () => _appendNum(label),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: FortunaColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: FortunaColors.primary.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: FortunaTextStyles.numericDisplay.copyWith(
                  color: FortunaColors.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GestureDetector(
          onTap: _clearNum,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: FortunaColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.backspace_outlined,
                color: FortunaColors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    CategorySettingsModel settings,
    AccountSettingsModel accountSettings,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _submitTransaction(settings, accountSettings),
        style: ElevatedButton.styleFrom(
          backgroundColor: FortunaColors.primary,
          foregroundColor: FortunaColors.onPrimary,
          elevation: 4,
          shadowColor: FortunaColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline),
            const SizedBox(width: 12),
            Text(
              'Add Transaction',
              style: FortunaTextStyles.titleMd.copyWith(
                color: FortunaColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? FortunaColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: FortunaColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: FortunaTextStyles.labelCaps.copyWith(
              color: isSelected
                  ? FortunaColors.onPrimary
                  : FortunaColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryInfo {
  final String name;
  final IconData icon;
  final String categoryName;
  const _CategoryInfo({required this.name, required this.icon, required this.categoryName});
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final _CategoryInfo category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected
                  ? FortunaColors.secondaryContainer
                  : FortunaColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? FortunaColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              category.icon,
              color: FortunaColors.primaryContainer,
              size: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: FortunaTextStyles.labelCaps.copyWith(
              color: FortunaColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
