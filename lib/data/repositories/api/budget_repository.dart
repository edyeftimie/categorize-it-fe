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
      final all = await getBudgets();
      return all.firstWhere((b) => b.id == id);
    } on DioException catch (e) {
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