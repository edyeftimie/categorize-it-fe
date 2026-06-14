import 'package:categoriseit_fe/core/theme/app_colors.dart';
import 'package:categoriseit_fe/core/utils/category_utils.dart';
import 'package:categoriseit_fe/core/utils/format_utils.dart';
import 'package:categoriseit_fe/data/providers.dart';
import 'package:categoriseit_fe/domain/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                  const Text('Transactions', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v.toLowerCase()),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: grouped.length,
                    itemBuilder: (context, i) {
                      final entry = grouped[i];
                      return _DateGroup(label: entry.key, transactions: entry.value);
                    },
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
        Text(label.toUpperCase(), style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        ...transactions.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _TxnCard(txn: t),
        )),
      ],
    );
  }
}

class _TxnCard extends StatelessWidget {
  final Transaction txn;
  const _TxnCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    final color = CategoryUtils.colorFromHex(txn.categoryColor);
    final icon  = CategoryUtils.iconFromName(txn.categoryIcon);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.merchantName ?? 'Transaction', style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(txn.categoryName ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(
            txn.isExpense ? '-${formatRonDec(txn.amount)}' : '+${formatRonDec(txn.amount)}',
            style: TextStyle(color: txn.isExpense ? AppColors.red : AppColors.emerald, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}