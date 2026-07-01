import 'package:categoriseit_fe/core/theme/app_colors.dart';
import 'package:categoriseit_fe/data/providers.dart';
import 'package:categoriseit_fe/domain/models/recommendation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recommendationsProvider);
    final unread = ref.watch(unreadCountProvider);
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
                  const Text('Insights', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('$unread new recommendation${unread == 1 ? '' : 's'}', style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
                error: (e, _) => Center(child: Text('$e')),
                data: (recs) => RefreshIndicator(
                  color: AppColors.emerald,                       // ADDED
                  backgroundColor: AppColors.surface,             // ADDED
                  onRefresh: () async {                           // ADDED: reload recommendations (StateNotifier)
                    await ref.read(recommendationsProvider.notifier).reload();
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),  // ADDED: allow pull-to-refresh even when list is not scrollable
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: recs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final rec = recs[i];
                      return Dismissible(
                        key: Key(rec.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => ref.read(recommendationsProvider.notifier).dismiss(rec.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.delete_outline, color: AppColors.red),
                        ),
                        child: _RecCard(rec: rec, onRead: () => ref.read(recommendationsProvider.notifier).markAsRead(rec.id)),
                      );
                    },
                  ),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecCard extends StatelessWidget {
  final Recommendation rec;
  final VoidCallback onRead;
  const _RecCard({required this.rec, required this.onRead});

  static const _styles = <RecommendationType, (Color, IconData)>{
    RecommendationType.overspend:  (AppColors.red,    Icons.warning_amber_rounded),
    RecommendationType.trendUp:    (AppColors.orange,  Icons.trending_up),
    RecommendationType.trendDown:  (AppColors.emerald, Icons.auto_awesome),
    RecommendationType.savingsTip: (AppColors.red,    Icons.savings),
    RecommendationType.noBudget:   (AppColors.yellow,  Icons.pie_chart_outline),
  };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _styles[rec.type]!;
    final bgColor = rec.isRead
        ? const Color(0xFF111111) 
        : AppColors.surface;

    return GestureDetector(
      onTap: rec.isRead ? null : onRead,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: bgColor,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 5, color: color),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: rec.isRead ? 0.08 : 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, color: color.withValues(alpha: rec.isRead ? 0.5 : 1.0), size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          rec.title,
                                          style: TextStyle(
                                            color: rec.isRead ? AppColors.textSecondary : Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(_timeAgo(rec.createdAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    rec.description,
                                    style: TextStyle(
                                      color: rec.isRead ? AppColors.textMuted : AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (!rec.isRead) ...[
                                    const SizedBox(height: 8),
                                    const Text('Swipe to dismiss', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: rec.isRead
                      ? Border.all(color: AppColors.divider, width: 0.5)
                      : Border.all(color: color, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}