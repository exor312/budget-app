import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_app/features/transactions/data/budget_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Transaction date/time', () {
    test('Transaction preserves exact date and time', () {
      final dt = DateTime(2026, 3, 15, 14, 30);
      final t = Transaction(
        amount: -25.0,
        description: 'Lunch',
        date: dt,
      );
      expect(t.date.year, 2026);
      expect(t.date.month, 3);
      expect(t.date.day, 15);
      expect(t.date.hour, 14);
      expect(t.date.minute, 30);
    });

    test('Transaction.toJson includes date ISO string with time', () {
      final dt = DateTime(2026, 3, 15, 14, 30, 0);
      final t = Transaction(
        amount: 100.0,
        description: 'Salary',
        date: dt,
      );
      final json = t.toJson();
      expect(json['date'], contains('2026-03-15'));
      expect(json['date'], contains('14:30'));
    });

    test('Transaction.fromJson preserves time from ISO string', () {
      final json = {
        'amount': 50.0,
        'description': 'Test',
        'date': '2026-05-24T09:15:30.000',
        'category': 'Food',
        'accountId': 'cash',
      };
      final t = Transaction.fromJson(json);
      expect(t.date.hour, 9);
      expect(t.date.minute, 15);
      expect(t.date.second, 30);
    });

    test('Transaction round-trip preserves exact date and time', () {
      final original = Transaction(
        amount: -25.5,
        description: 'Coffee',
        date: DateTime(2026, 5, 23, 14, 30, 45),
      );
      final json = original.toJson();
      final restored = Transaction.fromJson(json as Map<String, dynamic>);
      expect(restored.date.year, original.date.year);
      expect(restored.date.month, original.date.month);
      expect(restored.date.day, original.date.day);
      expect(restored.date.hour, original.date.hour);
      expect(restored.date.minute, original.date.minute);
    });
  });

  group('BudgetModel.getDailySpending', () {
    late BudgetModel model;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      model = BudgetModel();
      await model.loadTransactions();
    });

    test('returns empty list when no transactions', () {
      final result = model.getDailySpending(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 12, 31),
      );
      expect(result, isEmpty);
    });

    test('returns empty when no expenses (income only)', () async {
      await model.addTransaction(
        amount: 1000.0,
        description: 'Salary',
        date: DateTime(2026, 6, 15, 9, 0),
      );
      final result = model.getDailySpending(
        start: DateTime(2026, 6, 1),
        end: DateTime(2026, 6, 30),
      );
      expect(result, isEmpty);
    });

    test('aggregates spending by day', () async {
      await model.addTransaction(amount: -10, description: 'A', date: DateTime(2026, 6, 15, 8, 0));
      await model.addTransaction(amount: -20, description: 'B', date: DateTime(2026, 6, 15, 12, 30));
      await model.addTransaction(amount: -30, description: 'C', date: DateTime(2026, 6, 15, 18, 0));

      final result = model.getDailySpending(
        start: DateTime(2026, 6, 1),
        end: DateTime(2026, 6, 30),
      );

      expect(result.length, 1);
      expect(result.first.value, 60.0);
      expect(result.first.key.day, 15);
    });

    test('returns sorted by date', () async {
      await model.addTransaction(amount: -50, description: 'A', date: DateTime(2026, 6, 20, 10, 0));
      await model.addTransaction(amount: -30, description: 'B', date: DateTime(2026, 6, 10, 10, 0));
      await model.addTransaction(amount: -20, description: 'C', date: DateTime(2026, 6, 15, 10, 0));

      final result = model.getDailySpending(
        start: DateTime(2026, 6, 1),
        end: DateTime(2026, 6, 30),
      );

      expect(result.length, 3);
      expect(result[0].key.day, 10);
      expect(result[1].key.day, 15);
      expect(result[2].key.day, 20);
    });

    test('filters by date range', () async {
      await model.addTransaction(amount: -10, description: 'A', date: DateTime(2026, 5, 31, 23, 59));
      await model.addTransaction(amount: -20, description: 'B', date: DateTime(2026, 6, 1, 0, 0));
      await model.addTransaction(amount: -30, description: 'C', date: DateTime(2026, 6, 30, 23, 59));
      await model.addTransaction(amount: -40, description: 'D', date: DateTime(2026, 7, 1, 0, 0));

      final result = model.getDailySpending(
        start: DateTime(2026, 6, 1),
        end: DateTime(2026, 6, 30),
      );

      expect(result.length, 2);
    });
  });

  group('BudgetModel.getMonthlySpending', () {
    late BudgetModel model;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      model = BudgetModel();
      await model.loadTransactions();
    });

    test('aggregates spending by month', () async {
      await model.addTransaction(amount: -100, description: 'A', date: DateTime(2026, 1, 15, 10, 0));
      await model.addTransaction(amount: -200, description: 'B', date: DateTime(2026, 1, 20, 14, 0));
      await model.addTransaction(amount: -300, description: 'C', date: DateTime(2026, 2, 5, 9, 0));

      final result = model.getMonthlySpending(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 12, 31),
      );

      expect(result.length, 2);
      expect(result[0].value, 300.0);
      expect(result[1].value, 300.0);
    });
  });

  group('BudgetModel.getTransactionsInRange', () {
    late BudgetModel model;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      model = BudgetModel();
      await model.loadTransactions();
    });

    test('returns transactions within date range inclusive', () async {
      await model.addTransaction(amount: -10, description: 'A', date: DateTime(2026, 6, 1, 8, 0));
      await model.addTransaction(amount: -20, description: 'B', date: DateTime(2026, 6, 15, 12, 0));
      await model.addTransaction(amount: -30, description: 'C', date: DateTime(2026, 6, 30, 23, 0));
      await model.addTransaction(amount: -40, description: 'D', date: DateTime(2026, 7, 1, 8, 0));

      final result = model.getTransactionsInRange(
        start: DateTime(2026, 6, 1),
        end: DateTime(2026, 6, 30),
      );

      expect(result.length, 3);
    });

    test('includes transactions at day boundaries', () async {
      await model.addTransaction(amount: -10, description: 'A', date: DateTime(2026, 6, 15, 0, 0, 0));
      await model.addTransaction(amount: -20, description: 'B', date: DateTime(2026, 6, 15, 23, 59, 59));

      final result = model.getTransactionsInRange(
        start: DateTime(2026, 6, 15),
        end: DateTime(2026, 6, 15),
      );

      expect(result.length, 2);
    });
  });

  group('BudgetModel.addTransaction with custom date', () {
    late BudgetModel model;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      model = BudgetModel();
      await model.loadTransactions();
    });

    test('addTransaction with custom date preserves date', () async {
      final customDate = DateTime(2025, 12, 25, 18, 30);
      await model.addTransaction(
        amount: -50.0,
        description: 'Christmas dinner',
        date: customDate,
      );

      expect(model.transactions.length, 1);
      expect(model.transactions.first.date.year, 2025);
      expect(model.transactions.first.date.month, 12);
      expect(model.transactions.first.date.day, 25);
      expect(model.transactions.first.date.hour, 18);
      expect(model.transactions.first.date.minute, 30);
    });

    test('addTransaction without date defaults to now', () async {
      final before = DateTime.now();
      await model.addTransaction(
        amount: -10.0,
        description: 'Quick purchase',
      );
      final after = DateTime.now();

      expect(model.transactions.length, 1);
      final txnDate = model.transactions.first.date;
      expect(txnDate.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(txnDate.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });
}
