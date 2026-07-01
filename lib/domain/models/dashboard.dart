class CategorySpending {
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final double amount;
  final double? budgetLimit;
  final double percentage;

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.amount,
    this.budgetLimit,
    required this.percentage,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> j) => CategorySpending(
    categoryId: j['categoryId'] as String,
    categoryName: j['categoryName'] as String,
    categoryIcon: j['categoryIcon'] as String?,
    categoryColor: j['categoryColor'] as String?,
    amount: (j['amount'] as num).toDouble(),
    budgetLimit: (j['budgetLimit'] as num?)?.toDouble(),
    percentage: (j['percentage'] as num).toDouble(),
  );
}

class NeedWantSplit {
  final double need;
  final double want;
  final double savings;

  const NeedWantSplit({required this.need, required this.want, required this.savings});

  double get total      => need + want + savings;
  double get needPct    => total > 0 ? need / total    : 0;
  double get wantPct    => total > 0 ? want / total    : 0;
  double get savingsPct => total > 0 ? savings / total : 0;

  factory NeedWantSplit.fromJson(Map<String, dynamic> j) => NeedWantSplit(
    need:    (j['needAmount']    as num).toDouble(),
    want:    (j['wantAmount']    as num).toDouble(),
    savings: (j['savingsAmount'] as num).toDouble(),
  );
}

class DashboardData {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final List<CategorySpending> categoryBreakdown;
  final NeedWantSplit needWantSplit;
  final DateTime? month;

  const DashboardData({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.categoryBreakdown,
    required this.needWantSplit,
    this.month,
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
    totalBalance:  (j['totalBalance']  as num).toDouble(),
    totalIncome:   (j['totalIncome']   as num).toDouble(),
    totalExpenses: (j['totalExpenses'] as num).toDouble(),
    categoryBreakdown: (j['topCategories'] as List? ?? [])
        .map((e) => CategorySpending.fromJson(e as Map<String, dynamic>))
        .toList(),
    needWantSplit: NeedWantSplit.fromJson(
        j['needWantSplit'] as Map<String, dynamic>),
  );
}

class MonthlyAmount {
  final int month;
  final int year;
  final double total;

  const MonthlyAmount({required this.month, required this.year, required this.total});

  factory MonthlyAmount.fromJson(Map<String, dynamic> j) => MonthlyAmount(
    month: j['month'] as int,
    year:  j['year']  as int,
    total: (j['total'] as num).toDouble(),
  );
}