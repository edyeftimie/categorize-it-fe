import '../models/transaction.dart';

abstract interface class ITransactionRepository {
  Future<List<Transaction>> getTransactions({
    String? search,
    String? categoryId,
    int? month,
    int? year,
    bool? isExpense,
    int page = 1,
    int pageSize = 100,
  });

  Future<Transaction> createTransaction({
    required double amount,
    required String currency,
    required bool isExpense,
    required DateTime bookingDate,
    String? merchantName,
    String? description,
    String? categoryId,
  });

  Future<Transaction> recategorise(String transactionId, String categoryId);

  Future<void> sync();
}