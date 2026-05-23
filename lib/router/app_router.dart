import 'package:go_router/go_router.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/transactions/presentation/screens/transaction_history_screen.dart';

/// App router configuration using go_router.
final GoRouter appRouter = GoRouter(
  initialLocation: DashboardScreen.routePath,
  debugLogDiagnostics: false,
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
  ],
);
