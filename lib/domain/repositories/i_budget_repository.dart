import '../models/budget.dart';

abstract interface class IBudgetRepository {
  Future<List<Budget>> getBudgets();
  Future<Budget> createBudget({
    required String categoryId,
    required double monthlyLimit,
    String currency = 'RON',
  });
  Future<Budget> updateBudget(String id, {required double monthlyLimit});
  Future<void> deleteBudget(String id);
}