import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/providers.dart';
import '../../../domain/models/dashboard.dart';

String _monthLabel(MonthlyAmount m) {
  const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return names[m.month];
}

class CategoryChartScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  const CategoryChartScreen({super.key, this.categoryId});

  @override
  ConsumerState<CategoryChartScreen> createState() => _State();
}

class _State extends ConsumerState<CategoryChartScreen> {
  bool _isBar = true;
  String? _categoryId;
  late final AsyncValue<List<MonthlyAmount>> _seriesAsync;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final seriesAsync = ref.watch(_seriesProvider(_categoryId ?? 'cat1'));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            Row(
              children: [
                GestureDetector(onTap: () => context.pop(), child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.white, size: 20))),
                const SizedBox(width: 16),
                const Text('Spending Chart', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 16),
            categoriesAsync.whenOrNull(data: (cats) => _CategoryDropdown(
              categories: cats,
              selectedId: _categoryId,
              onChanged: (id) => setState(() => _categoryId = id),
            )) ?? const SizedBox.shrink(),
            const SizedBox(height: 12),
            seriesAsync.when(
              loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppColors.emerald))),
              error: (e, _) => Text('$e'),
              data: (series) => Column(
                children: [
                  _SummaryRow(series: series),
                  const SizedBox(height: 12),
                  _ChartToggle(isBar: _isBar, onToggle: (v) => setState(() => _isBar = v)),
                  const SizedBox(height: 12),
                  _ChartCard(series: series, isBar: _isBar),
                  const SizedBox(height: 12),
                  _StatsRow(series: series),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _seriesProvider = FutureProvider.family<List<MonthlyAmount>, String>((ref, categoryId) =>
  ref.read(dashboardRepositoryProvider).getMonthlySeries(categoryId));

class _CategoryDropdown extends StatelessWidget {
  final List categories;
  final String? selectedId;
  final ValueChanged<String> onChanged;
  const _CategoryDropdown({required this.categories, required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = categories.any((c) => c.id == selectedId)
    ? categories.firstWhere((c) => c.id == selectedId)
    : categories.first;
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: categories.map<Widget>((c) => ListTile(
            title: Text(c.name, style: TextStyle(color: c.id == selectedId ? AppColors.emerald : Colors.white)),
            onTap: () { onChanged(c.id); Navigator.pop(context); },
          )).toList(),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
        child: Row(
          children: [
            Text(selected?.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final List<MonthlyAmount> series;
  const _SummaryRow({required this.series});

  @override
  Widget build(BuildContext context) {
    final current  = series.last.total;
    final previous = series[series.length - 2].total;
    final diff     = current - previous;
    final pct      = previous > 0 ? (diff.abs() / previous * 100).toStringAsFixed(1) : '—';
    final isUp     = diff > 0;
    final avg      = series.fold(0.0, (s, m) => s + m.total) / series.length;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This month', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(formatRon(current), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(isUp ? Icons.trending_up : Icons.trending_down, size: 12, color: isUp ? AppColors.red : AppColors.emerald),
                  const SizedBox(width: 4),
                  Text('${isUp ? '+' : '-'}$pct% vs last', style: TextStyle(color: isUp ? AppColors.red : AppColors.emerald, fontSize: 11)),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('6-month avg', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(formatRon(avg), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('per month', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartToggle extends StatelessWidget {
  final bool isBar;
  final ValueChanged<bool> onToggle;
  const _ChartToggle({required this.isBar, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: Row(
        children: [
          _Tab(label: 'Bar',   active: isBar,  onTap: () => onToggle(true)),
          _Tab(label: 'Trend', active: !isBar, onTap: () => onToggle(false)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: active ? AppColors.emerald : Colors.transparent, borderRadius: BorderRadius.circular(9)),
        child: Center(child: Text(label, style: TextStyle(color: active ? Colors.black : AppColors.textSecondary, fontSize: 14, fontWeight: active ? FontWeight.w600 : FontWeight.normal))),
      ),
    ),
  );
}

class _ChartCard extends StatelessWidget {
  final List<MonthlyAmount> series;
  final bool isBar;
  const _ChartCard({required this.series, required this.isBar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: SizedBox(
        height: 180,
        child: isBar ? _buildBar() : _buildLine(),
      ),
    );
  }

  AxisTitles _bottomTitles() => AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      getTitlesWidget: (v, _) {
        final i = v.toInt();
        if (i < 0 || i >= series.length) return const SizedBox.shrink();
        return Text(_monthLabel(series[i]), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11));
      },
    ),
  );

  AxisTitles _leftTitles() => AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 44,
      getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
    ),
  );

  Widget _buildBar() => BarChart(
    BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, _, rod, __) => BarTooltipItem(
            '${series[group.x].month}\n${rod.toY.toInt()} RON',
            const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: _bottomTitles(),
        leftTitles:   _leftTitles(),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFF2A2A2A), strokeWidth: 1),
      ),
      barGroups: series.asMap().entries.map((e) => BarChartGroupData(
        x: e.key,
        barRods: [BarChartRodData(toY: e.value.total, color: AppColors.emerald, width: 18, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))],
      )).toList(),
    ),
    swapAnimationDuration: const Duration(milliseconds: 250),
  );

  Widget _buildLine() => LineChart(
    LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
            '${series[s.x.toInt()].month}\n${s.y.toInt()} RON',
            const TextStyle(color: Colors.white, fontSize: 12),
          )).toList(),
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: _bottomTitles(),
        leftTitles:   _leftTitles(),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFF2A2A2A), strokeWidth: 1),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: series.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.total)).toList(),
          isCurved: true,
          color: AppColors.emerald,
          barWidth: 2,
          dotData: FlDotData(getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3, color: AppColors.emerald, strokeWidth: 0, strokeColor: Colors.transparent)),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [AppColors.emerald.withValues(alpha: 0.3), AppColors.emerald.withValues(alpha: 0)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    ),
    duration: const Duration(milliseconds: 250),
  );
}

class _StatsRow extends StatelessWidget {
  final List<MonthlyAmount> series;
  const _StatsRow({required this.series});

  @override
  Widget build(BuildContext context) {
    final amounts = series.map((s) => s.total).toList();
    final peak = amounts.reduce((a, b) => a > b ? a : b);
    final low  = amounts.reduce((a, b) => a < b ? a : b);
    final avg  = amounts.fold(0.0, (s, a) => s + a) / amounts.length;
    return Row(
      children: [
        _StatCell(label: 'Peak',    value: peak.toInt().toString(), color: AppColors.red),
        const SizedBox(width: 10),
        _StatCell(label: 'Average', value: avg.toInt().toString(),  color: Colors.white),
        const SizedBox(width: 10),
        _StatCell(label: 'Lowest',  value: low.toInt().toString(),  color: AppColors.emerald),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCell({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
          const Text('RON', style: TextStyle(color: AppColors.divider, fontSize: 10)),
        ],
      ),
    ),
  );
}