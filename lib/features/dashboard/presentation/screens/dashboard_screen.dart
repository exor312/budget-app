import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../transactions/data/budget_model.dart';
import '../../../budget_goals/data/budget_goals_model.dart';
import '../widgets/net_worth_card.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/spending_categories_card.dart';
import '../widgets/quick_insights_card.dart';
import '../widgets/security_health_card.dart';
import '../widgets/account_balances_card.dart';

/// Main Dashboard screen — bento grid layout matching the Fortuna reference design.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String routePath = '/dashboard';
  static const String routeName = 'Dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollShadow = false;

  // Staggered animation controllers
  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();

    // Scroll shadow listener
    _scrollController.addListener(_onScroll);

    // Initialize staggered animations for 7 cards
    _controllers = List.generate(7, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
    });

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();

    // Start staggered entrance animations
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) _controllers[i].forward();
      });
    }

    // Load transactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetModel>().loadTransactions();
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_showScrollShadow) {
      setState(() => _showScrollShadow = true);
    } else if (_scrollController.offset <= 10 && _showScrollShadow) {
      setState(() => _showScrollShadow = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: FortunaColors.surface,
      body: Column(
        children: [
          // Top App Bar
          _buildTopAppBar(),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 48 : 20,
                      vertical: 8,
                    ),
                    child: Consumer2<BudgetModel, BudgetGoalsModel>(
                      builder: (context, budgetModel, budgetGoalsModel, _) {
                        // Compute real values from transaction data
                        final securityScore = _computeSecurityScore(budgetModel);
                        final savingsAmount = budgetModel.netBalance > 0
                            ? budgetModel.netBalance
                            : 0.0;
                        final billsDueLabel = _computeBillsDue(budgetModel);

                        return isDesktop
                            ? _buildDesktopLayout(
                                budgetModel, budgetGoalsModel, securityScore, savingsAmount, billsDueLabel)
                            : _buildMobileLayout(
                                budgetModel, budgetGoalsModel, securityScore, savingsAmount, billsDueLabel);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isDesktop
          ? FloatingActionButton(
              onPressed: () => context.push('/add-transaction'),
              backgroundColor: FortunaColors.primary,
              foregroundColor: FortunaColors.onPrimary,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 32),
            )
          : null,
    );
  }

  /// Compute a security/financial health score from real transaction activity.
  int _computeSecurityScore(BudgetModel model) {
    final txCount = model.transactions.length;
    if (txCount == 0) return 0;
    if (txCount < 5) return 40;
    if (txCount < 10) return 65;
    if (txCount < 20) return 80;
    // Score based on transaction consistency and positive net balance
    final hasPositiveBalance = model.netBalance > 0;
    return hasPositiveBalance ? 90 : 75;
  }

  /// Compute bills due label from recurring transaction detection.
  String _computeBillsDue(BudgetModel model) {
    // Look for transactions with "bill", "rent", "electric", "water" in description
    final now = DateTime.now();
    final currentMonth = model.transactions
        .where((t) =>
            t.amount < 0 &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .toList();

    int billCount = 0;
    for (final t in currentMonth) {
      final desc = t.description.toLowerCase();
      if (desc.contains('bill') ||
          desc.contains('rent') ||
          desc.contains('electric') ||
          desc.contains('water') ||
          desc.contains('subscription')) {
        billCount++;
      }
    }

    if (billCount == 0) return 'None';
    return '$billCount active';
  }

  Widget _buildTopAppBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: FortunaColors.surface,
        boxShadow: _showScrollShadow
            ? [
                BoxShadow(
                  color: FortunaColors.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width >= 768 ? 48 : 20,
          ),
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

  Widget _buildDesktopLayout(BudgetModel budgetModel, BudgetGoalsModel budgetGoalsModel,
      int securityScore, double savingsAmount, String billsDueLabel) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Row 1: Net Worth (7/12) + Budget (5/12)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _AnimatedCard(
                index: 0,
                slideAnimation: _slideAnimations[0],
                fadeAnimation: _fadeAnimations[0],
                child: NetWorthCard(
                  balance: budgetModel.netBalance,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: _AnimatedCard(
                index: 1,
                slideAnimation: _slideAnimations[1],
                fadeAnimation: _fadeAnimations[1],
                child: SizedBox(
                  height: 280,
                  child: BudgetProgressCard(
                    spentAmount: budgetGoalsModel.totalSpent,
                    totalBudget: budgetGoalsModel.totalMonthlyLimit,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Row 2: Categories (6/12) + Insights + Security (6/12)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: _AnimatedCard(
                index: 2,
                slideAnimation: _slideAnimations[2],
                fadeAnimation: _fadeAnimations[2],
                child: SpendingCategoriesCard(
                  categories: budgetModel.spendingCategories,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  _AnimatedCard(
                    index: 3,
                    slideAnimation: _slideAnimations[3],
                    fadeAnimation: _fadeAnimations[3],
                    child: QuickInsightsCard(
                      savingsAmount: savingsAmount,
                      billsDueLabel: billsDueLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedCard(
                    index: 4,
                    slideAnimation: _slideAnimations[4],
                    fadeAnimation: _fadeAnimations[4],
                    child: SecurityHealthCard(
                      score: securityScore,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _AnimatedCard(
          index: 5,
          slideAnimation: _slideAnimations[5],
          fadeAnimation: _fadeAnimations[5],
          child: const AccountBalancesCard(),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMobileLayout(BudgetModel budgetModel, BudgetGoalsModel budgetGoalsModel,
      int securityScore, double savingsAmount, String billsDueLabel) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _AnimatedCard(
          index: 0,
          slideAnimation: _slideAnimations[0],
          fadeAnimation: _fadeAnimations[0],
          child: NetWorthCard(balance: budgetModel.netBalance),
        ),
        const SizedBox(height: 16),
        _AnimatedCard(
          index: 1,
          slideAnimation: _slideAnimations[1],
          fadeAnimation: _fadeAnimations[1],
          child: BudgetProgressCard(
            spentAmount: budgetGoalsModel.totalSpent,
            totalBudget: budgetGoalsModel.totalMonthlyLimit,
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedCard(
          index: 2,
          slideAnimation: _slideAnimations[2],
          fadeAnimation: _fadeAnimations[2],
          child: SpendingCategoriesCard(
            categories: budgetModel.spendingCategories,
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedCard(
          index: 3,
          slideAnimation: _slideAnimations[3],
          fadeAnimation: _fadeAnimations[3],
          child: QuickInsightsCard(
            savingsAmount: savingsAmount,
            billsDueLabel: billsDueLabel,
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedCard(
          index: 4,
          slideAnimation: _slideAnimations[4],
          fadeAnimation: _fadeAnimations[4],
          child: SecurityHealthCard(
            score: securityScore,
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedCard(
          index: 5,
          slideAnimation: _slideAnimations[5],
          fadeAnimation: _fadeAnimations[5],
          child: const AccountBalancesCard(),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

/// Animated card wrapper for staggered entrance animations.
class _AnimatedCard extends StatelessWidget {
  const _AnimatedCard({
    required this.index,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.child,
  });

  final int index;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}
