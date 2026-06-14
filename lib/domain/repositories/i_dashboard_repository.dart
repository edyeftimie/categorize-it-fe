import '../models/dashboard.dart';

abstract interface class IDashboardRepository {
  Future<DashboardData> getDashboard();
  Future<List<MonthlyAmount>> getMonthlySeries(String categoryId);
}