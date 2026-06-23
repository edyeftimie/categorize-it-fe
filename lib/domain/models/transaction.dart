enum NeedWantSavings { need, want, savings, uncategorised, excluded }

class Transaction {
  final String id;
  final String? bankAccountId;
  final String? entryReference;
  final double amount;
  final String currency;
  final bool isExpense;
  final DateTime bookingDate;
  final String? merchantName;
  final String? merchantCategoryCode;
  final String? description;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final NeedWantSavings? classification;
  final bool isManual;
  final bool? isRecurring;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    this.bankAccountId,
    this.entryReference,
    required this.amount,
    required this.currency,
    required this.isExpense,
    required this.bookingDate,
    this.merchantName,
    this.merchantCategoryCode,
    this.description,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.classification,
    required this.isManual,
    this.isRecurring,
    required this.createdAt,
  });

  Transaction copyWith({
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    NeedWantSavings? classification,
  }) {
    return Transaction(
      id: id, bankAccountId: bankAccountId,
      entryReference: entryReference, amount: amount, currency: currency,
      isExpense: isExpense, bookingDate: bookingDate, merchantName: merchantName,
      merchantCategoryCode: merchantCategoryCode, description: description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      classification: classification ?? this.classification,
      isManual: isManual, isRecurring: isRecurring, createdAt: createdAt,
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
    id: j['id'],
    bankAccountId: j['bankAccountId'],
    entryReference: j['entryReference'],
    amount: (j['amount'] as num).toDouble(),
    currency: j['currency'],
    isExpense: j['isExpense'],
    bookingDate: DateTime.parse(j['bookingDate']),
    merchantName: j['merchantName'],
    merchantCategoryCode: j['merchantCategoryCode'],
    description: j['description'],
    categoryId: j['categoryId'],
    categoryName: j['categoryName'],
    categoryIcon: j['categoryIcon'],
    categoryColor: j['categoryColor'],
    isManual: j['isManual'],
    isRecurring: j['isRecurring'],
    createdAt: DateTime.parse(j['createdAt']),
  );
}