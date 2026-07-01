import 'package:categoriseit_fe/core/network/api_exception.dart';
import 'package:categoriseit_fe/domain/models/dashboard.dart';
import 'package:categoriseit_fe/domain/repositories/i_dashboard_repository.dart';
import 'package:dio/dio.dart';

class DashboardRepository implements IDashboardRepository {
  final Dio _dio;

  DashboardRepository({required Dio dio}) : _dio = dio;

  @override
  Future<DashboardData> getDashboard() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/dashboard');
      return DashboardData.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<MonthlyAmount>> getMonthlySeries(String categoryId) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/api/dashboard/monthly-series/$categoryId',
      );
      return (response.data ?? [])
          .map((e) => _parseMonthlyAmount(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
  

  MonthlyAmount _parseMonthlyAmount(Map<String, dynamic> j) =>
    MonthlyAmount.fromJson(j);
}