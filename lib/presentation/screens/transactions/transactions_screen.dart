import 'package:categoriseit_fe/core/theme/app_colors.dart';
import 'package:categoriseit_fe/core/utils/category_utils.dart';
import 'package:categoriseit_fe/core/utils/format_utils.dart';
import 'package:categoriseit_fe/data/providers.dart';
import 'package:categoriseit_fe/domain/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(transactionsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Transactions', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () => context.push('/transactions/add'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v.toLowerCase()),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
                error: (e, _) => Center(child: Text('$e')),
                data: (txns) {
                  final filtered = _query.isEmpty
                    ? txns
                    : txns.where((t) => (t.merchantName ?? '').toLowerCase().contains(_query) || (t.categoryName ?? '').toLowerCase().contains(_query)).toList();
                  final grouped = _groupByDate(filtered);
                  return RefreshIndicator(
                    color: AppColors.emerald,
                    backgroundColor: AppColors.surface,
                    onRefresh: () async {
                      ref.invalidate(transactionsProvider);
                      await ref.read(transactionsProvider.future);
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: grouped.length,
                      itemBuilder: (context, i) {
                        final entry = grouped[i];
                        return _DateGroup(label: entry.key, transactions: entry.value);
                      },
                    )
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<String, List<Transaction>>> _groupByDate(List<Transaction> txns) {
    final map = <String, List<Transaction>>{};
    for (final t in txns) {
      final label = formatGroupDate(t.bookingDate);
      map.putIfAbsent(label, () => []).add(t);
    }
    return map.entries.toList();
  }
}

class _DateGroup extends StatelessWidget {
  final String label;
  final List<Transaction> transactions;
  const _DateGroup({required this.label, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label.toUpperCase(), style: const TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        ...transactions.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _TxnCard(txn: t),
        )),
      ],
    );
  }
}

class _TxnCard extends ConsumerWidget {
  final Transaction txn;
  const _TxnCard({required this.txn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = CategoryUtils.colorFromHex(txn.categoryColor);
    final icon  = CategoryUtils.iconFromName(txn.categoryIcon);
    return GestureDetector(
      onTap: () => _showCategoryPicker(context, ref, txn),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: txn.isManual ? AppColors.surfaceHigh : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(txn.merchantName ?? 'Transaction',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                      if (txn.isManual) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Manual',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(txn.categoryName ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Text(
              txn.isExpense ? '-${formatRonDec(txn.amount)}' : '+${formatRonDec(txn.amount)}',
              style: TextStyle(color: txn.isExpense ? AppColors.red : AppColors.emerald, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, WidgetRef ref, Transaction txn) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _CategoryPickerSheet(txn: txn),
    );
  }
}

class _CategoryPickerSheet extends ConsumerStatefulWidget {
  final Transaction txn;
  const _CategoryPickerSheet({required this.txn});

  @override
  ConsumerState<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<_CategoryPickerSheet> {
  bool _saving = false;

  Future<void> _select(String categoryId) async {
    if (categoryId == widget.txn.categoryId) {
      Navigator.pop(context);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(transactionsMutationProvider.notifier)
          .recategorise(widget.txn.id, categoryId);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category updated'), backgroundColor: AppColors.emerald),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update category'), backgroundColor: AppColors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('Change category',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            if (_saving)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: AppColors.emerald)),
              )
            else
              Flexible(
                child: categoriesAsync.when(
                  loading: () => const Padding(padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: AppColors.emerald))),
                  error: (e, _) => const Padding(padding: EdgeInsets.all(24),
                    child: Text('Failed to load categories', style: TextStyle(color: AppColors.red))),
                  data: (cats) => ListView(
                    shrinkWrap: true,
                    children: cats.map((c) {
                      final color = CategoryUtils.colorFromHex(c.color);
                      final selected = c.id == widget.txn.categoryId;
                      return ListTile(
                        onTap: () => _select(c.id),
                        leading: Icon(CategoryUtils.iconFromName(c.icon), color: color),
                        title: Text(c.name, style: const TextStyle(color: Colors.white)),
                        trailing: selected
                          ? const Icon(Icons.check, color: AppColors.emerald)
                          : null,
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}