import 'package:categoriseit_fe/core/theme/app_colors.dart';
import 'package:categoriseit_fe/core/utils/category_utils.dart';
import 'package:categoriseit_fe/core/utils/format_utils.dart';
import 'package:categoriseit_fe/data/providers.dart';
import 'package:categoriseit_fe/domain/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoryTransactionsScreen extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  const CategoryTransactionsScreen({super.key, this.initialCategoryId});

  @override
  ConsumerState<CategoryTransactionsScreen> createState() => _State();
}

class _State extends ConsumerState<CategoryTransactionsScreen> {
  String? _categoryId;
  bool _showAllCurrent  = false;
  bool _showAllPrevious = false;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync    = ref.watch(categoriesProvider);
    final previousAsync      = ref.watch(previousMonthTransactionsProvider);
    final transactionsAsync  = ref.watch(currentMonthTransactionsProvider);
    final now                = DateTime.now();
    final prevMonthName      = _monthName(now.month == 1 ? 12 : now.month - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Transactions', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 16),
                  categoriesAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error:   (_, __) => const SizedBox.shrink(),
                    data: (cats) => _CategoryDropdown(
                      categories: cats.where((c) => c.id != 'cat8').toList(),
                      selectedId: _categoryId,
                      onChanged: (id) => setState(() {
                        _categoryId       = id;
                        _showAllCurrent   = false;
                        _showAllPrevious  = false;
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
                error:   (e, _) => Center(child: Text('$e')),
                data: (allTxns) {
                  final current  = _filterByCategory(allTxns);
                  final previous = _filterByCategory(previousAsync.valueOrNull ?? []);
                  final currentTotal  = current.where((t) => t.isExpense).fold(0.0,  (s, t) => s + t.amount);
                  final previousTotal = previous.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);

                  return RefreshIndicator(
                    color: AppColors.emerald,            
                    backgroundColor: AppColors.surface,   
                    onRefresh: () async {                   
                      ref.invalidate(currentMonthTransactionsProvider);
                      ref.invalidate(previousMonthTransactionsProvider);
                      ref.invalidate(categoriesProvider);
                      await ref.read(currentMonthTransactionsProvider.future);
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      children: [
                        _TotalBanner(
                          total: currentTotal,
                          previousTotal: previousTotal,
                          onChart: () => context.push('/home/category-chart', extra: _categoryId),
                        ),
                        const SizedBox(height: 12),

                        _TxnBox(
                          title:      'This month',
                          subtitle:   '${current.length} transactions',
                          total:      currentTotal,
                          showTotal:  false,
                          transactions: current,
                          showAll:    _showAllCurrent,
                          onToggle:   () => setState(() => _showAllCurrent = !_showAllCurrent),
                        ),
                        const SizedBox(height: 12),

                        _TxnBox(
                          title:      'Previous month',
                          subtitle:   '$prevMonthName • ${previous.length} transactions',
                          total:      previousTotal,
                          showTotal:  true,
                          transactions: previous,
                          showAll:    _showAllPrevious,
                          onToggle:   () => setState(() => _showAllPrevious = !_showAllPrevious),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Transaction> _filterByCategory(List<Transaction> txns) {
    final filtered = _categoryId == null
        ? txns.where((t) => t.isExpense).toList()
        : txns.where((t) => t.categoryId == _categoryId).toList();
    filtered.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    return filtered;
  }

  String _monthName(int month) {
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month.clamp(1, 12)];
  }
}

class _CategoryDropdown extends StatelessWidget {
  final List categories;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  const _CategoryDropdown({required this.categories, required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = categories.any((c) => c.id == selectedId)
        ? categories.firstWhere((c) => c.id == selectedId)
        : null;
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            ListTile(
              title: const Text('All expenses', style: TextStyle(color: Colors.white)),
              onTap: () { onChanged(null); Navigator.pop(context); },
            ),
            ...categories.map((c) => ListTile(
              leading: Icon(CategoryUtils.iconFromName(c.icon), color: CategoryUtils.colorFromHex(c.color), size: 20),
              title: Text(c.name, style: const TextStyle(color: Colors.white)),
              onTap: () { onChanged(c.id); Navigator.pop(context); },
            )),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
        child: Row(children: [
          Text(selected?.name ?? 'All expenses', style: const TextStyle(color: Colors.white, fontSize: 14)),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 18),
        ]),
      ),
    );
  }
}

class _TotalBanner extends StatelessWidget {
  final double total, previousTotal;
  final VoidCallback onChart;
  const _TotalBanner({required this.total, required this.previousTotal, required this.onChart});

  @override
  Widget build(BuildContext context) {
    final diff   = total - previousTotal;
    final pct    = previousTotal > 0 ? (diff.abs() / previousTotal * 100).toStringAsFixed(1) : null;
    final isUp   = diff > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total spent this month', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(formatRon(total), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                if (pct != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(isUp ? Icons.trending_up : Icons.trending_down, size: 12, color: isUp ? AppColors.red : AppColors.emerald),
                    const SizedBox(width: 4),
                    Text('${isUp ? '+' : '-'}$pct% vs last month', style: TextStyle(color: isUp ? AppColors.red : AppColors.emerald, fontSize: 11)),
                  ]),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onChart,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.emeraldSubtle, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.bar_chart, color: AppColors.emerald, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _TxnBox extends StatelessWidget {
  final String title, subtitle;
  final double total;
  final bool showTotal;
  final List<Transaction> transactions;
  final bool showAll;
  final VoidCallback onToggle;

  const _TxnBox({
    required this.title,
    required this.subtitle,
    required this.total,
    required this.showTotal,
    required this.transactions,
    required this.showAll,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final visible = showAll ? transactions : transactions.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
              if (showTotal)
                Text(formatRon(total), style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No transactions', style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
            )
          else ...[
            const SizedBox(height: 12),
            ...visible.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TxnRow(txn: t),
            )),
            const SizedBox(height: 4),
            if (transactions.length > 3)
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: showAll ? AppColors.surfaceHigh : AppColors.emeraldSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      showAll ? 'Collapse' : 'See more',
                      style: TextStyle(color: showAll ? AppColors.textSecondary : AppColors.emerald, fontSize: 13),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  final Transaction txn;
  const _TxnRow({required this.txn});

  @override
  Widget build(BuildContext context) {
    final color = CategoryUtils.colorFromHex(txn.categoryColor);
    final icon  = CategoryUtils.iconFromName(txn.categoryIcon);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(txn.merchantName ?? 'Transaction', style: const TextStyle(color: Colors.white, fontSize: 13)),
              Text(formatShortDate(txn.bookingDate),  style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ),
        Text(
          txn.isExpense ? '-${formatRonDec(txn.amount)}' : '+${formatRonDec(txn.amount)}',
          style: TextStyle(color: txn.isExpense ? AppColors.red : AppColors.emerald, fontSize: 13),
        ),
      ],
    );
  }
}