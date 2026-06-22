class Budget {
  final String id;
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final double monthlyLimit;
  final double spent;
  final String currency;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.monthlyLimit,
    required this.spent,
    required this.currency,
  });

  double get percentage   => monthlyLimit > 0 ? (spent / monthlyLimit).clamp(0.0, 1.0) : 0;
  bool   get isOverBudget => spent > monthlyLimit;
  bool   get isNearLimit  => !isOverBudget && percentage >= 0.85;

  String get statusLabel {
    if (isOverBudget) return 'Over budget';
    if (isNearLimit)  return 'Almost there';
    return 'On track';
  }

  Budget copyWith({double? spent, double? monthlyLimit}) => Budget(
    id: id, categoryId: categoryId, categoryName: categoryName,
    categoryIcon: categoryIcon, categoryColor: categoryColor,
    monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    spent: spent ?? this.spent,
    currency: currency,
  );

  factory Budget.fromJson(Map<String, dynamic> j) => Budget(
    id:            j['id']           as String,
    categoryId:    j['categoryId']   as String,
    categoryName:  j['categoryName'] as String,
    categoryIcon:  j['categoryIcon'] as String?,
    categoryColor: j['categoryColor'] as String?,
    monthlyLimit:  (j['monthlyLimit'] as num).toDouble(),
    spent:         (j['amountSpent']  as num?)?.toDouble() ?? 0,  // API field is amountSpent
    currency:      j['currency'] as String,
  );
}