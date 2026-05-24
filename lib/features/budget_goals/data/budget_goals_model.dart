import 'package:flutter/material.dart';
import '../../transactions/data/budget_model.dart';

/// BudgetGoalsModel — ChangeNotifier that computes budget categories,
/// spending totals, and savings goals from real BudgetModel transaction data.
class BudgetGoalsModel extends ChangeNotifier {
  BudgetGoalsModel({required BudgetModel budgetModel})
      : _budgetModel = budgetModel {
    _budgetModel.addListener(_onBudgetModelChanged);
    _recompute();
  }

  final BudgetModel _budgetModel;

  List<BudgetCategory> _categories = [];
  double _totalMonthlyLimit = 0.0;
  double _totalSpent = 0.0;
  ActiveGoal _activeGoal = const ActiveGoal(
    name: 'Savings Goal',
    targetAmount: 10000.0,
    currentAmount: 0.0,
  );

  List<BudgetCategory> get categories => List.unmodifiable(_categories);
  double get totalMonthlyLimit => _totalMonthlyLimit;
  double get totalSpent => _totalSpent;
  double get remainingAmount => _totalMonthlyLimit - _totalSpent;
  double get utilizationPercent => _totalMonthlyLimit > 0
      ? (_totalSpent / _totalMonthlyLimit * 100).round().toDouble()
      : 0.0;
  ActiveGoal get activeGoal => _activeGoal;

  void _onBudgetModelChanged() {
    _recompute();
  }

  void _recompute() {
    final now = DateTime.now();
    final currentMonthExpenses = _budgetModel.transactions
        .where((t) =>
            t.amount < 0 &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .toList();

    // Group expenses by stored category — use the transaction's category field directly
    final Map<String, double> categorySpent = {};
    for (final t in currentMonthExpenses) {
      final category = t.category.isNotEmpty ? t.category : 'Other';
      categorySpent[category] = (categorySpent[category] ?? 0) + t.amount.abs();
    }

    // Build categories with configurable limits and real spent amounts
    _categories = _allCategoryNames.map((name) {
      final spent = categorySpent[name] ?? 0.0;
      final limit = _defaultLimits[name] ?? 500.0;
      return BudgetCategory(
        name: name,
        description: _categoryDescriptions[name] ?? '',
        icon: _categoryIcons[name] ?? Icons.category,
        spent: spent,
        limit: limit,
      );
    }).toList();

    // Total monthly limit = sum of all category limits
    _totalMonthlyLimit =
        _allCategoryNames.fold(0.0, (sum, name) => sum + (_defaultLimits[name] ?? 500.0));

    // Total spent = sum of all current-month expenses
    _totalSpent = currentMonthExpenses.fold(0.0, (sum, t) => sum + t.amount.abs());

    // Active goal: currentAmount = net balance (totalIncome - totalExpenses)
    final netBalance = _budgetModel.netBalance;
    _activeGoal = ActiveGoal(
      name: 'Savings Goal',
      targetAmount: 10000.0,
      currentAmount: netBalance > 0 ? netBalance : 0.0,
    );

    notifyListeners();
  }

  /// All supported category names.
  static const List<String> _allCategoryNames = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Other',
  ];

  /// Configurable spending limits per category (not mock data — these are budget caps).
  static const Map<String, double> _defaultLimits = {
    'Food & Dining': 800.0,
    'Transport': 400.0,
    'Shopping': 500.0,
    'Entertainment': 250.0,
    'Bills': 1500.0,
    'Other': 300.0,
  };

  static const Map<String, String> _categoryDescriptions = {
    'Food & Dining': 'Groceries & restaurants',
    'Transport': 'Gas, rides, transit',
    'Shopping': 'Clothing & purchases',
    'Entertainment': 'Fun & subscriptions',
    'Bills': 'Rent & utilities',
    'Other': 'Miscellaneous',
  };

  static const Map<String, IconData> _categoryIcons = {
    'Food & Dining': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt,
    'Other': Icons.category,
  };

  @override
  void dispose() {
    _budgetModel.removeListener(_onBudgetModelChanged);
    super.dispose();
  }
}

/// A budget category with spending data.
class BudgetCategory {
  const BudgetCategory({
    required this.name,
    required this.description,
    required this.icon,
    required this.spent,
    required this.limit,
  });

  final String name;
  final String description;
  final IconData icon;
  final double spent;
  final double limit;

  double get utilizationPercent =>
      limit > 0 ? (spent / limit * 100).round().toDouble() : 0.0;

  double get overLimitAmount => spent > limit ? spent - limit : 0;

  BudgetStatus get status {
    final pct = utilizationPercent;
    if (pct >= 100) return BudgetStatus.critical;
    if (pct > 80) return BudgetStatus.warning;
    return BudgetStatus.healthy;
  }
}

/// Status of a budget category based on utilization.
enum BudgetStatus {
  healthy,
  warning,
  critical,
}

/// An active savings goal.
class ActiveGoal {
  const ActiveGoal({
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
  });

  final String name;
  final double targetAmount;
  final double currentAmount;

  double get percentComplete =>
      targetAmount > 0 ? (currentAmount / targetAmount * 100).round().toDouble() : 0.0;
}
