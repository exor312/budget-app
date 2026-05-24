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

  /// Group expenses by stored category for spending categories display.
  /// Uses the transaction's category field directly — no keyword re-categorization.
  List<SpendingCategory> get spendingCategories {
    final Map<String, double> categoryTotals = {};
    final expenseTransactions = _transactions.where((t) => t.amount < 0);

    for (final t in expenseTransactions) {
      final category = t.category.isNotEmpty ? t.category : 'Other';
      categoryTotals[category] = (categoryTotals[category] ?? 0) + t.amount.abs();
    }

    final total = categoryTotals.values.fold(0.0, (sum, v) => sum + v);
    if (total == 0) return [];

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
        amount: e.value,
        percentage: (e.value / total * 100).round(),
        icon: icons[e.key] ?? Icons.category,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

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

  Future<void> addTransaction({
    required double amount,
    required String description,
    String category = 'Other',
    String accountId = 'cash',
  }) async {
    final transaction = Transaction(
      amount: amount,
      description: description,
      date: DateTime.now(),
      category: category,
      accountId: accountId,
    );
    _transactions.add(transaction);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> removeTransaction(int index) async {
    final originalIndex = _transactions.length - 1 - index;
    if (originalIndex >= 0 && originalIndex < _transactions.length) {
      _transactions.removeAt(originalIndex);
      await _saveTransactions();
      notifyListeners();
    }
  }

  Future<void> clearAllTransactions() async {
    _transactions.clear();
    await _saveTransactions();
    notifyListeners();
  }
}

/// Transaction model — preserves existing JSON serialization.
class Transaction {
  final double amount;
  final String description;
  final DateTime date;
  final String category;
  final String accountId;

  Transaction({
    required this.amount,
    required this.description,
    required this.date,
    this.category = 'Other',
    this.accountId = 'cash',
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String? ?? 'Other',
      accountId: json['accountId'] as String? ?? 'cash',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'accountId': accountId,
    };
  }
}

/// Spending category for dashboard display.
class SpendingCategory {
  final String name;
  final double amount;
  final int percentage;
  final IconData icon;

  const SpendingCategory({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.icon,
  });
}
