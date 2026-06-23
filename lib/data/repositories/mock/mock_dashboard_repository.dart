import '../../../domain/models/dashboard.dart';
import '../../../domain/repositories/i_dashboard_repository.dart';
import 'mock_data.dart';

class MockDashboardRepository implements IDashboardRepository {
  @override
  Future<DashboardData> getDashboard() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.dashboard;
  }

  @override
  Future<List<MonthlyAmount>> getMonthlySeries(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.monthlySeries[categoryId] ?? [
      const MonthlyAmount(month: 12, year: 2023, total: 0),
      const MonthlyAmount(month: 1, year: 2024, total: 0),
      const MonthlyAmount(month: 2, year: 2024, total: 0),
      const MonthlyAmount(month: 3, year: 2024, total: 0),
      const MonthlyAmount(month: 4, year: 2024, total: 0),
      const MonthlyAmount(month: 5, year: 2024, total: 0),
    ];
  }
}