import '../../../domain/models/bank_connection.dart';
import '../../../domain/models/budget.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/dashboard.dart';
import '../../../domain/models/recommendation.dart';
import '../../../domain/models/transaction.dart';

class MockData {
  MockData._();

  static final categories = [
    const Category(id: 'cat1', name: 'Food & Dining', icon: 'restaurant', color: '#FF6B6B', isSystem: true),
    const Category(id: 'cat2', name: 'Transport', icon: 'directions_car', color: '#4ECDC4', isSystem: true),
    const Category(id: 'cat3', name: 'Housing & Utilities', icon: 'home', color: '#45B7D1', isSystem: true),
    const Category(id: 'cat4', name: 'Shopping', icon: 'shopping_bag', color: '#96CEB4', isSystem: true),
    const Category(id: 'cat5', name: 'Entertainment', icon: 'movie', color: '#A855F7', isSystem: true),
    const Category(id: 'cat6', name: 'Health', icon: 'favorite', color: '#DDA0DD', isSystem: true),
    const Category(id: 'cat7', name: 'Education', icon: 'school', color: '#98D8C8', isSystem: true),
    const Category(id: 'cat8', name: 'Income', icon: 'account_balance', color: '#77DD77', isSystem: true),
    const Category(id: 'cat9', name: 'Subscriptions', icon: 'subscriptions', color: '#AEC6CF', isSystem: true),
    const Category(id: 'cat10', name: 'Other', icon: 'category', color: '#B0B0B0', isSystem: true),
  ];

  static final now = DateTime.now();

  static final transactions = [
    Transaction(id: 't1', amount: 22.50, currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month, now.day), merchantName: 'Starbucks', categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant', categoryColor: '#FF6B6B', classification: NeedWantSavings.want, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 't2', amount: 7.50, currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month, now.day), merchantName: 'CTP Cluj', categoryId: 'cat2', categoryName: 'Transport', categoryIcon: 'directions_car', categoryColor: '#4ECDC4', classification: NeedWantSavings.need, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 't3', amount: 4000.0, currency: 'RON', isExpense: false, bookingDate: DateTime(now.year, now.month, now.day - 1), merchantName: 'Salary', categoryId: 'cat8', categoryName: 'Income', categoryIcon: 'account_balance', categoryColor: '#77DD77', classification: NeedWantSavings.savings, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 't4', amount: 79.95, currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month, now.day - 1), merchantName: 'Netflix', categoryId: 'cat9', categoryName: 'Subscriptions', categoryIcon: 'subscriptions', categoryColor: '#AEC6CF', classification: NeedWantSavings.want, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 't5', amount: 436.50, currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month, now.day - 1), merchantName: 'Kaufland', categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant', categoryColor: '#FF6B6B', classification: NeedWantSavings.need, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 't6', amount: 45.0, currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month, now.day - 2), merchantName: "McDonald's", categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant', categoryColor: '#FF6B6B', classification: NeedWantSavings.want, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 't7', amount: 234.20, currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month, now.day - 4), merchantName: 'Lidl', categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant', categoryColor: '#FF6B6B', classification: NeedWantSavings.need, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 't8', amount: 89.0, currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month, now.day - 4), merchantName: 'Pizza Hut', categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant', categoryColor: '#FF6B6B', classification: NeedWantSavings.want, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 't9', amount: 327.0, currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month, now.day - 6), merchantName: 'Auchan', categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant', categoryColor: '#FF6B6B', classification: NeedWantSavings.need, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 't10', amount: 780.0, currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month, now.day - 3), merchantName: 'CTP Abonament', categoryId: 'cat2', categoryName: 'Transport', categoryIcon: 'directions_car', categoryColor: '#4ECDC4', classification: NeedWantSavings.need, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 't11', amount: 946.0, currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month, now.day - 5), merchantName: 'Cinema City', categoryId: 'cat5', categoryName: 'Entertainment', categoryIcon: 'movie', categoryColor: '#A855F7', classification: NeedWantSavings.want, isManual: false, createdAt: DateTime.now()),
  ];

