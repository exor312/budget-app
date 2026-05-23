import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../transactions/data/budget_model.dart';
import '../widgets/net_worth_card.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/spending_categories_card.dart';
import '../widgets/quick_insights_card.dart';
import '../widgets/security_health_card.dart';

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

  static const double _monthlyBudget = 4500.0;

  @override
  void initState() {
    super.initState();

    // Scroll shadow listener
    _scrollController.addListener(_onScroll);

    // Initialize staggered animations for 6 cards
    _controllers = List.generate(6, (index) {
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
                    child: Consumer<BudgetModel>(
                      builder: (context, model, _) {
                        return isDesktop
                            ? _buildDesktopLayout(model)
                            : _buildMobileLayout(model);
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
              onPressed: () => _showAddTransactionSheet(context),
              backgroundColor: FortunaColors.primary,
              foregroundColor: FortunaColors.onPrimary,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 32),
            )
          : null,
    );
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

  Widget _buildDesktopLayout(BudgetModel model) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Row 1: Net Worth (8/12) + Budget (4/12)
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
                  balance: model.netBalance,
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
                    spentAmount: model.monthlySpending,
                    totalBudget: _monthlyBudget,
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
                  categories: model.spendingCategories,
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
                    child: const QuickInsightsCard(),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedCard(
                    index: 4,
                    slideAnimation: _slideAnimations[4],
                    fadeAnimation: _fadeAnimations[4],
                    child: const SecurityHealthCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMobileLayout(BudgetModel model) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _AnimatedCard(
          index: 0,
          slideAnimation: _slideAnimations[0],
          fadeAnimation: _fadeAnimations[0],
          child: NetWorthCard(balance: model.netBalance),
        ),
        const SizedBox(height: 16),
        _AnimatedCard(
          index: 1,
          slideAnimation: _slideAnimations[1],
          fadeAnimation: _fadeAnimations[1],
          child: BudgetProgressCard(
            spentAmount: model.monthlySpending,
            totalBudget: _monthlyBudget,
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedCard(
          index: 2,
          slideAnimation: _slideAnimations[2],
          fadeAnimation: _fadeAnimations[2],
          child: SpendingCategoriesCard(
            categories: model.spendingCategories,
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedCard(
          index: 3,
          slideAnimation: _slideAnimations[3],
          fadeAnimation: _fadeAnimations[3],
          child: const QuickInsightsCard(),
        ),
        const SizedBox(height: 16),
        _AnimatedCard(
          index: 4,
          slideAnimation: _slideAnimations[4],
          fadeAnimation: _fadeAnimations[4],
          child: const SecurityHealthCard(),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: const TransactionFormSheet(),
      ),
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

/// Animated card wrapper for staggered entrance animations.
class TransactionFormSheet extends StatefulWidget {
  const TransactionFormSheet({super.key});

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isIncome = true;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;

      context.read<BudgetModel>().addTransaction(
            amount: _isIncome ? amount : -amount,
            description: description,
          );

      _amountController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FortunaColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Transaction',
              style: FortunaTextStyles.titleMd.copyWith(
                color: FortunaColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Type:'),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Income'),
                  selected: _isIncome,
                  selectedColor: FortunaColors.secondaryContainer,
                  onSelected: (selected) {
                    setState(() => _isIncome = selected);
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Expense'),
                  selected: !_isIncome,
                  selectedColor: FortunaColors.secondaryContainer,
                  onSelected: (selected) {
                    setState(() => _isIncome = !selected);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _addTransaction,
                child: const Text('Add Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
