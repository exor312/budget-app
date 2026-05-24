import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:budget_app/features/budget_goals/data/budget_goals_model.dart';
import 'package:budget_app/features/budget_goals/data/savings_goal_model.dart';
import 'package:budget_app/features/budget_goals/presentation/screens/budgets_goals_screen.dart';
import 'package:budget_app/features/budget_goals/presentation/widgets/budget_category_card.dart';
import 'package:budget_app/features/budget_goals/presentation/widgets/summary_card.dart';
import 'package:budget_app/features/budget_goals/presentation/widgets/goal_card.dart';
import 'package:budget_app/features/transactions/data/budget_model.dart';

void main() {
  Widget buildTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BudgetModel()),
        ChangeNotifierProvider(create: (_) => SavingsGoalModel()),
        ChangeNotifierProxyProvider<BudgetModel, BudgetGoalsModel>(
          create: (context) => BudgetGoalsModel(
            budgetModel: context.read<BudgetModel>(),
          ),
          update: (context, budgetModel, previous) =>
              previous ?? BudgetGoalsModel(budgetModel: budgetModel),
        ),
      ],
      child: const MaterialApp(
        home: BudgetsGoalsScreen(),
      ),
    );
  }

  group('BudgetsGoalsScreen', () {
    testWidgets('has correct routePath and routeName', (tester) async {
      expect(BudgetsGoalsScreen.routePath, equals('/budgets'));
      expect(BudgetsGoalsScreen.routeName, equals('Budgets'));
    });

    testWidgets('screen renders without crash', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Budgets & Goals'), findsOneWidget);
    });

    testWidgets('shows dynamic subtitle when no transactions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Add transactions to start tracking your budget!'), findsOneWidget);
    });

    testWidgets('shows New Budget button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('New Budget'), findsOneWidget);
    });

    testWidgets('shows Active Categories section', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Active Categories'), findsOneWidget);
    });

    testWidgets('shows Savings Goals section', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Savings Goals'), findsOneWidget);
    });
  });

  group('BudgetCategoryCard', () {
    Widget buildCard(BudgetCategory category, {VoidCallback? onEdit, VoidCallback? onDelete}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: BudgetCategoryCard(
                category: category,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders category name', (tester) async {
      const cat = BudgetCategory(
        name: 'Food & Dining',
        description: 'Groceries & restaurants',
        icon: Icons.restaurant,
        spent: 452.20,
        limit: 800.0,
        isDefault: true,
      );
      await tester.pumpWidget(buildCard(cat));
      expect(find.text('Food & Dining'), findsOneWidget);
    });

    testWidgets('renders spent and limit amounts', (tester) async {
      const cat = BudgetCategory(
        name: 'Food & Dining',
        description: 'Test',
        icon: Icons.restaurant,
        spent: 452.20,
        limit: 800.0,
        isDefault: false,
      );
      await tester.pumpWidget(buildCard(cat));
      expect(find.text('\$452.20'), findsOneWidget);
      expect(find.text('of \$800'), findsOneWidget);
    });

    testWidgets('shows On track for healthy category', (tester) async {
      const cat = BudgetCategory(
        name: 'Food & Dining',
        description: 'Test',
        icon: Icons.restaurant,
        spent: 452.20,
        limit: 800.0,
        isDefault: false,
      );
      await tester.pumpWidget(buildCard(cat));
      expect(find.text('On track'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows percentage used for warning category', (tester) async {
      const cat = BudgetCategory(
        name: 'Entertainment',
        description: 'Test',
        icon: Icons.movie,
        spent: 210.0,
        limit: 250.0,
        isDefault: false,
      );
      await tester.pumpWidget(buildCard(cat));
      expect(find.textContaining('% used'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('shows over limit amount for critical category', (tester) async {
      const cat = BudgetCategory(
        name: 'Other',
        description: 'Test',
        icon: Icons.shopping_cart,
        spent: 325.40,
        limit: 300.0,
        isDefault: false,
      );
      await tester.pumpWidget(buildCard(cat));
      expect(find.text('Over'), findsWidgets);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows edit and delete buttons for custom category', (tester) async {
      const cat = BudgetCategory(
        name: 'Gaming',
        description: 'Test',
        icon: Icons.sports_esports,
        spent: 100,
        limit: 200,
        isDefault: false,
      );
      await tester.pumpWidget(buildCard(cat, onEdit: () {}, onDelete: () {}));
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('does not show delete button for default category', (tester) async {
      const cat = BudgetCategory(
        name: 'Food & Dining',
        description: 'Test',
        icon: Icons.restaurant,
        spent: 100,
        limit: 200,
        isDefault: true,
      );
      await tester.pumpWidget(buildCard(cat, onEdit: () {}, onDelete: null));
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
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
      await tester.pumpWidget(buildCard(3750, 2150));
      expect(find.text('Total Monthly Limit'), findsOneWidget);
    });

    testWidgets('renders total limit amount', (tester) async {
      await tester.pumpWidget(buildCard(3750, 2150));
      expect(find.text('\$3750'), findsOneWidget);
    });

    testWidgets('renders utilized percentage', (tester) async {
      await tester.pumpWidget(buildCard(3750, 2150));
      expect(find.textContaining('utilized'), findsOneWidget);
    });
  });

  group('GoalCard', () {
    Widget buildCard(SavingsGoal goal, {VoidCallback? onDelete}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 250,
            child: GoalCard(goal: goal, onDelete: onDelete),
          ),
        ),
      );
    }

    testWidgets('renders goal name', (tester) async {
      const goal = SavingsGoal(
        id: '1',
        name: 'Vacation Fund',
        targetAmount: 10000,
        currentAmount: 5000,
      );
      await tester.pumpWidget(buildCard(goal));
      expect(find.text('Vacation Fund'), findsOneWidget);
    });

    testWidgets('renders current and target amounts', (tester) async {
      const goal = SavingsGoal(
        id: '1',
        name: 'Test',
        targetAmount: 10000,
        currentAmount: 5000,
      );
      await tester.pumpWidget(buildCard(goal));
      expect(find.text('\$5000'), findsOneWidget);
      expect(find.text('of \$10000'), findsOneWidget);
    });

    testWidgets('renders percent complete', (tester) async {
      const goal = SavingsGoal(
        id: '1',
        name: 'Test',
        targetAmount: 10000,
        currentAmount: 5000,
      );
      await tester.pumpWidget(buildCard(goal));
      expect(find.text('50% complete'), findsOneWidget);
    });

    testWidgets('renders savings icon', (tester) async {
      const goal = SavingsGoal(
        id: '1',
        name: 'Test',
        targetAmount: 1000,
        currentAmount: 500,
      );
      await tester.pumpWidget(buildCard(goal));
      expect(find.byIcon(Icons.savings), findsOneWidget);
    });

    testWidgets('shows delete button when onDelete provided', (tester) async {
      const goal = SavingsGoal(
        id: '1',
        name: 'Test',
        targetAmount: 1000,
        currentAmount: 500,
      );
      await tester.pumpWidget(buildCard(goal, onDelete: () {}));
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('hides delete button when onDelete is null', (tester) async {
      const goal = SavingsGoal(
        id: '1',
        name: 'Test',
        targetAmount: 1000,
        currentAmount: 500,
      );
      await tester.pumpWidget(buildCard(goal));
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });
}