  static final previousMonthTransactions = [
    Transaction(id: 'pt1', amount: 289.50, currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month - 1, 28), merchantName: 'Carrefour',   categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant',     categoryColor: '#FF6B6B', classification: NeedWantSavings.need, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 'pt2', amount: 24.00,  currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month - 1, 25), merchantName: 'Starbucks',   categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant',     categoryColor: '#FF6B6B', classification: NeedWantSavings.want, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 'pt3', amount: 38.50,  currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month - 1, 22), merchantName: 'Subway',      categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant',     categoryColor: '#FF6B6B', classification: NeedWantSavings.want, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 'pt4', amount: 52.00,  currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month - 1, 20), merchantName: 'Burger King', categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant',     categoryColor: '#FF6B6B', classification: NeedWantSavings.want, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 'pt5', amount: 156.30, currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month - 1, 18), merchantName: 'Mega Image',  categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant',     categoryColor: '#FF6B6B', classification: NeedWantSavings.need, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 'pt6', amount: 21.50,  currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month - 1, 15), merchantName: 'Starbucks',   categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant',     categoryColor: '#FF6B6B', classification: NeedWantSavings.want, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 'pt7', amount: 185.0,  currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month - 1, 10), merchantName: 'CTP Abonament', categoryId: 'cat2', categoryName: 'Transport',     categoryIcon: 'directions_car', categoryColor: '#4ECDC4', classification: NeedWantSavings.need, isManual: false, createdAt: DateTime.now()),
    Transaction(id: 'pt8', amount: 420.0,  currency: 'RON', isExpense: true, bookingDate: DateTime(now.year, now.month - 1, 5),  merchantName: 'Cinema City', categoryId: 'cat5', categoryName: 'Entertainment', categoryIcon: 'movie',          categoryColor: '#A855F7', classification: NeedWantSavings.want, isManual: false, createdAt: DateTime.now()),
  ];

