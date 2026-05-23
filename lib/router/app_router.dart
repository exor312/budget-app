import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/transactions/presentation/screens/transaction_history_screen.dart';
import '../features/transactions/data/budget_model.dart';

/// App router configuration using go_router with ShellRoute for tab navigation.
final GoRouter appRouter = GoRouter(
  initialLocation: DashboardScreen.routePath,
  debugLogDiagnostics: false,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return _ShellScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: DashboardScreen.routePath,
          name: DashboardScreen.routeName,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: TransactionHistoryScreen.routePath,
          name: TransactionHistoryScreen.routeName,
          builder: (context, state) => const TransactionHistoryScreen(),
        ),
      ],
    ),
  ],
);

/// Shell scaffold that provides bottom navigation bar around tab content.
class _ShellScaffold extends StatefulWidget {
  const _ShellScaffold({required this.child});
  final Widget child;

  @override
  State<_ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<_ShellScaffold> {
  int _currentIndex = 0;

  static const List<_TabInfo> _tabs = [
    _TabInfo(icon: Icons.home, label: 'Home', path: '/dashboard'),
    _TabInfo(icon: Icons.receipt_long, label: 'History', path: '/transactions'),
    _TabInfo(icon: Icons.add_circle, label: 'Add', path: '/add'),
    _TabInfo(icon: Icons.track_changes, label: 'Budgets', path: '/budgets'),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine current tab from location
    final location = GoRouterState.of(context).uri.toString();
    _currentIndex = _tabs.indexWhere((tab) => location.startsWith(tab.path));
    if (_currentIndex < 0) _currentIndex = 0;

    // For Add tab, show the dashboard with bottom sheet overlay
    if (location.startsWith('/add')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddTransactionSheet(context);
      });
      // Redirect to dashboard after triggering add
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: _buildBottomNav(context),
      );
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF041627).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isActive = _currentIndex == index;

              return GestureDetector(
                onTap: () {
                  if (tab.path == '/add') {
                    context.go('/dashboard');
                    _showAddTransactionSheet(context);
                  } else {
                    context.go(tab.path);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: isActive
                      ? BoxDecoration(
                          color: const Color(0xFFD5E0F7),
                          borderRadius: BorderRadius.circular(9999),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        color: isActive
                            ? const Color(0xFF586377)
                            : const Color(0xFF44474C),
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.05,
                          color: isActive
                              ? const Color(0xFF586377)
                              : const Color(0xFF44474C),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: const _TransactionFormSheet(),
      ),
    );
  }
}

class _TabInfo {
  final IconData icon;
  final String label;
  final String path;
  const _TabInfo({required this.icon, required this.label, required this.path});
}

/// Reuse the transaction form sheet from the screen file.
class _TransactionFormSheet extends StatefulWidget {
  const _TransactionFormSheet();

  @override
  State<_TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<_TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isIncome = true;
  String _selectedCategory = 'Other';

  static const List<String> _expenseCategories = [
    'Food & Dining', 'Transport', 'Shopping', 'Entertainment', 'Health', 'Bills', 'Other',
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Transaction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF041627))),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount', prefixText: '\$',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter an amount';
                if (double.tryParse(value) == null) return 'Please enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a description';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(children: [
              const Text('Type:'),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('Income'), selected: _isIncome,
                selectedColor: const Color(0xFFD5E0F7),
                onSelected: (s) => setState(() => _isIncome = true),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Expense'), selected: !_isIncome,
                selectedColor: const Color(0xFFD5E0F7),
                onSelected: (s) => setState(() => _isIncome = false),
              ),
            ]),
            const SizedBox(height: 16),
            if (!_isIncome) ...[
              const Text('Category:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) { if (v != null) setState(() => _selectedCategory = v); },
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: _addTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF041627),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
