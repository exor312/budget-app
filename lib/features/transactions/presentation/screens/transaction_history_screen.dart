import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../transactions/data/budget_model.dart';
import '../widgets/transaction_list_item.dart';

/// Transaction history screen — view and delete transactions.
/// Matches the Fortuna reference design with search, filters, and date grouping.
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  static const String routePath = '/transactions';
  static const String routeName = 'Transactions';

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All'; // All, This Month, Income, Expense

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Group transactions by date relative to now.
  Map<String, List<MapEntry<int, Transaction>>> _groupTransactions(
      List<Transaction> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<MapEntry<int, Transaction>>> groups = {};

    for (int i = 0; i < transactions.length; i++) {
      final t = transactions[i];
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
      groups[groupKey]!.add(MapEntry(i, t));
    }

    return groups;
  }

  /// Filter transactions based on active filter and search query.
  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    var filtered = transactions.where((t) {
      // Search filter
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        if (!t.description.toLowerCase().contains(query) &&
            !t.category.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Chip filter
      switch (_activeFilter) {
        case 'This Month':
          return t.date.year == now.year && t.date.month == now.month;
        case 'Income':
          return t.amount > 0;
        case 'Expense':
          return t.amount < 0;
        default:
          return true;
      }
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FortunaColors.surface,
      body: Column(
        children: [
          // Sticky Header
          _buildHeader(),
          // Search & Filter Bar
          _buildSearchAndFilters(),
          // Transaction List
          Expanded(
            child: Consumer<BudgetModel>(
              builder: (context, model, _) {
                final filtered = _filterTransactions(
                  model.transactions.reversed.toList(),
                );

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                // Group by date
                final groups = _groupTransactions(filtered);
                final groupKeys = groups.keys.toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: groupKeys.length,
                  itemBuilder: (context, groupIndex) {
                    final groupKey = groupKeys[groupIndex];
                    final entries = groups[groupKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: EdgeInsets.only(
                            top: groupIndex == 0 ? 16 : 24,
                            bottom: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                groupKey,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: FortunaColors.onSurface,
                                ),
                              ),
                              if (groupKey == 'Today')
                                Text(
                                  _formatDateShort(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.05,
                                    color: FortunaColors.outline,
                                  ),
                                ),
                              if (groupKey == 'Yesterday')
                                Text(
                                  _formatDateShort(
                                    DateTime.now().subtract(
                                      const Duration(days: 1),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.05,
                                    color: FortunaColors.outline,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Transaction items
                        ...entries.map((entry) {
                          final transaction = entry.value;
                          final originalIndex = model.transactions.length -
                              1 -
                              entry.key;
                          return TransactionListItem(
                            transaction: transaction,
                            onDelete: () {
                              model.removeTransaction(originalIndex);
                            },
                          );
                        }),
                        if (groupIndex == groupKeys.length - 1)
                          const SizedBox(height: 100),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        backgroundColor: FortunaColors.primary,
        foregroundColor: FortunaColors.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
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
                    'Fortuna',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: FortunaColors.primary,
                      letterSpacing: -0.02,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
                color: FortunaColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search transactions, merchants...',
              hintStyle: TextStyle(color: FortunaColors.outline),
              prefixIcon: Icon(Icons.search, color: FortunaColors.outline),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Filters', icon: Icons.tune),
                const SizedBox(width: 8),
                _buildFilterChip('This Month'),
                const SizedBox(width: 8),
                _buildFilterChip('Income'),
                const SizedBox(width: 8),
                _buildFilterChip('Expense'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {IconData? icon}) {
    final isActive = _activeFilter == label ||
        (label == 'Filters' && _activeFilter != 'All');

    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == 'Filters') {
            // Toggle filters - reset to All
            _activeFilter = 'All';
          } else {
            _activeFilter = _activeFilter == label ? 'All' : label;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? FortunaColors.secondaryContainer
              : FortunaColors.surfaceContainer,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : FortunaColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: FortunaColors.onSecondaryContainer),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.05,
                color: isActive
                    ? FortunaColors.onSecondaryContainer
                    : FortunaColors.onSurfaceVariant,
              ),
            ),
          ],
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
            Icons.receipt_long_outlined,
            color: FortunaColors.onSurfaceVariant,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              color: FortunaColors.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or add a transaction',
            style: TextStyle(
              color: FortunaColors.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: const _TransactionFormContent(),
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

  String _formatDateShort(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _TransactionFormContent extends StatefulWidget {
  const _TransactionFormContent();

  @override
  State<_TransactionFormContent> createState() =>
      _TransactionFormContentState();
}

class _TransactionFormContentState extends State<_TransactionFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isIncome = true;
  String _selectedCategory = 'Other';

  static const List<String> _expenseCategories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Entertainment',
    'Health',
    'Bills',
    'Other',
  ];

  static const List<String> _incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;

      context.read<BudgetModel>().addTransaction(
            amount: _isIncome ? amount : -amount,
            description: description,
            category: _isIncome ? 'Income' : _selectedCategory,
          );

      _amountController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _isIncome ? _incomeCategories : _expenseCategories;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FortunaColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: FortunaColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Income/Expense toggle
            Row(
              children: [
                const Text('Type:'),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Income'),
                  selected: _isIncome,
                  selectedColor: FortunaColors.secondaryContainer,
                  onSelected: (selected) {
                    setState(() {
                      _isIncome = true;
                      _selectedCategory = 'Other';
                    });
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Expense'),
                  selected: !_isIncome,
                  selectedColor: FortunaColors.secondaryContainer,
                  onSelected: (selected) {
                    setState(() {
                      _isIncome = false;
                      _selectedCategory = 'Food & Dining';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Category dropdown
            if (!_isIncome) ...[
              const Text('Category:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _addTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FortunaColors.primary,
                  foregroundColor: FortunaColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