  static final budgets = [
    const Budget(id: 'b1', categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant', categoryColor: '#FF6B6B', monthlyLimit: 1500, spent: 1840, currency: 'RON'),
    const Budget(id: 'b2', categoryId: 'cat2', categoryName: 'Transport', categoryIcon: 'directions_car', categoryColor: '#4ECDC4', monthlyLimit: 1500, spent: 780, currency: 'RON'),
    const Budget(id: 'b3', categoryId: 'cat5', categoryName: 'Entertainment', categoryIcon: 'movie', categoryColor: '#A855F7', monthlyLimit: 1000, spent: 946, currency: 'RON'),
  ];

  static final recommendations = [
    Recommendation(id: 'r1', type: RecommendationType.overspend, title: 'Budget exceeded', description: 'Food & Dining is 23% over your 1,500 RON monthly limit.', categoryId: 'cat1', priority: 1, isRead: false, isDismissed: false, createdAt: DateTime.now().subtract(const Duration(hours: 4))),
    Recommendation(id: 'r2', type: RecommendationType.trendUp, title: 'Subscription detected', description: 'Netflix charges 79.95 RON monthly. Track it?', categoryId: 'cat9', priority: 2, isRead: false, isDismissed: false, createdAt: DateTime.now().subtract(const Duration(days: 1))),
    Recommendation(id: 'r3', type: RecommendationType.trendDown, title: 'Savings opportunity', description: 'Transport spending dropped 18% this month. Great job!', categoryId: 'cat2', priority: 3, isRead: false, isDismissed: false, createdAt: DateTime.now().subtract(const Duration(days: 3))),
    Recommendation(id: 'r4', type: RecommendationType.trendUp, title: 'Spending trend', description: 'Entertainment up 45% vs last month.', categoryId: 'cat5', priority: 2, isRead: true, isDismissed: false, createdAt: DateTime.now().subtract(const Duration(days: 5))),
  ];

  static final bankConnections = [
    BankConnection(id: 'bc1', aspspName: 'Banca Transilvania', aspspCountry: 'RO', validUntil: DateTime(2026, 12, 31), status: 'Active', createdAt: DateTime(2026, 1, 1), bankAccounts: [
    BankAccount(id: 'ba1', uid: 'uid1', iban: 'RO49BTRL00001234524521', name: 'Current Account', currency: 'RON', lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 2))),
    BankAccount(id: 'ba2', uid: 'uid2', iban: 'RO49BTRL00001234528832', name: 'Savings', currency: 'RON', lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 2))),]),
    BankConnection(id: 'bc2', aspspName: 'ING Bank', aspspCountry: 'RO', validUntil: DateTime(2025, 12, 31), status: 'Expired', createdAt: DateTime(2025, 1, 1), bankAccounts: []),
  ];

  static final dashboard = DashboardData(
    totalBalance: 1030,
    totalIncome: 4000,
    totalExpenses: 2970,
    month: DateTime.now(),
    needWantSplit: const NeedWantSplit(need: 1780, want: 1190, savings: 0),
    categoryBreakdown: [
      const CategorySpending(categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant', categoryColor: '#FF6B6B', amount: 1140, budgetLimit: 1500, percentage: 0.73),
      const CategorySpending(categoryId: 'cat3', categoryName: 'Rent', categoryIcon: 'home', categoryColor: '#45B7D1', amount: 1000, budgetLimit: 1500, percentage: 0.52),
      const CategorySpending(categoryId: 'cat2', categoryName: 'Transport', categoryIcon: 'directions_car', categoryColor: '#4ECDC4', amount: 380, budgetLimit: 1500, percentage: 0.52),
      const CategorySpending(categoryId: 'cat5', categoryName: 'Entertainment', categoryIcon: 'movie', categoryColor: '#A855F7', amount: 450, budgetLimit: 1000, percentage: 0.42),
    ],
  );

  static final allCategoriesSpending = [
    const CategorySpending(categoryId: 'cat1', categoryName: 'Food & Dining', categoryIcon: 'restaurant', categoryColor: '#FF6B6B', amount: 1140, percentage: 0.76),
    const CategorySpending(categoryId: 'cat3', categoryName: 'Rent', categoryIcon: 'home', categoryColor: '#45B7D1', amount: 1000, percentage: 0.67),
    const CategorySpending(categoryId: 'cat5', categoryName: 'Entertainment', categoryIcon: 'movie', categoryColor: '#A855F7', amount: 450, percentage: 0.30),
    const CategorySpending(categoryId: 'cat2', categoryName: 'Transport', categoryIcon: 'directions_car', categoryColor: '#4ECDC4', amount: 380, percentage: 0.25),
    const CategorySpending(categoryId: 'cat4', categoryName: 'Shopping', categoryIcon: 'shopping_bag', categoryColor: '#96CEB4', amount: 320, percentage: 0.21),
    const CategorySpending(categoryId: 'cat3', categoryName: 'Housing & Utilities', categoryIcon: 'wifi', categoryColor: '#45B7D1', amount: 280, percentage: 0.19),
    const CategorySpending(categoryId: 'cat6', categoryName: 'Health', categoryIcon: 'favorite', categoryColor: '#DDA0DD', amount: 150, percentage: 0.10),
    const CategorySpending(categoryId: 'cat7', categoryName: 'Travel', categoryIcon: 'flight', categoryColor: '#6366F1', amount: 0, percentage: 0.00),
  ];

  static final monthlySeries = <String, List<MonthlyAmount>>{
    'cat1': [
      const MonthlyAmount(month: 12, year: 2023, total: 620), 
      const MonthlyAmount(month: 1, year: 2024, total: 780), 
      const MonthlyAmount(month: 2, year: 2024, total: 550), 
      const MonthlyAmount(month: 3, year: 2024, total: 890), 
      const MonthlyAmount(month: 4, year: 2024, total: 582), 
      const MonthlyAmount(month: 5, year: 2024, total: 1240)
    ],
    'cat2': [
      const MonthlyAmount(month: 12, year: 2023, total: 210), 
      const MonthlyAmount(month: 1, year: 2024, total: 185), 
      const MonthlyAmount(month: 2, year: 2024, total: 230), 
      const MonthlyAmount(month: 3, year: 2024, total: 195), 
      const MonthlyAmount(month: 4, year: 2024, total: 220), 
      const MonthlyAmount(month: 5, year: 2024, total: 175)
    ],
    'cat5': [
      const MonthlyAmount(month: 12, year: 2023, total: 350), 
      const MonthlyAmount(month: 1, year: 2024, total: 420), 
      const MonthlyAmount(month: 2, year: 2024, total: 280), 
      const MonthlyAmount(month: 3, year: 2024, total: 310), 
      const MonthlyAmount(month: 4, year: 2024, total: 390), 
      const MonthlyAmount(month: 5, year: 2024, total: 260)
    ],
    'cat4': [
      const MonthlyAmount(month: 12, year: 2023, total: 1200), 
      const MonthlyAmount(month: 1, year: 2024, total: 640), 
      const MonthlyAmount(month: 2, year: 2024, total: 480), 
      const MonthlyAmount(month: 3, year: 2024, total: 720), 
      const MonthlyAmount(month: 4, year: 2024, total: 560), 
      const MonthlyAmount(month: 5, year: 2024, total: 830)
    ]
  };
}