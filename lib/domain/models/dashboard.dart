class CategorySpending {
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final double amount;
  final double? budgetLimit;
  final double percentage;

  const CategorySpending({
    required this.categoryId, required this.categoryName,
    this.categoryIcon, this.categoryColor,
    required this.amount, this.budgetLimit, required this.percentage,
  });
}

class NeedWantSplit {
  final double need;
  final double want;
  final double savings;

  const NeedWantSplit({required this.need, required this.want, required this.savings});

  double get total => need + want + savings;
  double get needPct    => total > 0 ? need / total    : 0;
  double get wantPct    => total > 0 ? want / total    : 0;
  double get savingsPct => total > 0 ? savings / total : 0;
}

class DashboardData {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final List<CategorySpending> categoryBreakdown;
  final NeedWantSplit needWantSplit;
  final DateTime month;

  const DashboardData({
    required this.totalBalance, required this.totalIncome,
    required this.totalExpenses, required this.categoryBreakdown,
    required this.needWantSplit, required this.month,
  });
}

class MonthlyAmount {
  final String month;
  final double amount;
  const MonthlyAmount(this.month, this.amount);
}