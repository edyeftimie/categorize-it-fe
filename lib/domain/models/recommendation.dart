enum RecommendationType { overspend, trendUp, trendDown, savingsTip, noBudget }

RecommendationType recommendationTypeFromString(String s) {
  switch (s) {
    case 'OVERSPEND':   return RecommendationType.overspend;
    case 'TREND_UP':    return RecommendationType.trendUp;
    case 'TREND_DOWN':  return RecommendationType.trendDown;
    case 'SAVINGS_TIP': return RecommendationType.savingsTip;
    case 'NO_BUDGET':   return RecommendationType.noBudget;
    default:            return RecommendationType.overspend;
  }
}

class Recommendation {
  final String id;
  final RecommendationType type;
  final String title;
  final String description;
  final String? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final int priority;
  final bool isRead;
  final bool isDismissed;
  final DateTime createdAt;

  const Recommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    required this.priority,
    required this.isRead,
    required this.isDismissed,
    required this.createdAt,
  });

  // Backend convention: 3 = High, 2 = Medium, 1 = Low
  bool get isHigh   => priority == 3;
  bool get isMedium => priority == 2;
  bool get isLow    => priority == 1;

  Recommendation copyWith({bool? isRead, bool? isDismissed}) => Recommendation(
    id: id, type: type, title: title, description: description,
    categoryId: categoryId, categoryName: categoryName, categoryColor: categoryColor,
    priority: priority,
    isRead: isRead ?? this.isRead,
    isDismissed: isDismissed ?? this.isDismissed,
    createdAt: createdAt,
  );

  factory Recommendation.fromJson(Map<String, dynamic> j) => Recommendation(
    id: j['id'] as String,
    type: recommendationTypeFromString(j['type'] as String),
    title: j['title'] as String,
    description: j['description'] as String,
    categoryId: j['categoryId'] as String?,
    categoryName: j['categoryName'] as String?,
    categoryColor: j['categoryColor'] as String?,
    priority: j['priority'] as int,
    isRead: j['isRead'] as bool,
    isDismissed: j['isDismissed'] as bool,
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}