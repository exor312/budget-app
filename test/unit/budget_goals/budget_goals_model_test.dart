import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget_goals/data/budget_goals_model.dart';

void main() {
  group('BudgetGoalsModel', () {
    late BudgetGoalsModel model;

    setUp(() {
      model = BudgetGoalsModel();
    });

    test('extends ChangeNotifier', () {
      expect(model, isA<ChangeNotifier>());
    });

    test('provides 4 sample categories', () {
      expect(model.categories.length, equals(4));
      expect(model.categories[0].name, equals('Groceries'));
      expect(model.categories[1].name, equals('Entertainment'));
      expect(model.categories[2].name, equals('Personal Care'));
      expect(model.categories[3].name, equals('Travel'));
    });

    test('each category has name, icon, spent, limit', () {
      for (final cat in model.categories) {
        expect(cat.name, isNotEmpty);
        expect(cat.icon, isA<IconData>());
        expect(cat.spent, greaterThan(0));
        expect(cat.limit, greaterThan(0));
      }
    });

    test('provides totalMonthlyLimit and totalSpent', () {
      expect(model.totalMonthlyLimit, equals(4800.0));
      expect(model.totalSpent, greaterThan(0));
    });

    test('provides ActiveGoal with name, target, current', () {
      expect(model.activeGoal.name, equals('New Car Fund'));
      expect(model.activeGoal.targetAmount, equals(15000.0));
      expect(model.activeGoal.currentAmount, equals(8400.0));
    });

    test('categories match reference data', () {
      expect(model.categories[0].spent, equals(452.20));
      expect(model.categories[0].limit, equals(800.0));
      expect(model.categories[1].spent, equals(210.0));
      expect(model.categories[1].limit, equals(250.0));
      expect(model.categories[2].spent, equals(325.40));
      expect(model.categories[2].limit, equals(300.0));
      expect(model.categories[3].spent, equals(150.0));
      expect(model.categories[3].limit, equals(600.0));
    });

    test('utilizationPercent returns correct values', () {
      expect(model.categories[0].utilizationPercent, equals(57.0)); // 452/800
      expect(model.categories[1].utilizationPercent, equals(84.0)); // 210/250
      expect(model.categories[2].utilizationPercent, equals(108.0)); // 325/300
      expect(model.categories[3].utilizationPercent, equals(25.0)); // 150/600
    });

    test('status returns healthy for <= 80%', () {
      expect(model.categories[0].status, equals(BudgetStatus.healthy));
      expect(model.categories[3].status, equals(BudgetStatus.healthy));
    });

    test('status returns warning for 81-99%', () {
      expect(model.categories[1].status, equals(BudgetStatus.warning));
    });

    test('status returns critical for >= 100%', () {
      expect(model.categories[2].status, equals(BudgetStatus.critical));
    });

    test('overLimitAmount is 0 when under limit', () {
      expect(model.categories[0].overLimitAmount, equals(0));
    });

    test('overLimitAmount returns correct amount when over limit', () {
      expect(
        model.categories[2].overLimitAmount,
        closeTo(25.40, 0.01),
      );
    });

    test('activeGoal percentComplete is correct', () {
      expect(model.activeGoal.percentComplete, equals(56.0)); // 8400/15000
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
  });
}
