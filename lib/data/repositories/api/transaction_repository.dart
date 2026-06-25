import 'package:categoriseit_fe/core/network/api_exception.dart';
import 'package:categoriseit_fe/domain/models/transaction.dart';
import 'package:categoriseit_fe/domain/repositories/i_transaction_repository.dart';
import 'package:dio/dio.dart';

class TransactionRepository implements ITransactionRepository {
  final Dio _dio;
  TransactionRepository(this._dio);

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
    try {
      final params = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        if (search     != null) 'search':     search,
        if (categoryId != null) 'categoryId': categoryId,
        if (month      != null) 'month':      month,
        if (year       != null) 'year':       year,
        if (isExpense  != null) 'isExpense':  isExpense,
      };

      final r = await _dio.get<dynamic>('/api/transactions', queryParameters: params);

      // Backend may return a bare list or a paginated wrapper { items: [...], totalCount: int }
      final List<dynamic> raw;
      if (r.data is List) {
        raw = r.data as List<dynamic>;
      } else {
        final wrapper = r.data as Map<String, dynamic>;
        raw = (wrapper['items'] ?? wrapper['data'] ?? []) as List<dynamic>;
      }

      return raw.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Transaction> createTransaction({
    required double amount,
    required String currency,
    required bool isExpense,
    required DateTime bookingDate,
    String? merchantName,
    String? description,
    String? categoryId,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
        'currency': currency,
        'isExpense': isExpense,
        'bookingDate': bookingDate.toUtc().toIso8601String(),
        if (merchantName != null) 'merchantName': merchantName,
        if (description  != null) 'description':  description,
        if (categoryId   != null) 'categoryId':   categoryId,
      };

      final r = await _dio.post<Map<String, dynamic>>('/api/transactions', data: body);
      final id = r.data!['id'] as String;

      // API returns only { id }; construct from known fields.
      return Transaction(
        id: id,
        amount: amount,
        currency: currency,
        isExpense: isExpense,
        bookingDate: bookingDate,
        merchantName: merchantName,
        description: description,
        categoryId: categoryId,
        isManual: true,
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Transaction> recategorise(String transactionId, String categoryId) async {
    try {
      await _dio.patch<void>(
        '/api/transactions/$transactionId/category',
        data: {'categoryId': categoryId},
      );
      final all = await getTransactions();
      return all.firstWhere((t) => t.id == transactionId);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> sync() async {
    try {
      await _dio.post<void>('/api/transactions/sync');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}