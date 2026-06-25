import 'package:categoriseit_fe/core/network/api_exception.dart';
import 'package:categoriseit_fe/domain/models/budget.dart';
import 'package:categoriseit_fe/domain/repositories/i_budget_repository.dart';
import 'package:dio/dio.dart';

class BudgetRepository implements IBudgetRepository {
  final Dio _dio;
  BudgetRepository(this._dio);

  @override
  Future<List<Budget>> getBudgets() async {
    try {
      final r = await _dio.get<List<dynamic>>('/api/budgets');
      return (r.data ?? [])
          .map((e) => Budget.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Budget> createBudget({
    required String categoryId,
    required double monthlyLimit,
    String currency = 'RON',
  }) async {
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '/api/budgets',
        data: {
          'categoryId': categoryId,
          'monthlyLimit': monthlyLimit,
          'currency': currency,
        },
      );
      final id = r.data!['id'] as String;
      // POST returns only { id }. Refetch to get the full populated Budget
      // (categoryName/icon/color/amountSpent come from the server).
      final all = await getBudgets();
      return all.firstWhere((b) => b.id == id);
    } on DioException catch (e) {
      // 409 Conflict message ("A budget for this category already exists.")
      // is extracted from the response body by ApiException.fromDioException.
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Budget> updateBudget(String id, {required double monthlyLimit}) async {
    try {
      await _dio.put<void>(
        '/api/budgets/$id',
        data: {'monthlyLimit': monthlyLimit},
      );
      // PUT returns 204. Refetch to return the current server state.
      final all = await getBudgets();
      return all.firstWhere((b) => b.id == id);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    try {
      await _dio.delete<void>('/api/budgets/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}