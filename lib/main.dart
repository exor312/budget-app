import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_model.dart';
import 'features/transactions/data/budget_model.dart';
import 'features/budget_goals/data/budget_goals_model.dart';
import 'features/budget_goals/data/savings_goal_model.dart';
import 'features/settings/data/category_settings_model.dart';
import 'features/settings/data/account_settings_model.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeModel = ThemeModel();
  await themeModel.load();
  runApp(FortunaApp(themeModel: themeModel));
}

class FortunaApp extends StatelessWidget {
  final ThemeModel themeModel;

  const FortunaApp({super.key, required this.themeModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeModel),
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
      child: Consumer<ThemeModel>(
        builder: (context, theme, _) {
          return MaterialApp.router(
            title: 'Fortuna',
            debugShowCheckedModeBanner: false,
            theme: FortunaTheme.light,
            darkTheme: FortunaTheme.dark,
            themeMode: theme.themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
