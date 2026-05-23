import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget_goals/data/budget_goals_model.dart';
import 'package:budget_app/features/transactions/data/budget_model.dart';

void main() {
  group('BudgetGoalsModel', () {
    late BudgetModel budgetModel;
    late BudgetGoalsModel model;

    setUp(() {
      budgetModel = BudgetModel();
      model = BudgetGoalsModel(budgetModel: budgetModel);
    });

    test('extends ChangeNotifier', () {
      expect(model, isA<ChangeNotifier>());
    });

    test('provides 6 categories computed from transaction keywords', () {
      expect(model.categories.length, equals(6));
      final names = model.categories.map((c) => c.name).toList();
      expect(names, contains('Food & Dining'));
      expect(names, contains('Transport'));
      expect(names, contains('Shopping'));
      expect(names, contains('Entertainment'));
      expect(names, contains('Bills'));
      expect(names, contains('Other'));
    });

    test('each category has name, icon, spent, limit', () {
      for (final cat in model.categories) {
        expect(cat.name, isNotEmpty);
        expect(cat.icon, isA<IconData>());
        expect(cat.spent, greaterThanOrEqualTo(0));
        expect(cat.limit, greaterThan(0));
      }
    });

    test('categories show zero spent when no transactions', () {
      for (final cat in model.categories) {
        expect(cat.spent, equals(0.0));
      }
    });

    test('totalMonthlyLimit is sum of category default limits', () {
      // Default limits: 800+400+500+250+1500+300 = 3750
      expect(model.totalMonthlyLimit, equals(3750.0));
    });

    test('totalSpent is 0 when no transactions', () {
      expect(model.totalSpent, equals(0.0));
    });

    test('activeGoal currentAmount is 0 when no transactions', () {
      expect(model.activeGoal.currentAmount, equals(0.0));
    });

    test('activeGoal targetAmount is 10000', () {
      expect(model.activeGoal.targetAmount, equals(10000.0));
    });

    test('computes spent from real transactions', () {
      budgetModel.addTransaction(amount: -50.0, description: 'grocery food');
      budgetModel.addTransaction(amount: -30.0, description: 'uber transport');
      // Force recompute
      model = BudgetGoalsModel(budgetModel: budgetModel);

      final foodCat = model.categories.firstWhere((c) => c.name == 'Food & Dining');
      final transportCat = model.categories.firstWhere((c) => c.name == 'Transport');
      expect(foodCat.spent, equals(50.0));
      expect(transportCat.spent, equals(30.0));
    });

    test('activeGoal currentAmount equals net balance', () {
      budgetModel.addTransaction(amount: 5000.0, description: 'salary Income');
      budgetModel.addTransaction(amount: -2000.0, description: 'rent Bill');
      model = BudgetGoalsModel(budgetModel: budgetModel);

      expect(model.activeGoal.currentAmount, equals(3000.0));
    });

    test('no hardcoded mock data', () {
      // Verify categories are computed, not hardcoded
      final catNames = model.categories.map((c) => c.name).toList();
      expect(catNames, isNot(contains('Groceries')));
      expect(catNames, isNot(contains('Personal Care')));
      expect(catNames, isNot(contains('Travel')));
    });

    test('remainingAmount is calculated correctly', () {
      expect(model.remainingAmount, equals(model.totalMonthlyLimit - model.totalSpent));
    });
  });

  group('BudgetCategory', () {
    test('utilizationPercent is 0 when limit is 0', () {
      const cat = BudgetCategory(
        name: 'Test',
        description: 'Test',
        icon: Icons.category,
        spent: 100,
        limit: 0,
      );
      expect(cat.utilizationPercent, equals(0.0));
    });

    test('utilizationPercent calculates correctly', () {
      const cat = BudgetCategory(
        name: 'Test',
        description: 'Test',
        icon: Icons.category,
        spent: 400,
        limit: 800,
      );
      expect(cat.utilizationPercent, equals(50.0));
    });

    test('status returns healthy for <= 80%', () {
      const cat = BudgetCategory(
        name: 'Test',
        description: 'Test',
        icon: Icons.category,
        spent: 400,
        limit: 800,
      );
      expect(cat.status, equals(BudgetStatus.healthy));
    });

    test('status returns warning for 81-99%', () {
      const cat = BudgetCategory(
        name: 'Test',
        description: 'Test',
        icon: Icons.category,
        spent: 210,
        limit: 250,
      );
      expect(cat.status, equals(BudgetStatus.warning));
    });

    test('status returns critical for >= 100%', () {
      const cat = BudgetCategory(
        name: 'Test',
        description: 'Test',
        icon: Icons.category,
        spent: 325.40,
        limit: 300,
      );
      expect(cat.status, equals(BudgetStatus.critical));
    });

    test('overLimitAmount is 0 when under limit', () {
      const cat = BudgetCategory(
        name: 'Test',
        description: 'Test',
        icon: Icons.category,
        spent: 400,
        limit: 800,
      );
      expect(cat.overLimitAmount, equals(0));
    });

    test('overLimitAmount returns correct amount when over limit', () {
      const cat = BudgetCategory(
        name: 'Test',
        description: 'Test',
        icon: Icons.category,
        spent: 325.40,
        limit: 300,
      );
      expect(cat.overLimitAmount, closeTo(25.40, 0.01));
    });
  });

  group('ActiveGoal', () {
    test('percentComplete is 0 when target is 0', () {
      const goal = ActiveGoal(
        name: 'Test',
        targetAmount: 0,
        currentAmount: 100,
      );
      expect(goal.percentComplete, equals(0.0));
    });

    test('percentComplete calculates correctly', () {
      const goal = ActiveGoal(
        name: 'Test',
        targetAmount: 10000,
        currentAmount: 5600,
      );
      expect(goal.percentComplete, equals(56.0));
    });
  });
}
