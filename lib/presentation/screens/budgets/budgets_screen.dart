import 'package:categoriseit_fe/core/theme/app_colors.dart';
import 'package:categoriseit_fe/core/utils/category_utils.dart';
import 'package:categoriseit_fe/core/utils/format_utils.dart';
import 'package:categoriseit_fe/data/providers.dart';
import 'package:categoriseit_fe/domain/models/budget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(budgetsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
          error: (e, _) => Center(child: Text('$e')),
          data: (budgets) => _Body(budgets: budgets, ref: ref),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final List<Budget> budgets;
  final WidgetRef ref;
  const _Body({required this.budgets, required this.ref});

  @override
  Widget build(BuildContext context) {
    final totalLimit = budgets.fold(0.0, (s, b) => s + b.monthlyLimit);
    final totalSpent = budgets.fold(0.0, (s, b) => s + b.spent);
    final overallPct = totalLimit > 0 ? totalSpent / totalLimit : 0.0;

    return RefreshIndicator(
      color: AppColors.emerald, 
      backgroundColor: AppColors.surface,  
      onRefresh: () async {               
        await ref.read(budgetsProvider.notifier).reload();
        ref.invalidate(dashboardProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(), 
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Budgets', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(formatMonthYear(DateTime.now()), style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/budgets/add'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _OverviewCard(totalLimit: totalLimit, totalSpent: totalSpent, overallPct: overallPct.clamp(0.0, 1.0)),
          const SizedBox(height: 16),
          ...budgets.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BudgetCard(budget: b),
          )),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final double totalLimit, totalSpent, overallPct;
  const _OverviewCard({required this.totalLimit, required this.totalSpent, required this.overallPct});

  @override
  Widget build(BuildContext context) {
    final remaining = (totalLimit - totalSpent).clamp(0.0, double.infinity);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total budgeted', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text(formatRon(totalLimit), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Spent so far', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text(formatRon(totalSpent), style: const TextStyle(color: AppColors.orange, fontSize: 22, fontWeight: FontWeight.w500)),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: overallPct,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation(
                  overallPct > 0.9 ? AppColors.red : overallPct > 0.7 ? AppColors.yellow : AppColors.emerald,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('${formatRon(remaining)} remaining', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  const _BudgetCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final color = CategoryUtils.colorFromHex(budget.categoryColor);
    final icon  = CategoryUtils.iconFromName(budget.categoryIcon);
    final (statusColor, statusBg) = budget.isOverBudget
      ? (AppColors.red, AppColors.redSubtle)
      : budget.isNearLimit
        ? (AppColors.yellow, AppColors.yellowSubtle)
        : (AppColors.emerald, AppColors.emeraldSubtle);

    return GestureDetector(                                    
      onTap: () => context.push('/budgets/add', extra: budget),  
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(budget.categoryName, style: const TextStyle(color: Colors.white, fontSize: 14))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(budget.statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: budget.percentage,
                minHeight: 6,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation(budget.isOverBudget ? AppColors.red : color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${formatRon(budget.spent)} spent', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text('${formatRon(budget.monthlyLimit)} limit', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),                                                 
    );
  }
}