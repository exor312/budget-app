import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// BudgetModel — ChangeNotifier managing transactions.
/// Migrated from the original main.dart, preserving all existing logic.
class BudgetModel extends ChangeNotifier {
  List<Transaction> _transactions = [];
  static const String _transactionsKey = 'budget_transactions';

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  double get totalIncome =>
      _transactions.where((t) => t.amount > 0).fold(0, (sum, t) => sum + t.amount);

  double get totalExpenses =>
      _transactions.where((t) => t.amount < 0).fold(0, (sum, t) => sum + t.amount.abs());

  double get netBalance =>
      _transactions.fold(0, (sum, t) => sum + t.amount);

  /// Monthly spending (current month expenses only).
  double get monthlySpending {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.amount < 0 &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0, (sum, t) => sum + t.amount.abs());
  }

  /// Group expenses by category keyword for spending categories display.
  List<SpendingCategory> get spendingCategories {
    final Map<String, double> categoryTotals = {};
    final expenseTransactions = _transactions.where((t) => t.amount < 0);

    for (final t in expenseTransactions) {
      final category = _categorize(t.description);
      categoryTotals[category] = (categoryTotals[category] ?? 0) + t.amount.abs();
    }

    final total = categoryTotals.values.fold(0.0, (sum, v) => sum + v);
    if (total == 0) return _defaultCategories;

    final icons = {
      'Food & Dining': Icons.restaurant,
      'Transport': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Entertainment': Icons.movie,
      'Bills': Icons.receipt,
      'Other': Icons.category,
    };

    return categoryTotals.entries.map((e) {
      return SpendingCategory(
        name: e.key,
        percentage: (e.value / total * 100).round(),
        icon: icons[e.key] ?? Icons.category,
      );
      // Sort by percentage descending
    }).toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
  }

  String _categorize(String description) {
    final lower = description.toLowerCase();
    if (lower.contains('food') || lower.contains('restaurant') || lower.contains('grocery') || lower.contains('meal')) {
      return 'Food & Dining';
    }
    if (lower.contains('gas') || lower.contains('uber') || lower.contains('car') || lower.contains('transport')) {
      return 'Transport';
    }
    if (lower.contains('shop') || lower.contains('buy') || lower.contains('purchase') || lower.contains('amazon')) {
      return 'Shopping';
    }
    if (lower.contains('movie') || lower.contains('netflix') || lower.contains('game') || lower.contains('fun')) {
      return 'Entertainment';
    }
    if (lower.contains('bill') || lower.contains('rent') || lower.contains('electric') || lower.contains('water')) {
      return 'Bills';
    }
    return 'Other';
  }

  /// Default categories when no transactions exist.
  List<SpendingCategory> get _defaultCategories => [
        SpendingCategory(name: 'Food & Dining', percentage: 40, icon: Icons.restaurant),
        SpendingCategory(name: 'Transport', percentage: 20, icon: Icons.directions_car),
        SpendingCategory(name: 'Shopping', percentage: 15, icon: Icons.shopping_bag),
      ];

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_transactionsKey);
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      _transactions = decoded
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      _transactions.map((t) => t.toJson()).toList(),
    );
    await prefs.setString(_transactionsKey, jsonString);
  }

  void addTransaction({
    required double amount,
    required String description,
    String category = 'Other',
  }) {
    final transaction = Transaction(
      amount: amount,
      description: description,
      date: DateTime.now(),
      category: category,
    );
    _transactions.add(transaction);
    _saveTransactions();
    notifyListeners();
  }

  void removeTransaction(int index) {
    final originalIndex = _transactions.length - 1 - index;
    if (originalIndex >= 0 && originalIndex < _transactions.length) {
      _transactions.removeAt(originalIndex);
      _saveTransactions();
      notifyListeners();
    }
  }

  void clearAllTransactions() {
    _transactions.clear();
    _saveTransactions();
    notifyListeners();
  }
}

/// Transaction model — preserves existing JSON serialization.
class Transaction {
  final double amount;
  final String description;
  final DateTime date;
  final String category;

  Transaction({
    required this.amount,
    required this.description,
    required this.date,
    this.category = 'Other',
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String? ?? 'Other',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
    };
  }
}

/// Spending category for dashboard display.
class SpendingCategory {
  final String name;
  final int percentage;
  final IconData icon;

  const SpendingCategory({
    required this.name,
    required this.percentage,
    required this.icon,
  });
}
