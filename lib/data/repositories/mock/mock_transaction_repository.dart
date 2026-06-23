import '../../../domain/models/transaction.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import 'mock_data.dart';

class MockTransactionRepository implements ITransactionRepository {
  final _transactions = List<Transaction>.from(MockData.transactions);

  @override
  Future<List<Transaction>> getTransactions({DateTime? dateFrom, DateTime? dateTo, String? categoryId, String? bankAccountId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions.where((t) {
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (dateFrom != null && t.bookingDate.isBefore(dateFrom)) return false;
      if (dateTo   != null && t.bookingDate.isAfter(dateTo))   return false;
      return true;
    }).toList()
      ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
  }

  @override
  Future<Transaction> createTransaction({required double amount, required String currency, required bool isExpense, required DateTime bookingDate, String? merchantName, String? description, String? categoryId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final cat = categoryId != null ? MockData.categories.firstWhere((c) => c.id == categoryId, orElse: () => MockData.categories.last) : MockData.categories.last;
    final t = Transaction(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}', userId: 'u1',
      amount: amount, currency: currency, isExpense: isExpense, bookingDate: bookingDate,
      merchantName: merchantName, description: description, categoryId: cat.id,
      categoryName: cat.name, categoryIcon: cat.icon, categoryColor: cat.color,
      isManual: true, createdAt: DateTime.now(),
    );
    _transactions.insert(0, t);
    return t;
  }

  @override
  Future<Transaction> recategorise(String transactionId, String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _transactions.indexWhere((t) => t.id == transactionId);
    final cat = MockData.categories.firstWhere((c) => c.id == categoryId);
    final updated = _transactions[idx].copyWith(categoryId: cat.id, categoryName: cat.name, categoryIcon: cat.icon, categoryColor: cat.color);
    _transactions[idx] = updated;
    return updated;
  }

  @override
  Future<void> sync() async => Future.delayed(const Duration(seconds: 2));
}