import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:budget_app/features/transactions/data/budget_model.dart';
import 'package:budget_app/features/dashboard/presentation/widgets/net_worth_card.dart';
import 'package:budget_app/features/dashboard/presentation/widgets/budget_progress_card.dart';
import 'package:budget_app/features/dashboard/presentation/widgets/spending_categories_card.dart';
import 'package:budget_app/features/dashboard/presentation/widgets/quick_insights_card.dart';
import 'package:budget_app/features/dashboard/presentation/widgets/security_health_card.dart';

void main() {
  group('NetWorthCard', () {
    testWidgets('displays balance and trend indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetWorthCard(balance: 124592.0, trendPercentage: 4.2),
          ),
        ),
      );

      expect(find.text('Total Net Worth'), findsOneWidget);
      expect(find.textContaining('124,592'), findsOneWidget);
      expect(find.textContaining('+4.2%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    });

    testWidgets('displays zero balance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NetWorthCard(balance: 0)),
        ),
      );

      expect(find.text('Total Net Worth'), findsOneWidget);
    });
  });

  group('BudgetProgressCard', () {
    testWidgets('displays title, progress bar, and button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BudgetProgressCard(spentAmount: 3420, totalBudget: 4500),
          ),
        ),
      );

      expect(find.text('Monthly Budget'), findsOneWidget);
      expect(find.text('VIEW BUDGET DETAILS'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows correct percentage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BudgetProgressCard(spentAmount: 2250, totalBudget: 4500),
          ),
        ),
      );

      expect(find.textContaining('50%'), findsOneWidget);
    });
  });

  group('SpendingCategoriesCard', () {
    testWidgets('displays categories with progress bars', (tester) async {
      const categories = [
        SpendingCategory(name: 'Food & Dining', percentage: 40, icon: Icons.restaurant),
        SpendingCategory(name: 'Transport', percentage: 20, icon: Icons.directions_car),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpendingCategoriesCard(categories: categories),
          ),
        ),
      );

      expect(find.text('Top Spending Categories'), findsOneWidget);
      expect(find.text('ALL CATEGORIES'), findsOneWidget);
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);
    });
  });

  group('QuickInsightsCard', () {
    testWidgets('displays savings goal and bills due', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuickInsightsCard(savingsGoal: 12000, billsDueDays: 3),
          ),
        ),
      );

      expect(find.text('Quick Insights'), findsOneWidget);
      expect(find.text('Savings Goal'), findsOneWidget);
      expect(find.text('Bills Due'), findsOneWidget);
      expect(find.text('3 Days'), findsOneWidget);
      expect(find.byIcon(Icons.savings), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });
  });

  group('SecurityHealthCard', () {
    testWidgets('displays security score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SecurityHealthCard(score: 85)),
        ),
      );

      expect(find.text('Security Health'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
      expect(find.byIcon(Icons.verified_user), findsOneWidget);
      expect(find.textContaining('Two-factor authentication'), findsOneWidget);
    });
  });
}
