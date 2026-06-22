import '../../domain/models/budget.dart';
import '../../domain/repositories/i_budget_repository.dart';
import 'mock_data.dart';

class MockBudgetRepository implements IBudgetRepository {
  final _budgets = List<Budget>.from(MockData.budgets);

  @override
  Future<List<Budget>> getBudgets() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_budgets);
  }

  @override
  Future<Budget> createBudget({required String categoryId, required double monthlyLimit, String currency = 'RON'}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final cat = MockData.categories.firstWhere((c) => c.id == categoryId);
    final b = Budget(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      categoryId: cat.id, categoryName: cat.name, categoryIcon: cat.icon, categoryColor: cat.color,
      monthlyLimit: monthlyLimit, spent: 0, currency: currency,
    );
    _budgets.add(b);
    return b;
  }

  @override
  Future<Budget> updateBudget(String id, {required double monthlyLimit}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _budgets.indexWhere((b) => b.id == id);
    final updated = _budgets[idx].copyWith(monthlyLimit: monthlyLimit);
    _budgets[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteBudget(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _budgets.removeWhere((b) => b.id == id);
  }
}