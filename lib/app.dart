import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'data/providers.dart';
import 'presentation/screens/account/account_screen.dart';
import 'presentation/screens/budgets/add_budget_screen.dart';
import 'presentation/screens/budgets/budgets_screen.dart';
import 'presentation/screens/categories/all_categories_screen.dart';
import 'presentation/screens/categories/category_chart_screen.dart';
import 'presentation/screens/categories/category_transactions_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/insights/insights_screen.dart';
import 'presentation/screens/transactions/transactions_screen.dart';
import 'presentation/widgets/app_bottom_nav.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    routes: [
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/home/all-categories',
        builder: (_, __) => const AllCategoriesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/home/category-transactions',
        builder: (_, state) => CategoryTransactionsScreen(initialCategoryId: state.extra as String?),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/home/category-chart',
        builder: (_, state) => CategoryChartScreen(categoryId: state.extra as String?),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/budgets/add',
        builder: (_, __) => const AddBudgetScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home',         builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/transactions',  builder: (_, __) => const TransactionsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/insights',      builder: (_, __) => const InsightsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/budgets',       builder: (_, __) => const BudgetsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/account',       builder: (_, __) => const AccountScreen())]),
        ],
      ),
    ],
  );
});

class _AppShell extends ConsumerWidget {
  final StatefulNavigationShell shell;
  const _AppShell({required this.shell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    final conn = ref.watch(isConnectedProvider);

    return Scaffold(
      body: Column(
        children: [
          conn.when(
            data: (connected) => connected
                ? const SizedBox.shrink()
                : Container(
                    color: const Color(0xFFEF4444),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Text(
                      'No connection to server',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(child: shell),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: shell.currentIndex,
        unreadCount: unread,
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}