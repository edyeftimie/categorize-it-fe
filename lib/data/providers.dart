import 'package:categoriseit_fe/core/services/google_sign_in_service.dart';
import 'package:categoriseit_fe/data/repositories/api/budget_repository.dart';
import 'package:categoriseit_fe/data/repositories/api/category_repository.dart';
import 'package:categoriseit_fe/data/repositories/api/dashboard_repository.dart';
import 'package:categoriseit_fe/data/repositories/api/recommendation_repository.dart';
import 'package:categoriseit_fe/data/repositories/api/transaction_repository.dart';
import 'package:categoriseit_fe/domain/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/budget.dart';
import '../domain/models/dashboard.dart';
import '../domain/models/recommendation.dart';
import '../domain/models/transaction.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../domain/repositories/i_bank_connection_repository.dart';
import '../domain/repositories/i_budget_repository.dart';
import '../domain/repositories/i_category_repository.dart';
import '../domain/repositories/i_dashboard_repository.dart';
import '../domain/repositories/i_recommendation_repository.dart';
import '../domain/repositories/i_transaction_repository.dart';
// import 'repositories/mock/mock_auth_repository.dart';
import 'repositories/mock/mock_bank_connection_repository.dart';
import 'repositories/mock/mock_budget_repository.dart';
// import 'repositories/mock/mock_category_repository.dart';
// import 'repositories/mock/mock_dashboard_repository.dart';
import 'repositories/mock/mock_recommendation_repository.dart';
// import 'repositories/mock/mock_transaction_repository.dart';
import '../core/services/connectivity_service.dart';
import 'package:dio/dio.dart';
import '../core/services/token_storage.dart';
import '../core/network/dio_client.dart';
import 'repositories/api/auth_repository.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.startMonitoring();
  ref.onDispose(() => service.dispose());
  return service;
});

final isConnectedProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).stream;
});

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final Provider<Dio> dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  return DioClient(
    tokenStorage,
    onUnauthorized: () {
      ref.read(authControllerProvider.notifier).forceLogout();
      ref.invalidate(dashboardProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(budgetsProvider);
      ref.invalidate(recommendationsProvider);
      ref.invalidate(bankConnectionsProvider);
    },
  ).dio;
});


class AuthController extends StateNotifier<AsyncValue<User?>> {
  final IAuthRepository _repo;

  AuthController(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = await AsyncValue.guard(() => _repo.getCurrentUser());
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _repo.login(email: email, password: password);
      return result.user;
    });
  }

  Future<void> register({required String name, required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _repo.register(username: name, email: email, password: password);
      return result.user;
    });
  }

  Future<void> googleLogin() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final idToken = await GoogleSignInService.getIdToken();
      if (idToken == null) throw Exception('Google Sign-In was cancelled.');
      final result = await _repo.googleLogin(idToken: idToken);
      return result.user;
    });
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }

  // Synchronous — does NOT call backend. Resets state so router redirects to /login.
  void forceLogout() {
    state = const AsyncValue.data(null);
  }
}

final googleSignInServiceProvider = Provider<GoogleSignInService>(
  (ref) => GoogleSignInService(),
);

// final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>(
//   (ref) => AuthController(
//     ref.read(authRepositoryProvider),
//   ),
// );
final StateNotifierProvider<AuthController, AsyncValue<User?>> authControllerProvider =
  StateNotifierProvider<AuthController, AsyncValue<User?>>(
    (ref) => AuthController(ref.read(authRepositoryProvider)),
  );

// repos with api
final authRepositoryProvider = Provider<IAuthRepository>((ref) => ApiAuthRepository(
  dio: ref.read(dioProvider),
  tokenStorage: ref.read(tokenStorageProvider),
));
final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) => CategoryRepository(dio: ref.read(dioProvider)));
final dashboardRepositoryProvider = Provider<IDashboardRepository>((ref) => DashboardRepository(dio: ref.read(dioProvider)));
final transactionRepositoryProvider    = Provider<ITransactionRepository>((ref)    => TransactionRepository(ref.read(dioProvider)));
final recommendationRepositoryProvider = Provider<IRecommendationRepository>((ref) => RecommendationRepository(ref.read(dioProvider)));
final budgetRepositoryProvider = Provider<IBudgetRepository>((ref) => BudgetRepository(ref.read(dioProvider)));

// repos with mock
// final authRepositoryProvider           = Provider<IAuthRepository>((ref)           => MockAuthRepository());
// final transactionRepositoryProvider    = Provider<ITransactionRepository>((ref)    => MockTransactionRepository());
// final categoryRepositoryProvider       = Provider<ICategoryRepository>((ref)       => MockCategoryRepository());
// final budgetRepositoryProvider         = Provider<IBudgetRepository>((ref)         => MockBudgetRepository());
// final recommendationRepositoryProvider = Provider<IRecommendationRepository>((ref) => MockRecommendationRepository());
final bankConnectionRepositoryProvider = Provider<IBankConnectionRepository>((ref) => MockBankConnectionRepository());
// final dashboardRepositoryProvider      = Provider<IDashboardRepository>((ref)      => MockDashboardRepository());

