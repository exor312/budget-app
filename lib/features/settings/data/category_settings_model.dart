import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../budget_goals/data/budget_goals_model.dart';

/// Manages custom expense and income category names stored in SharedPreferences.
/// Default categories come from BudgetGoalsModel and cannot be deleted.
class CategorySettingsModel extends ChangeNotifier {
  CategorySettingsModel() {
    _load();
  }

  static const String _expenseKey = 'custom_expense_categories';
  static const String _incomeKey = 'custom_income_categories';

  static const List<String> _defaultIncomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Other',
  ];

  List<String> _customExpenseCategories = [];
  List<String> _customIncomeCategories = [];

  /// All expense categories: defaults + custom.
  List<String> get allExpenseCategories => [
        ...BudgetGoalsModel.allCategoryNames,
        ..._customExpenseCategories,
      ];

  /// All income categories: defaults + custom.
  List<String> get allIncomeCategories => [
        ..._defaultIncomeCategories,
        ..._customIncomeCategories,
      ];

  /// Only the custom expense categories.
  List<String> get customExpenseCategories =>
      List.unmodifiable(_customExpenseCategories);

  /// Only the custom income categories.
  List<String> get customIncomeCategories =>
      List.unmodifiable(_customIncomeCategories);

  /// Default expense categories (from BudgetGoalsModel).
  List<String> get defaultExpenseCategories =>
      List.unmodifiable(BudgetGoalsModel.allCategoryNames);

  /// Default income categories.
  List<String> get defaultIncomeCategories =>
      List.unmodifiable(_defaultIncomeCategories);

  bool _isDefaultExpenseCategory(String name) =>
      BudgetGoalsModel.allCategoryNames.contains(name);

  bool _isDefaultIncomeCategory(String name) =>
      _defaultIncomeCategories.contains(name);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _customExpenseCategories =
        prefs.getStringList(_expenseKey) ?? <String>[];
    _customIncomeCategories =
        prefs.getStringList(_incomeKey) ?? <String>[];
    notifyListeners();
  }

  Future<void> _saveExpense() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_expenseKey, _customExpenseCategories);
  }

  Future<void> _saveIncome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_incomeKey, _customIncomeCategories);
  }

  /// Add a custom expense category. No-op if empty or duplicate.
  Future<void> addExpenseCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (allExpenseCategories.contains(trimmed)) return;
    _customExpenseCategories.add(trimmed);
    await _saveExpense();
    notifyListeners();
  }

  /// Add a custom income category. No-op if empty or duplicate.
  Future<void> addIncomeCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (allIncomeCategories.contains(trimmed)) return;
    _customIncomeCategories.add(trimmed);
    await _saveIncome();
    notifyListeners();
  }

  /// Remove a custom expense category. No-op if it's a default or doesn't exist.
  Future<void> removeExpenseCategory(String name) async {
    if (_isDefaultExpenseCategory(name)) return;
    final removed = _customExpenseCategories.remove(name);
    if (removed) {
      await _saveExpense();
      notifyListeners();
    }
  }

  /// Remove a custom income category. No-op if it's a default or doesn't exist.
  Future<void> removeIncomeCategory(String name) async {
    if (_isDefaultIncomeCategory(name)) return;
    final removed = _customIncomeCategories.remove(name);
    if (removed) {
      await _saveIncome();
      notifyListeners();
    }
  }
}
