import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../transactions/data/budget_model.dart';
import '../../../settings/data/category_settings_model.dart';

/// Full-screen Add Transaction page.
/// Matches the reference design: expense/income toggle, custom keypad,
/// category chips, and submit button.
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

  Future<void> _submitTransaction(CategorySettingsModel settings) async {
    final amount = double.tryParse(_currentAmount);
    if (amount == null || amount <= 0) return;

    final signedAmount = _isExpense ? -amount : amount;
    final displayCategory = _isExpense
        ? (_selectedCategory ?? 'Other')
        : 'Income';
    // Look up the category name from the dynamic list
    final categories = _buildExpenseCategories(settings);
    final category = _isExpense
        ? categories
            .firstWhere((c) => c.name == displayCategory,
                orElse: () => _CategoryInfo(name: 'Other', icon: Icons.category, categoryName: 'Other'))
            .categoryName
        : 'Income';

    await context.read<BudgetModel>().addTransaction(
          amount: signedAmount,
          description: category,
          category: category,
        );

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Consumer<CategorySettingsModel>(
      builder: (context, settings, _) {
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
                      child: Padding(
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
                            _buildCategorySection(settings),
                            const SizedBox(height: 24),
                            _buildKeypad(),
                            const Spacer(),
                            _buildSubmitButton(settings),
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
              onTap: () => setState(() => _isExpense = true),
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: 'Income',
              isSelected: !_isExpense,
              onTap: () => setState(() => _isExpense = false),
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

  Widget _buildCategorySection(CategorySettingsModel settings) {
    final categories = _buildExpenseCategories(settings);
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

  Widget _buildSubmitButton(CategorySettingsModel settings) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _submitTransaction(settings),
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
                color: isSelected
                    ? FortunaColors.primary
                    : Colors.transparent,
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
