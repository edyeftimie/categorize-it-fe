import '../models/transaction.dart';

abstract interface class ITransactionRepository {
  Future<List<Transaction>> getTransactions({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? categoryId,
    String? bankAccountId,
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