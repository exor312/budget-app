import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../transactions/data/budget_model.dart';
import '../../data/budget_goals_model.dart';
import '../../data/savings_goal_model.dart';
import '../widgets/budget_category_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/goal_card.dart';
import '../widgets/edit_budget_dialog.dart';
import '../widgets/savings_goal_dialog.dart';

/// Budgets & Goals screen — displays budget categories, summary stats,
/// and savings goals. Users can edit/delete/add budgets and goals.
/// All data computed from real transactions.
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
                      horizontal: isDesktop ? 48 : 16,
                      vertical: 8,
                    ),
                    child: Consumer3<BudgetGoalsModel, BudgetModel, SavingsGoalModel>(
                      builder: (context, model, budgetModel, goalsModel, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _buildHeroSection(context, budgetModel),
                            const SizedBox(height: 24),
                            _buildStatsSection(model, isDesktop),
                            const SizedBox(height: 24),
                            _buildCategoriesSection(context, model, isDesktop),
                            const SizedBox(height: 24),
                            _buildGoalsSection(context, goalsModel),
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
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: FortunaColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: FortunaColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Fortuna',
                    style: FortunaTextStyles.headlineSm.copyWith(
                      color: FortunaColors.primary,
                      fontSize: 22,
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

  Widget _buildHeroSection(BuildContext context, BudgetModel budgetModel) {
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budgets & Goals',
                style: FortunaTextStyles.headlineMd.copyWith(
                  color: FortunaColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: FortunaTextStyles.bodyMd.copyWith(
                  color: FortunaColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _showAddBudgetDialog(context),
          icon: const Icon(Icons.add_circle, size: 18),
          label: const Text('New Budget'),
          style: ElevatedButton.styleFrom(
            backgroundColor: FortunaColors.primary,
            foregroundColor: FortunaColors.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
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
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 200,
              child: GoalCard(
                goal: const SavingsGoal(
                  id: '__placeholder__',
                  name: 'No goals yet',
                  targetAmount: 1,
                  currentAmount: 0,
                ),
              ),
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
      ],
    );
  }

  Widget _buildCategoriesSection(
    BuildContext context,
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
        const SizedBox(height: 12),
        _buildCategoriesGrid(context, model, isDesktop),
      ],
    );
  }

  Widget _buildCategoriesGrid(
    BuildContext context,
    BudgetGoalsModel model,
    bool isDesktop,
  ) {
    if (isDesktop) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ...model.categories.map(
            (cat) => SizedBox(
              width: 300,
              child: BudgetCategoryCard(
                category: cat,
                onEdit: () => _showEditBudgetDialog(context, cat),
                onDelete: cat.isDefault
                    ? null
                    : () => _confirmDeleteCategory(context, cat),
              ),
            ),
          ),
          _buildAddCategoryButton(context),
        ],
      );
    }

    return Column(
      children: [
        ...model.categories.map(
          (cat) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BudgetCategoryCard(
              category: cat,
              onEdit: () => _showEditBudgetDialog(context, cat),
              onDelete: cat.isDefault
                  ? null
                  : () => _confirmDeleteCategory(context, cat),
            ),
          ),
        ),
        _buildAddCategoryButton(context),
      ],
    );
  }

  Widget _buildGoalsSection(BuildContext context, SavingsGoalModel goalsModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Savings Goals',
              style: FortunaTextStyles.titleMd.copyWith(
                color: FortunaColors.primary,
              ),
            ),
            IconButton(
              onPressed: () => _showAddGoalDialog(context),
              icon: const Icon(Icons.add_circle),
              color: FortunaColors.primary,
              iconSize: 28,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!goalsModel.hasGoals)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FortunaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: FortunaColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.savings,
                    size: 40,
                    color: FortunaColors.onSurfaceVariant.withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                Text(
                  'No savings goals yet',
                  style: FortunaTextStyles.bodyMd.copyWith(
                    color: FortunaColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap the + button to add one',
                  style: FortunaTextStyles.bodySm.copyWith(
                    color: FortunaColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          )
        else
          ...goalsModel.goals.map(
            (goal) => GoalCard(
              goal: goal,
              onDelete: () => _confirmDeleteGoal(context, goal),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAddCategoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddBudgetDialog(context),
      child: Container(
        width: 120,
        height: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: FortunaColors.outlineVariant,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 24,
              color: FortunaColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: FortunaTextStyles.bodySm.copyWith(
                color: FortunaColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dialog handlers ---

  void _showAddBudgetDialog(BuildContext context) {
    final model = context.read<BudgetGoalsModel>();
    showDialog<EditBudgetResult>(
      context: context,
      builder: (_) => EditBudgetDialog(
        isAdd: true,
        existingNames: model.categories.map((c) => c.name).toList(),
      ),
    ).then((result) {
      if (result != null) {
        model.addCategory(result.name, limit: result.limit);
      }
    });
  }

  void _showEditBudgetDialog(BuildContext context, BudgetCategory category) {
    final model = context.read<BudgetGoalsModel>();
    showDialog<EditBudgetResult>(
      context: context,
      builder: (_) => EditBudgetDialog(
        isAdd: false,
        initialName: category.name,
        initialLimit: category.limit,
        existingNames: model.categories.map((c) => c.name).toList(),
      ),
    ).then((result) {
      if (result != null) {
        model.updateCategoryLimit(result.name, result.limit);
      }
    });
  }

  void _confirmDeleteCategory(BuildContext context, BudgetCategory category) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${category.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<BudgetGoalsModel>().removeCategory(category.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FortunaColors.error,
              foregroundColor: FortunaColors.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final model = context.read<SavingsGoalModel>();
    showDialog<SavingsGoalResult>(
      context: context,
      builder: (_) => SavingsGoalDialog(
        isAdd: true,
        existingNames: model.goals.map((g) => g.name).toList(),
      ),
    ).then((result) {
      if (result != null) {
        model.addGoal(name: result.name, targetAmount: result.targetAmount);
      }
    });
  }

  void _confirmDeleteGoal(BuildContext context, SavingsGoal goal) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Delete "${goal.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<SavingsGoalModel>().removeGoal(goal.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FortunaColors.error,
              foregroundColor: FortunaColors.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
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
