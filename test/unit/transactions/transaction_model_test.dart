import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/transactions/data/budget_model.dart';

void main() {
  group('Transaction', () {
    test('fromJson creates Transaction with correct fields', () {
      final json = {
        'amount': 50.0,
        'description': 'Test transaction',
        'date': '2026-05-23T10:00:00.000Z',
      };

      final transaction = Transaction.fromJson(json);

      expect(transaction.amount, 50.0);
      expect(transaction.description, 'Test transaction');
      expect(transaction.date.year, 2026);
      expect(transaction.date.month, 5);
    });

    test('toJson returns correct map', () {
      final transaction = Transaction(
        amount: -25.5,
        description: 'Coffee',
        date: DateTime(2026, 5, 23, 10, 0),
      );

      final json = transaction.toJson();

      expect(json['amount'], -25.5);
      expect(json['description'], 'Coffee');
      expect(json['date'], contains('2026-05-23'));
    });

    test('fromJson round-trip preserves data', () {
      final original = Transaction(
        amount: 100.0,
        description: 'Salary',
        date: DateTime(2026, 1, 15, 9, 0),
      );

      final json = original.toJson();
      final restored = Transaction.fromJson(json as Map<String, dynamic>);

      expect(restored.amount, original.amount);
      expect(restored.description, original.description);
    });
  });

  group('SpendingCategory', () {
    test('creates with correct fields', () {
      const category = SpendingCategory(
        name: 'Food & Dining',
        amount: 400.0,
        percentage: 40,
        icon: Icons.restaurant,
      );

      expect(category.name, 'Food & Dining');
      expect(category.amount, 400.0);
      expect(category.percentage, 40);
    });
  });
}
