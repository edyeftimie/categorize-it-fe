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
    required this.priority,
    required this.isRead,
    required this.isDismissed,
    required this.createdAt,
  });

  bool get isHigh   => priority == 3;
  bool get isMedium => priority == 2;
  bool get isLow    => priority == 1;

  Recommendation copyWith({bool? isRead, bool? isDismissed}) => Recommendation(
    id: id, type: type, title: title, description: description,
    categoryId: categoryId, priority: priority,
    isRead: isRead ?? this.isRead,
    isDismissed: isDismissed ?? this.isDismissed,
    createdAt: createdAt,
  );

  factory Recommendation.fromJson(Map<String, dynamic> j) => Recommendation(
    id: j['id'],
    type: recommendationTypeFromString(j['type']),
    title: j['title'],
    description: j['description'],
    categoryId: j['categoryId'],
    priority: j['priority'],
    isRead: j['isRead'],
    isDismissed: j['isDismissed'],
    createdAt: DateTime.parse(j['createdAt']),
  );
}