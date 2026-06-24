import 'package:categoriseit_fe/core/services/google_sign_in_service.dart';
import 'package:categoriseit_fe/data/repositories/api/category_repository.dart';
import 'package:categoriseit_fe/data/repositories/api/dashboard_repository.dart';
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

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  return DioClient(tokenStorage).dio;
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

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>(
  (ref) => AuthController(
    ref.read(authRepositoryProvider),
  ),
);

// repos with api
final authRepositoryProvider = Provider<IAuthRepository>((ref) => ApiAuthRepository(
  dio: ref.read(dioProvider),
  tokenStorage: ref.read(tokenStorageProvider),
));
final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) => CategoryRepository(dio: ref.read(dioProvider)));
final dashboardRepositoryProvider = Provider<IDashboardRepository>((ref) => DashboardRepository(dio: ref.read(dioProvider)));
final transactionRepositoryProvider    = Provider<ITransactionRepository>((ref)    => TransactionRepository(ref.read(dioProvider)));

// repos with mock
// final authRepositoryProvider           = Provider<IAuthRepository>((ref)           => MockAuthRepository());
// final transactionRepositoryProvider    = Provider<ITransactionRepository>((ref)    => MockTransactionRepository());
// final categoryRepositoryProvider       = Provider<ICategoryRepository>((ref)       => MockCategoryRepository());
final budgetRepositoryProvider         = Provider<IBudgetRepository>((ref)         => MockBudgetRepository());
final recommendationRepositoryProvider = Provider<IRecommendationRepository>((ref) => MockRecommendationRepository());
final bankConnectionRepositoryProvider = Provider<IBankConnectionRepository>((ref) => MockBankConnectionRepository());
// final dashboardRepositoryProvider      = Provider<IDashboardRepository>((ref)      => MockDashboardRepository());

// final currentUserProvider = FutureProvider<User?>((ref) => ref.read(authRepositoryProvider).getCurrentUser());
final dashboardProvider  = FutureProvider<DashboardData>((ref) => ref.read(dashboardRepositoryProvider).getDashboard());
final categoriesProvider = FutureProvider((ref) => ref.read(categoryRepositoryProvider).getCategories());
final transactionsProvider = FutureProvider<List<Transaction>>((ref) => ref.read(transactionRepositoryProvider).getTransactions());
final bankConnectionsProvider = FutureProvider((ref) => ref.read(bankConnectionRepositoryProvider).getConnections());

class BudgetsNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  final IBudgetRepository _repo;
  BudgetsNotifier(this._repo) : super(const AsyncValue.loading()) { _load(); }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getBudgets);
  }

  Future<void> create({required String categoryId, required double monthlyLimit}) async {
    final b = await _repo.createBudget(categoryId: categoryId, monthlyLimit: monthlyLimit);
    state = state.whenData((list) => [...list, b]);
  }

  Future<void> delete(String id) async {
    await _repo.deleteBudget(id);
    state = state.whenData((list) => list.where((b) => b.id != id).toList());
  }
}

final budgetsProvider = StateNotifierProvider<BudgetsNotifier, AsyncValue<List<Budget>>>(
  (ref) => BudgetsNotifier(ref.read(budgetRepositoryProvider)));

class RecommendationsNotifier extends StateNotifier<AsyncValue<List<Recommendation>>> {
  final IRecommendationRepository _repo;
  RecommendationsNotifier(this._repo) : super(const AsyncValue.loading()) { _load(); }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getRecommendations);
  }

  Future<void> dismiss(String id) async {
    await _repo.dismiss(id);
    state = state.whenData((list) => list.where((r) => r.id != id).toList());
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    state = state.whenData((list) => list.map((r) => r.id == id ? r.copyWith(isRead: true) : r).toList());
  }
}

final recommendationsProvider = StateNotifierProvider<RecommendationsNotifier, AsyncValue<List<Recommendation>>>(
  (ref) => RecommendationsNotifier(ref.read(recommendationRepositoryProvider)));

final unreadCountProvider = Provider<int>((ref) =>
  ref.watch(recommendationsProvider).whenOrNull(
    data: (list) => list.where((r) => !r.isRead).length,
  ) ?? 0);