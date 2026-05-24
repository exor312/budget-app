import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/transactions/data/budget_model.dart';
import 'features/budget_goals/data/budget_goals_model.dart';
import 'features/budget_goals/data/savings_goal_model.dart';
import 'features/settings/data/category_settings_model.dart';
import 'features/settings/data/account_settings_model.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FortunaApp());
}

class FortunaApp extends StatelessWidget {
  const FortunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BudgetModel()),
        ChangeNotifierProvider(create: (_) => SavingsGoalModel()),
        ChangeNotifierProvider(create: (_) => CategorySettingsModel()),
        ChangeNotifierProvider(create: (_) => AccountSettingsModel()),
        ChangeNotifierProxyProvider<BudgetModel, BudgetGoalsModel>(
          create: (context) => BudgetGoalsModel(
            budgetModel: context.read<BudgetModel>(),
          ),
          update: (context, budgetModel, previous) =>
              previous ?? BudgetGoalsModel(budgetModel: budgetModel),
        ),
      ],
      child: MaterialApp.router(
        title: 'Fortuna',
        debugShowCheckedModeBanner: false,
        theme: FortunaTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
