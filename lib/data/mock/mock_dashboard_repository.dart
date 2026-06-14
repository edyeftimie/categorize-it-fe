import '../../domain/models/dashboard.dart';
import '../../domain/repositories/i_dashboard_repository.dart';
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
      MonthlyAmount('Dec', 0), MonthlyAmount('Jan', 0), MonthlyAmount('Feb', 0),
      MonthlyAmount('Mar', 0), MonthlyAmount('Apr', 0), MonthlyAmount('May', 0),
    ];
  }
}