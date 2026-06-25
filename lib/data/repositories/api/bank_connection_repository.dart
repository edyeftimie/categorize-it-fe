import 'package:categoriseit_fe/core/network/api_exception.dart';
import 'package:categoriseit_fe/domain/models/bank.dart';
import 'package:categoriseit_fe/domain/models/bank_connection.dart';
import 'package:categoriseit_fe/domain/repositories/i_bank_connection_repository.dart';
import 'package:dio/dio.dart';

class BankConnectionRepository implements IBankConnectionRepository {
  final Dio _dio;
  BankConnectionRepository(this._dio);

  @override
  Future<List<BankConnection>> getConnections() async {
    try {
      final r = await _dio.get<List<dynamic>>('/api/bank-connections');
      return (r.data ?? [])
          .map((e) => BankConnection.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<Bank>> getAvailableBanks() async {
    try {
      final r = await _dio.get<List<dynamic>>('/api/banks');
      return (r.data ?? [])
          .map((e) => Bank.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<({String url, String state})> initiateAuth({
    required String aspspName,
    required String aspspCountry,
  }) async {
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '/api/bank-connections/auth',
        data: {'aspspName': aspspName, 'aspspCountry': aspspCountry},
      );
      final data = r.data!;
      return (url: data['url'] as String, state: data['state'] as String);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<BankConnection> handleCallback({required String code}) async {
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '/api/bank-connections/callback',
        data: {'code': code},
      );
      return BankConnection.fromJson(r.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> disconnect(String id) async {
    try {
      await _dio.delete<void>('/api/bank-connections/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}