// final currentUserProvider = FutureProvider<User?>((ref) => ref.read(authRepositoryProvider).getCurrentUser());
final dashboardProvider  = FutureProvider<DashboardData>((ref) => ref.read(dashboardRepositoryProvider).getDashboard());
final categoriesProvider = FutureProvider((ref) => ref.read(categoryRepositoryProvider).getCategories());
final transactionsProvider = FutureProvider<List<Transaction>>((ref) => ref.read(transactionRepositoryProvider).getTransactions());
final currentMonthTransactionsProvider = FutureProvider<List<Transaction>>((ref) {
  final now = DateTime.now();
  return ref.read(transactionRepositoryProvider)
      .getTransactions(month: now.month, year: now.year);
});
final previousMonthTransactionsProvider = FutureProvider<List<Transaction>>((ref) {
  final now       = DateTime.now();
  final prevMonth = now.month == 1 ? 12 : now.month - 1;
  final prevYear  = now.month == 1 ? now.year - 1 : now.year;
  return ref.read(transactionRepositoryProvider)
      .getTransactions(month: prevMonth, year: prevYear);
});
final bankConnectionsProvider = FutureProvider((ref) => ref.read(bankConnectionRepositoryProvider).getConnections());

class BudgetsNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  final IBudgetRepository _repo;
  final Ref _ref;

  BudgetsNotifier(this._repo, this._ref) : super(const AsyncValue.loading()) { _load(); }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getBudgets);
  }

  Future<void> create({required String categoryId, required double monthlyLimit}) async {
    final b = await _repo.createBudget(categoryId: categoryId, monthlyLimit: monthlyLimit);
    state = state.whenData((list) => [...list, b]);
    _ref.invalidate(recommendationsProvider);
    _ref.invalidate(dashboardProvider);
  }

  Future<void> update(String id, {required double monthlyLimit}) async {
    final b = await _repo.updateBudget(id, monthlyLimit: monthlyLimit);
    state = state.whenData((list) => list.map((e) => e.id == id ? b : e).toList());
    _ref.invalidate(recommendationsProvider);
    _ref.invalidate(dashboardProvider);
  }

  Future<void> delete(String id) async {
    await _repo.deleteBudget(id);
    state = state.whenData((list) => list.where((b) => b.id != id).toList());
    _ref.invalidate(recommendationsProvider);
    _ref.invalidate(dashboardProvider);
  }
}

final StateNotifierProvider<BudgetsNotifier, AsyncValue<List<Budget>>> budgetsProvider =
    StateNotifierProvider<BudgetsNotifier, AsyncValue<List<Budget>>>(
      (ref) => BudgetsNotifier(ref.read(budgetRepositoryProvider), ref));

class RecommendationsNotifier extends StateNotifier<AsyncValue<List<Recommendation>>> {
  final IRecommendationRepository _repo;

  RecommendationsNotifier(this._repo) : super(const AsyncValue.loading()) { _load(); }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getRecommendations);
  }

  Future<void> reload() => _load();

  Future<void> dismiss(String id) async {
    await _repo.dismiss(id);
    state = state.whenData((list) => list.where((r) => r.id != id).toList());
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    state = state.whenData((list) => list.map((r) => r.id == id ? r.copyWith(isRead: true) : r).toList());
  }
}

class TransactionsMutationNotifier extends StateNotifier<AsyncValue<void>> {
  final ITransactionRepository _repo;
  final Ref _ref;

  TransactionsMutationNotifier(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  void _invalidateAll() {
    _ref.invalidate(recommendationsProvider);
    _ref.invalidate(dashboardProvider);
    _ref.invalidate(transactionsProvider);
    _ref.invalidate(currentMonthTransactionsProvider);   // ← add
    _ref.invalidate(previousMonthTransactionsProvider);  // ← add
    _ref.invalidate(budgetsProvider);
  }

  Future<Transaction> createTransaction({
    required double amount,
    required String currency,
    required bool isExpense,
    required DateTime bookingDate,
    String? merchantName,
    String? description,
    String? categoryId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final t = await _repo.createTransaction(
        amount: amount, currency: currency, isExpense: isExpense,
        bookingDate: bookingDate, merchantName: merchantName,
        description: description, categoryId: categoryId,
      );
      _invalidateAll();
      state = const AsyncValue.data(null);
      return t;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Transaction> recategorise(String transactionId, String categoryId) async {
    state = const AsyncValue.loading();
    try {
      final t = await _repo.recategorise(transactionId, categoryId);
      _invalidateAll();
      state = const AsyncValue.data(null);
      return t;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> sync() async {
    state = const AsyncValue.loading();
    try {
      await _repo.sync();
      _invalidateAll();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final StateNotifierProvider<TransactionsMutationNotifier, AsyncValue<void>>
    transactionsMutationProvider =
    StateNotifierProvider<TransactionsMutationNotifier, AsyncValue<void>>(
      (ref) => TransactionsMutationNotifier(ref.read(transactionRepositoryProvider), ref));

final recommendationsProvider = StateNotifierProvider<RecommendationsNotifier, AsyncValue<List<Recommendation>>>(
  (ref) => RecommendationsNotifier(ref.read(recommendationRepositoryProvider)));

final unreadCountProvider = Provider<int>((ref) =>
  ref.watch(recommendationsProvider).whenOrNull(
    data: (list) => list.where((r) => !r.isRead).length,
  ) ?? 0);