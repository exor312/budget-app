import 'package:flutter/material.dart';

/// BudgetGoalsModel — ChangeNotifier providing sample budget categories
/// and active savings goal data for the Budgets & Goals screen.
class BudgetGoalsModel extends ChangeNotifier {
  BudgetGoalsModel() {
    _categories = _defaultCategories;
    _totalMonthlyLimit = 4800.0;
    _totalSpent = _categories.fold(0.0, (sum, c) => sum + c.spent);
    _activeGoal = const ActiveGoal(
      name: 'New Car Fund',
      targetAmount: 15000.0,
      currentAmount: 8400.0,
    );
  }

  late List<BudgetCategory> _categories;
  late double _totalMonthlyLimit;
  late double _totalSpent;
  late ActiveGoal _activeGoal;

  List<BudgetCategory> get categories => List.unmodifiable(_categories);
  double get totalMonthlyLimit => _totalMonthlyLimit;
  double get totalSpent => _totalSpent;
  double get remainingAmount => _totalMonthlyLimit - _totalSpent;
  double get utilizationPercent => _totalMonthlyLimit > 0
      ? (_totalSpent / _totalMonthlyLimit * 100).round().toDouble()
      : 0.0;
  ActiveGoal get activeGoal => _activeGoal;

  static const List<BudgetCategory> _defaultCategories = [
    BudgetCategory(
      name: 'Groceries',
      description: 'Daily essentials',
      icon: Icons.restaurant,
      spent: 452.20,
      limit: 800.0,
    ),
    BudgetCategory(
      name: 'Entertainment',
      description: 'Movies, dining out',
      icon: Icons.movie,
      spent: 210.0,
      limit: 250.0,
    ),
    BudgetCategory(
      name: 'Personal Care',
      description: 'Clothing & self-care',
      icon: Icons.shopping_cart,
      spent: 325.40,
      limit: 300.0,
    ),
    BudgetCategory(
      name: 'Travel',
      description: 'Commute & holidays',
      icon: Icons.flight_takeoff,
      spent: 150.0,
      limit: 600.0,
    ),
  ];
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
