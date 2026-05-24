import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_app/features/budget_goals/data/budget_goals_model.dart';
import 'package:budget_app/features/budget_goals/data/savings_goal_model.dart';
import 'package:budget_app/features/transactions/data/budget_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BudgetGoalsModel', () {
    late BudgetModel budgetModel;
    late BudgetGoalsModel model;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      budgetModel = BudgetModel();
      model = BudgetGoalsModel(budgetModel: budgetModel);
    });

    test('extends ChangeNotifier', () {
      expect(model, isA<ChangeNotifier>());
    });

    test('provides 6 default categories', () {
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

    test('savingsGoals is empty by default', () {
      expect(model.savingsGoals, isEmpty);
    });

    test('computes spent from real transactions', () async {
      await budgetModel.addTransaction(amount: -50.0, description: 'grocery food', category: 'Food & Dining');
      await budgetModel.addTransaction(amount: -30.0, description: 'uber transport', category: 'Transport');
      model = BudgetGoalsModel(budgetModel: budgetModel);

      final foodCat = model.categories.firstWhere((c) => c.name == 'Food & Dining');
      final transportCat = model.categories.firstWhere((c) => c.name == 'Transport');
      expect(foodCat.spent, equals(50.0));
      expect(transportCat.spent, equals(30.0));
    });

    test('no hardcoded mock data', () {
      final catNames = model.categories.map((c) => c.name).toList();
      expect(catNames, isNot(contains('Groceries')));
      expect(catNames, isNot(contains('Personal Care')));
      expect(catNames, isNot(contains('Travel')));
    });

    test('remainingAmount is calculated correctly', () {
      expect(model.remainingAmount, equals(model.totalMonthlyLimit - model.totalSpent));
    });

    test('addCategory adds a custom category', () async {
      final result = await model.addCategory('Gaming', limit: 200.0);
      expect(result, isTrue);
      expect(model.categories.length, equals(7));
      final gaming = model.categories.firstWhere((c) => c.name == 'Gaming');
      expect(gaming.limit, equals(200.0));
      expect(gaming.isDefault, isFalse);
    });

    test('addCategory rejects duplicate name', () async {
      final result = await model.addCategory('Food & Dining', limit: 100.0);
      expect(result, isFalse);
    });

    test('removeCategory removes custom category', () async {
      await model.addCategory('Gaming', limit: 200.0);
      final result = await model.removeCategory('Gaming');
      expect(result, isTrue);
      expect(model.categories.length, equals(6));
    });

    test('removeCategory rejects default category', () async {
      final result = await model.removeCategory('Food & Dining');
      expect(result, isFalse);
    });

    test('updateCategoryLimit changes limit', () async {
      final result = await model.updateCategoryLimit('Food & Dining', 900.0);
      expect(result, isTrue);
      final food = model.categories.firstWhere((c) => c.name == 'Food & Dining');
      expect(food.limit, equals(900.0));
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
        isDefault: false,
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
        isDefault: false,
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
        isDefault: false,
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
        isDefault: false,
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
        isDefault: false,
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
        isDefault: false,
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
        isDefault: false,
      );
      expect(cat.overLimitAmount, closeTo(25.40, 0.01));
    });
  });

  group('SavingsGoal', () {
    test('percentComplete is 0 when target is 0', () {
      const goal = SavingsGoal(
        id: '1',
        name: 'Test',
        targetAmount: 0,
        currentAmount: 100,
      );
      expect(goal.percentComplete, equals(0.0));
    });

    test('percentComplete calculates correctly', () {
      const goal = SavingsGoal(
        id: '1',
        name: 'Test',
        targetAmount: 10000,
        currentAmount: 5600,
      );
      expect(goal.percentComplete, equals(56.0));
    });

    test('copyWith preserves fields', () {
      const goal = SavingsGoal(
        id: '1',
        name: 'Test',
        targetAmount: 5000,
        currentAmount: 1000,
      );
      final updated = goal.copyWith(currentAmount: 2000);
      expect(updated.currentAmount, equals(2000));
      expect(updated.name, equals('Test'));
    });

    test('toJson and fromJson round-trip', () {
      const goal = SavingsGoal(
        id: '1',
        name: 'Vacation',
        targetAmount: 5000,
        currentAmount: 1200,
      );
      final json = goal.toJson();
      final restored = SavingsGoal.fromJson(json);
      expect(restored.id, equals(goal.id));
      expect(restored.name, equals(goal.name));
      expect(restored.targetAmount, equals(goal.targetAmount));
      expect(restored.currentAmount, equals(goal.currentAmount));
    });
  });
}
