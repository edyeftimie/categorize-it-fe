import '../../../domain/models/transaction.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import 'mock_data.dart';

class MockTransactionRepository implements ITransactionRepository {
  final _transactions = List<Transaction>.from(MockData.transactions);

  @override
  Future<List<Transaction>> getTransactions({
    String? search,
    String? categoryId,
    int? month,
    int? year,
    bool? isExpense,
    int page = 1,
    int pageSize = 100,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = _transactions.where((t) {
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (month != null && t.bookingDate.month != month) return false;
      if (year != null && t.bookingDate.year != year) return false;
      if (isExpense != null && t.isExpense != isExpense) return false;

      if (search != null && search.trim().isNotEmpty) {
        final query = search.toLowerCase();
        final matchMerchant = t.merchantName?.toLowerCase().contains(query) ?? false;
        final matchDesc = t.description?.toLowerCase().contains(query) ?? false;
        
        if (!matchMerchant && !matchDesc) return false;
      }

      return true;
    }).toList();

    filtered.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

    final startIndex = (page - 1) * pageSize;
    if (startIndex >= filtered.length) {
      return []; 
    }

    return filtered.skip(startIndex).take(pageSize).toList();
  }

  @override
  Future<Transaction> createTransaction({required double amount, required String currency, required bool isExpense, required DateTime bookingDate, String? merchantName, String? description, String? categoryId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final cat = categoryId != null ? MockData.categories.firstWhere((c) => c.id == categoryId, orElse: () => MockData.categories.last) : MockData.categories.last;
    final t = Transaction(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
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