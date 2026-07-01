import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:categoriseit_fe/presentation/screens/transactions/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'core/network/api_exception.dart';
import 'core/theme/app_colors.dart';
import 'data/providers.dart';
import 'domain/models/budget.dart';
import 'domain/models/user.dart';
import 'presentation/screens/account/account_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/banks/select_bank_screen.dart';
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

class _AuthNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

const _storage     = FlutterSecureStorage();
const _lastCodeKey = 'bank_cb_last_code';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthNotifier();

  ref.listen<AsyncValue<User?>>(authControllerProvider, (prev, next) {
    print('AUTH CHANGED: prev=${prev?.valueOrNull?.id}, next=${next.valueOrNull?.id}, isLoading=${next.isLoading}');
    notifier.notify();
  });

  ref.listen<AsyncValue<User?>>(
    authControllerProvider,
    (prev, next) {
      if (prev?.valueOrNull?.id != next.valueOrNull?.id) {
        ref.invalidate(dashboardProvider);
        ref.invalidate(transactionsProvider);
        ref.invalidate(categoriesProvider);
        ref.invalidate(budgetsProvider);
        ref.invalidate(recommendationsProvider);
        ref.invalidate(bankConnectionsProvider);
      }
    },
  );

  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authAsync = ref.read(authControllerProvider);
      print('REDIRECT: loc=${state.matchedLocation}, isLoading=${authAsync.isLoading}, authed=${authAsync.valueOrNull != null}');
      if (authAsync.isLoading) return null;

      final isAuthenticated = authAsync.valueOrNull != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    onException: (_, state, router) {
      if (state.uri.scheme.toLowerCase() == 'categoriseit') return;
    },
    routes: [
      GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

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
        builder: (_, state) => AddBudgetScreen(budget: state.extra as Budget?),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/banks/select',
        builder: (_, __) => const SelectBankScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/transactions/add',
        builder: (_, __) => const AddTransactionScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home',        builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/transactions', builder: (_, __) => const TransactionsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/insights',     builder: (_, __) => const InsightsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/budgets',      builder: (_, __) => const BudgetsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/account',      builder: (_, __) => const AccountScreen())]),
        ],
      ),
    ],
  );
});

class _AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;
  const _AppShell({required this.shell});

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  StreamSubscription<Uri>? _linkSub;
  bool _processingCallback = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initDeepLinks());
  }

  Future<void> _initDeepLinks() async {
    final appLinks = AppLinks();
    try {
      final initial = await appLinks.getInitialLink();
      if (initial != null) await _handleLink(initial);
    } catch (_) {}
    _linkSub = appLinks.uriLinkStream.listen(
      (uri) => _handleLink(uri),
      onError: (_) {},
    );
  }

  Future<void> _handleLink(Uri uri) async {
    if (uri.scheme.toLowerCase() != 'categoriseit' || uri.host != 'bank-callback') return;
    final code = uri.queryParameters['code'];
    if (code == null || code.isEmpty) return;

    final lastCode = await _storage.read(key: _lastCodeKey);
    if (code == lastCode) return;
    await _storage.write(key: _lastCodeKey, value: code);

    _processCallback(code);
  }

  Future<void> _processCallback(String code) async {
    if (mounted) setState(() => _processingCallback = true);
    try {
      await ref.read(bankConnectionRepositoryProvider).handleCallback(code: code);
      await ref.read(transactionsMutationProvider.notifier).sync();
      ref.invalidate(bankConnectionsProvider);
      if (!mounted) return;
      setState(() => _processingCallback = false);

      GoRouter.of(context).go('/account');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bank connected successfully'),
          backgroundColor: AppColors.emerald,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _processingCallback = false);

      final msg = e is ApiException ? e.message : 'Bank connection failed. Please try again.';
      GoRouter.of(context).go('/account');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.red),
      );
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadCountProvider);
    final conn   = ref.watch(isConnectedProvider);

    return Stack(
      children: [
        Scaffold(
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
                error:   (_, __) => const SizedBox.shrink(),
              ),
              Expanded(child: widget.shell),
            ],
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: widget.shell.currentIndex,
            unreadCount: unread,
            onTap: (i) => widget.shell.goBranch(i, initialLocation: i == widget.shell.currentIndex),
          ),
        ),

        if (_processingCallback)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.emerald),
                  SizedBox(height: 16),
                  Text(
                    'Connecting your bank…',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}