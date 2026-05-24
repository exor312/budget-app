import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// A single savings goal with name, target, and current amount.
class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;

  double get percentComplete =>
      targetAmount > 0 ? (currentAmount / targetAmount * 100).round().toDouble() : 0.0;

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
    );
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
    };
  }
}

/// ChangeNotifier managing a list of savings goals persisted to SharedPreferences.
class SavingsGoalModel extends ChangeNotifier {
  SavingsGoalModel() {
    _loadGoals();
  }

  static const String _storageKey = 'savings_goals';

  List<SavingsGoal> _goals = [];

  List<SavingsGoal> get goals => List.unmodifiable(_goals);

  bool get hasGoals => _goals.isNotEmpty;

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      _goals = decoded
          .map((json) => SavingsGoal.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      _goals.map((g) => g.toJson()).toList(),
    );
    await prefs.setString(_storageKey, jsonString);
  }

  /// Add a new savings goal. Returns false if name is empty or duplicate.
  Future<bool> addGoal({required String name, required double targetAmount}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || targetAmount <= 0) return false;
    if (_goals.any((g) => g.name.toLowerCase() == trimmed.toLowerCase())) return false;

    final goal = SavingsGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: trimmed,
      targetAmount: targetAmount,
    );
    _goals.add(goal);
    await _saveGoals();
    notifyListeners();
    return true;
  }

  /// Update an existing goal. Returns false if not found.
  Future<bool> updateGoal(String id, {String? name, double? targetAmount, double? currentAmount}) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return false;

    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isEmpty) return false;

    _goals[index] = _goals[index].copyWith(
      name: trimmed,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
    );
    await _saveGoals();
    notifyListeners();
    return true;
  }

  /// Remove a goal by id.
  Future<void> removeGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _saveGoals();
    notifyListeners();
  }

  /// Get a goal by id.
  SavingsGoal? getGoalById(String id) {
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }
}
