import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/transactions/presentation/screens/transaction_history_screen.dart';
import '../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../features/budget_goals/presentation/screens/budgets_goals_screen.dart';
import '../features/accounts/presentation/screens/account_detail_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/accounts/presentation/screens/accounts_screen.dart';

/// App router configuration using go_router with ShellRoute for tab navigation.
final GoRouter appRouter = GoRouter(
  initialLocation: DashboardScreen.routePath,
  debugLogDiagnostics: false,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return _ShellScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: DashboardScreen.routePath,
          name: DashboardScreen.routeName,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: TransactionHistoryScreen.routePath,
          name: TransactionHistoryScreen.routeName,
          builder: (context, state) => const TransactionHistoryScreen(),
        ),
        GoRoute(
          path: BudgetsGoalsScreen.routePath,
          name: BudgetsGoalsScreen.routeName,
          builder: (context, state) => const BudgetsGoalsScreen(),
        ),
        GoRoute(
          path: SettingsScreen.routePath,
          name: SettingsScreen.routeName,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AccountsScreen.routePath,
          name: AccountsScreen.routeName,
          builder: (context, state) => const AccountsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: AddTransactionScreen.routePath,
      name: AddTransactionScreen.routeName,
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: '/accounts/:accountId',
      name: AccountDetailScreen.routeName,
      builder: (context, state) {
        final accountId = state.pathParameters['accountId']!;
        return AccountDetailScreen(accountId: accountId);
      },
    ),
  ],
);

/// Shell scaffold that provides bottom navigation bar around tab content.
class _ShellScaffold extends StatefulWidget {
  const _ShellScaffold({required this.child});
  final Widget child;

  @override
  State<_ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<_ShellScaffold> {
  int _currentIndex = 0;

  static const List<_TabInfo> _tabs = [
    _TabInfo(icon: Icons.home, label: 'Home', path: '/dashboard'),
    _TabInfo(icon: Icons.receipt_long, label: 'History', path: '/transactions'),
    _TabInfo(icon: Icons.add_circle, label: 'Add', path: '/add'),
    _TabInfo(icon: Icons.account_balance_wallet, label: 'Accounts', path: '/accounts'),
    _TabInfo(icon: Icons.track_changes, label: 'Budgets', path: '/budgets'),
    _TabInfo(icon: Icons.settings, label: 'Settings', path: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine current tab from location
    final location = GoRouterState.of(context).uri.toString();
    _currentIndex = _tabs.indexWhere((tab) => location.startsWith(tab.path));
    if (_currentIndex < 0) _currentIndex = 0;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF041627).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isActive = _currentIndex == index;

              return GestureDetector(
                onTap: () {
                  if (tab.path == '/add') {
                    context.push(AddTransactionScreen.routePath);
                  } else {
                    context.go(tab.path);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: isActive
                      ? BoxDecoration(
                          color: const Color(0xFFD5E0F7),
                          borderRadius: BorderRadius.circular(9999),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        color: isActive
                            ? const Color(0xFF586377)
                            : const Color(0xFF44474C),
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.05,
                          color: isActive
                              ? const Color(0xFF586377)
                              : const Color(0xFF44474C),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabInfo {
  final IconData icon;
  final String label;
  final String path;
  const _TabInfo({required this.icon, required this.label, required this.path});
}
