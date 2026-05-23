import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../transactions/data/budget_model.dart';
import '../../data/budget_goals_model.dart';
import '../widgets/budget_category_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/goal_card.dart';

/// Budgets & Goals screen — displays budget categories, summary stats,
/// and active savings goals. All data computed from real transactions.
class BudgetsGoalsScreen extends StatelessWidget {
  const BudgetsGoalsScreen({super.key});

  static const String routePath = '/budgets';
  static const String routeName = 'Budgets';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: FortunaColors.surface,
      body: Column(
        children: [
          _buildTopAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 48 : 20,
                      vertical: 8,
                    ),
                    child: Consumer2<BudgetGoalsModel, BudgetModel>(
                      builder: (context, model, budgetModel, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _buildHeroSection(budgetModel),
                            const SizedBox(height: 40),
                            _buildStatsSection(model, isDesktop),
                            const SizedBox(height: 40),
                            _buildCategoriesSection(model, isDesktop),
                            const SizedBox(height: 100),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      color: FortunaColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: FortunaColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: FortunaColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Fortuna',
                    style: FortunaTextStyles.headlineLg.copyWith(
                      color: FortunaColors.primary,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
                color: FortunaColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BudgetModel budgetModel) {
    final netBalance = budgetModel.netBalance;
    final monthlySpending = budgetModel.monthlySpending;
    final monthlyIncome = budgetModel.totalIncome;
    final savingsThisMonth = monthlyIncome - monthlySpending;

    String subtitle;
    if (budgetModel.transactions.isEmpty) {
      subtitle = 'Add transactions to start tracking your budget!';
    } else if (savingsThisMonth > 0) {
      subtitle = 'You\'ve saved \$${_formatAmount(savingsThisMonth)} this month. Keep it up!';
    } else if (savingsThisMonth == 0) {
      subtitle = 'You\'re breaking even this month. Watch your spending!';
    } else {
      subtitle = 'You\'re \$${_formatAmount(savingsThisMonth.abs())} over budget this month.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budgets & Goals',
                    style: FortunaTextStyles.headlineLgMobile.copyWith(
                      color: FortunaColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: FortunaTextStyles.bodyLg.copyWith(
                      color: FortunaColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle, size: 20),
              label: const Text('New Budget'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FortunaColors.primary,
                foregroundColor: FortunaColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(BudgetGoalsModel model, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SummaryCard(
              totalLimit: model.totalMonthlyLimit,
              totalSpent: model.totalSpent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 200,
              child: GoalCard(goal: model.activeGoal),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SummaryCard(
          totalLimit: model.totalMonthlyLimit,
          totalSpent: model.totalSpent,
        ),
        const SizedBox(height: 16),
        GoalCard(goal: model.activeGoal),
      ],
    );
  }

  Widget _buildCategoriesSection(
    BudgetGoalsModel model,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Categories',
          style: FortunaTextStyles.titleMd.copyWith(
            color: FortunaColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildCategoriesGrid(model.categories, isDesktop),
      ],
    );
  }

  Widget _buildCategoriesGrid(
    List<BudgetCategory> categories,
    bool isDesktop,
  ) {
    if (isDesktop) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          ...categories.map(
            (cat) => SizedBox(
              width: 280,
              child: BudgetCategoryCard(category: cat),
            ),
          ),
          _buildAddCategoryButton(),
        ],
      );
    }

    return Column(
      children: [
        ...categories.map(
          (cat) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BudgetCategoryCard(category: cat),
          ),
        ),
        _buildAddCategoryButton(),
      ],
    );
  }

  Widget _buildAddCategoryButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
            color: FortunaColors.outlineVariant,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle,
              size: 40,
              color: FortunaColors.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Category',
              style: FortunaTextStyles.titleMd.copyWith(
                color: FortunaColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }
    return amount.toStringAsFixed(2);
  }
}
