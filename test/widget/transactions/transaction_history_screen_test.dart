import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:budget_app/features/transactions/data/budget_model.dart';
import 'package:budget_app/features/transactions/presentation/screens/transaction_history_screen.dart';

class EmptyBudgetModel extends BudgetModel {
  @override
  List<Transaction> get transactions => [];
}

class SingleTransactionBudgetModel extends BudgetModel {
  @override
  List<Transaction> get transactions => [
    Transaction(amount: 50.0, description: 'Coffee', date: DateTime(2026, 5, 23)),
  ];
}

void main() {
  Widget createTestWidget(BudgetModel model) {
    return ChangeNotifierProvider<BudgetModel>.value(
      value: model,
      child: const MaterialApp(home: TransactionHistoryScreen()),
    );
  }

  group('TransactionHistoryScreen', () {
    testWidgets('shows empty state when no transactions', (tester) async {
      await tester.pumpWidget(createTestWidget(EmptyBudgetModel()));

      expect(find.text('No transactions found'), findsOneWidget);
      expect(find.text('Try adjusting your filters or add a transaction'), findsOneWidget);
    });

    testWidgets('shows transaction list when transactions exist', (tester) async {
      await tester.pumpWidget(createTestWidget(SingleTransactionBudgetModel()));

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.textContaining('50'), findsOneWidget);
    });

    testWidgets('displays Fortuna header', (tester) async {
      await tester.pumpWidget(createTestWidget(EmptyBudgetModel()));

      expect(find.text('Fortuna'), findsOneWidget);
    });

    testWidgets('has search bar', (tester) async {
      await tester.pumpWidget(createTestWidget(EmptyBudgetModel()));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search transactions, merchants...'), findsOneWidget);
    });

    testWidgets('has filter chips', (tester) async {
      await tester.pumpWidget(createTestWidget(EmptyBudgetModel()));

      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
    });
  });
}
