import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../transactions/data/budget_model.dart';
import 'savings_goal_model.dart';

/// BudgetGoalsModel — ChangeNotifier that computes budget categories,
/// spending totals, and savings goals from real BudgetModel transaction data.
/// Now supports editing category limits, adding/removing custom categories.
class BudgetGoalsModel extends ChangeNotifier {
  BudgetGoalsModel({required BudgetModel budgetModel})
      : _budgetModel = budgetModel {
    _budgetModel.addListener(_onBudgetModelChanged);
    _recompute();
    _loadCategories();
  }

  final BudgetModel _budgetModel;

  List<BudgetCategory> _categories = [];
  double _totalMonthlyLimit = 0.0;
  double _totalSpent = 0.0;
  List<SavingsGoal> _goals = [];

  // Custom category overrides stored in SharedPreferences
  Map<String, double> _customLimits = {};
  List<String> _customCategories = [];
  static const String _customLimitsKey = 'custom_category_limits';
  static const String _customCategoriesKey = 'custom_categories';

  List<BudgetCategory> get categories => List.unmodifiable(_categories);
  double get totalMonthlyLimit => _totalMonthlyLimit;
  double get totalSpent => _totalSpent;
  double get remainingAmount => _totalMonthlyLimit - _totalSpent;
  double get utilizationPercent => _totalMonthlyLimit > 0
      ? (_totalSpent / _totalMonthlyLimit * 100).round().toDouble()
      : 0.0;
  List<SavingsGoal> get savingsGoals => List.unmodifiable(_goals);

  /// Default category names from settings.
  List<String> get _allCategoryNames {
    return [...allCategoryNames, ..._customCategories];
  }

  /// Get the effective limit for a category (custom override or default).
  double _getLimit(String name) {
    return _customLimits[name] ?? _defaultLimits[name] ?? 500.0;
  }

  void _onBudgetModelChanged() {
    _recompute();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    // Load custom limits from SharedPreferences
    final limitsJson = prefs.getString(_customLimitsKey);
    if (limitsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(limitsJson);
      final loadedLimits = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      // Merge: keep in-memory values, add any from disk that aren't already set
      for (final entry in loadedLimits.entries) {
        _customLimits.putIfAbsent(entry.key, () => entry.value);
      }
    }
    // Load custom categories from SharedPreferences
    final stored = prefs.getStringList(_customCategoriesKey) ?? <String>[];
    // Merge: add any from disk that aren't already in memory
    for (final name in stored) {
      if (!_customCategories.contains(name)) {
        _customCategories.add(name);
      }
    }
    _recompute();
  }

  Future<void> _saveCustomLimits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customLimitsKey, jsonEncode(_customLimits));
  }

  Future<void> _saveCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_customCategoriesKey, _customCategories);
  }

  void _recompute() {
    final now = DateTime.now();
    final currentMonthExpenses = _budgetModel.transactions
        .where((t) =>
            t.amount < 0 &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .toList();

    // Group expenses by stored category
    final Map<String, double> categorySpent = {};
    for (final t in currentMonthExpenses) {
      final category = t.category.isNotEmpty ? t.category : 'Other';
      categorySpent[category] = (categorySpent[category] ?? 0) + t.amount.abs();
    }

    // Build categories with configurable limits and real spent amounts
    _categories = _allCategoryNames.map((name) {
      final spent = categorySpent[name] ?? 0.0;
      final limit = _getLimit(name);
      return BudgetCategory(
        name: name,
        description: _categoryDescriptions[name] ?? '',
        icon: _categoryIcons[name] ?? Icons.category,
        spent: spent,
        limit: limit,
        isDefault: allCategoryNames.contains(name),
      );
    }).toList();

    // Total monthly limit = sum of all category limits
    _totalMonthlyLimit =
        _allCategoryNames.fold(0.0, (sum, name) => sum + _getLimit(name));

    // Total spent = sum of all current-month expenses
    _totalSpent = currentMonthExpenses.fold(0.0, (sum, t) => sum + t.amount.abs());

    notifyListeners();
  }

  // --- Category CRUD ---

  /// Update the spending limit for a category (default or custom).
  Future<bool> updateCategoryLimit(String name, double limit) async {
    if (limit <= 0) return false;
    _customLimits[name] = limit;
    await _saveCustomLimits();
    _recompute();
    return true;
  }

  /// Add a new custom category. Returns false if duplicate name.
  Future<bool> addCategory(String name, {double limit = 500.0}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    if (_allCategoryNames.contains(trimmed)) return false;
    _customCategories.add(trimmed);
    _customLimits[trimmed] = limit;
    await _saveCustomCategories();
    await _saveCustomLimits();
    _recompute();
    return true;
  }

  /// Remove a custom category. Returns false if it's a default category.
  Future<bool> removeCategory(String name) async {
    if (allCategoryNames.contains(name)) return false;
    final removed = _customCategories.remove(name);
    if (removed) {
      _customLimits.remove(name);
      await _saveCustomCategories();
      await _saveCustomLimits();
      _recompute();
      return true;
    }
    return false;
  }

  /// Check if a category is a default (non-deletable).
  bool isDefaultCategory(String name) => allCategoryNames.contains(name);

  /// All supported default category names.
  static const List<String> allCategoryNames = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Other',
  ];

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
    this.isDefault = false,
  });

  final String name;
  final String description;
  final IconData icon;
  final double spent;
  final double limit;
  final bool isDefault;

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
