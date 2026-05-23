import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:budget_app/core/theme/app_theme.dart';
import 'package:budget_app/core/widgets/loading_widget.dart';
import 'package:budget_app/core/widgets/error_widget.dart';
import 'package:budget_app/core/widgets/empty_state.dart';
import 'package:budget_app/features/transactions/data/budget_model.dart';

class TestBudgetModel extends BudgetModel {
  final List<Transaction> _testTransactions;
  TestBudgetModel(this._testTransactions);

  @override
  List<Transaction> get transactions => _testTransactions;
}

void main() {
  group('AppLoadingWidget', () {
    testWidgets('displays centered CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLoadingWidget())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
    });
  });

  group('AppErrorWidget', () {
    testWidgets('displays error icon and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(message: 'Something went wrong'),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('displays retry button when onRetry provided', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppErrorWidget(message: 'Error')),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });
  });

  group('AppEmptyStateWidget', () {
    testWidgets('displays icon and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyStateWidget(message: 'No items yet'),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No items yet'), findsOneWidget);
    });
  });
}
