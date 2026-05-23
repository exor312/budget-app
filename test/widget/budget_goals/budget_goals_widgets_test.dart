import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:budget_app/features/budget_goals/data/budget_goals_model.dart';
import 'package:budget_app/features/budget_goals/presentation/screens/budgets_goals_screen.dart';
import 'package:budget_app/features/budget_goals/presentation/widgets/budget_category_card.dart';
import 'package:budget_app/features/budget_goals/presentation/widgets/summary_card.dart';
import 'package:budget_app/features/budget_goals/presentation/widgets/goal_card.dart';

void main() {
  group('BudgetsGoalsScreen', () {
    Widget buildTestApp() {
      return ChangeNotifierProvider(
        create: (_) => BudgetGoalsModel(),
        child: const MaterialApp(
          home: BudgetsGoalsScreen(),
        ),
      );
    }

    testWidgets('has correct routePath and routeName', (tester) async {
      expect(BudgetsGoalsScreen.routePath, equals('/budgets'));
      expect(BudgetsGoalsScreen.routeName, equals('Budgets'));
    });

    testWidgets('screen renders without crash', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 100));
      // Verify the screen builds and renders key text elements
      expect(find.text('Budgets & Goals'), findsOneWidget);
    });
  });

  group('BudgetCategoryCard', () {
    Widget buildCard(BudgetCategory category) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: BudgetCategoryCard(category: category),
            ),
          ),
        ),
      );
    }

    testWidgets('renders category name and description', (tester) async {
      const cat = BudgetCategory(
        name: 'Groceries',
        description: 'Daily essentials',
        icon: Icons.restaurant,
        spent: 452.20,
        limit: 800.0,
      );
      await tester.pumpWidget(buildCard(cat));
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Daily essentials'), findsOneWidget);
    });

    testWidgets('renders spent and limit amounts', (tester) async {
      const cat = BudgetCategory(
        name: 'Groceries',
        description: 'Test',
        icon: Icons.restaurant,
        spent: 452.20,
        limit: 800.0,
      );
      await tester.pumpWidget(buildCard(cat));
      expect(find.text('\$452.20'), findsOneWidget);
      expect(find.text('of \$800'), findsOneWidget);
    });

    testWidgets('shows Under budget for healthy category', (tester) async {
      const cat = BudgetCategory(
        name: 'Groceries',
        description: 'Test',
        icon: Icons.restaurant,
        spent: 452.20,
        limit: 800.0,
      );
      await tester.pumpWidget(buildCard(cat));
      expect(find.text('Under budget'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows Careful for warning category', (tester) async {
      const cat = BudgetCategory(
        name: 'Entertainment',
        description: 'Test',
        icon: Icons.movie,
        spent: 210.0,
        limit: 250.0,
      );
      await tester.pumpWidget(buildCard(cat));
      expect(find.textContaining('Careful'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('shows Over Limit for critical category', (tester) async {
      const cat = BudgetCategory(
        name: 'Personal Care',
        description: 'Test',
        icon: Icons.shopping_cart,
        spent: 325.40,
        limit: 300.0,
      );
      await tester.pumpWidget(buildCard(cat));
      expect(find.text('Over Limit'), findsWidgets);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('renders more_vert icon button', (tester) async {
      const cat = BudgetCategory(
        name: 'Test',
        description: 'Test',
        icon: Icons.category,
        spent: 100,
        limit: 200,
      );
      await tester.pumpWidget(buildCard(cat));
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });

  group('SummaryCard', () {
    Widget buildCard(double limit, double spent) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            child: SummaryCard(totalLimit: limit, totalSpent: spent),
          ),
        ),
      );
    }

    testWidgets('renders Total Monthly Limit label', (tester) async {
      await tester.pumpWidget(buildCard(4800, 2150));
      expect(find.text('Total Monthly Limit'), findsOneWidget);
    });

    testWidgets('renders total limit amount', (tester) async {
      await tester.pumpWidget(buildCard(4800, 2150));
      expect(find.text('\$4800'), findsOneWidget);
    });

    testWidgets('renders utilized percentage', (tester) async {
      await tester.pumpWidget(buildCard(4800, 2150));
      expect(find.textContaining('utilized'), findsOneWidget);
    });
  });

  group('GoalCard', () {
    Widget buildCard(ActiveGoal goal) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 250,
            child: GoalCard(goal: goal),
          ),
        ),
      );
    }

    testWidgets('renders goal name', (tester) async {
      const goal = ActiveGoal(
        name: 'New Car Fund',
        targetAmount: 15000,
        currentAmount: 8400,
      );
      await tester.pumpWidget(buildCard(goal));
      expect(find.text('New Car Fund'), findsOneWidget);
    });

    testWidgets('renders Active Goal badge', (tester) async {
      const goal = ActiveGoal(
        name: 'Test',
        targetAmount: 1000,
        currentAmount: 500,
      );
      await tester.pumpWidget(buildCard(goal));
      expect(find.text('Active Goal'), findsOneWidget);
    });

    testWidgets('renders target amount', (tester) async {
      const goal = ActiveGoal(
        name: 'Test',
        targetAmount: 15000,
        currentAmount: 8400,
      );
      await tester.pumpWidget(buildCard(goal));
      expect(find.text('Target: \$15000'), findsOneWidget);
    });

    testWidgets('renders current saved amount', (tester) async {
      const goal = ActiveGoal(
        name: 'Test',
        targetAmount: 15000,
        currentAmount: 8400,
      );
      await tester.pumpWidget(buildCard(goal));
      expect(find.text('\$8400'), findsOneWidget);
    });

    testWidgets('renders savings icon', (tester) async {
      const goal = ActiveGoal(
        name: 'Test',
        targetAmount: 1000,
        currentAmount: 500,
      );
      await tester.pumpWidget(buildCard(goal));
      expect(find.byIcon(Icons.savings), findsOneWidget);
    });
  });
}
