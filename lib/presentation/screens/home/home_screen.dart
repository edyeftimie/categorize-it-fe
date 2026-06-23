import 'package:categoriseit_fe/core/theme/app_colors.dart';
import 'package:categoriseit_fe/core/utils/category_utils.dart';
import 'package:categoriseit_fe/core/utils/format_utils.dart';
import 'package:categoriseit_fe/data/providers.dart';
import 'package:categoriseit_fe/domain/models/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
        error: (e, _) => Center(child: Text('$e')),
        data: (d) => _Body(data: d),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final DashboardData data;
  const _Body({required this.data});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          const SizedBox(height: 8),
          const Text('Good morning,', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('Eduard 👋', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          _BalanceCard(data: data),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Spending this month', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              GestureDetector(
                onTap: () => context.push('/home/all-categories'),
                child: const Text('See more', style: TextStyle(color: AppColors.emerald, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...data.categoryBreakdown.take(4).map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CategoryCard(spending: c),
          )),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final DashboardData data;
  const _BalanceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.emerald, AppColors.emeraldDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total balance', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
          const SizedBox(height: 4),
          Text(formatRon(data.totalBalance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(children: [
            _MiniStat(label: 'Income',   value: formatRon(data.totalIncome)),
            const SizedBox(width: 12),
            _MiniStat(label: 'Expenses', value: formatRon(data.totalExpenses)),
          ]),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategorySpending spending;
  const _CategoryCard({required this.spending});

  @override
  Widget build(BuildContext context) {
    final color = CategoryUtils.colorFromHex(spending.categoryColor);
    final icon  = CategoryUtils.iconFromName(spending.categoryIcon);
    return GestureDetector(
      onTap: () => context.push('/home/category-transactions', extra: spending.categoryId),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(spending.categoryName, style: const TextStyle(color: Colors.white, fontSize: 14))),
              Text(formatRon(spending.amount), style: const TextStyle(color: Colors.white, fontSize: 14)),
            ]),
            const SizedBox(height: 12),
            _ProgressBar(value: spending.percentage, color: color),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: AppColors.divider,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}