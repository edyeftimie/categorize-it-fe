import 'package:categoriseit_fe/core/theme/app_colors.dart';
import 'package:categoriseit_fe/core/utils/category_utils.dart';
import 'package:categoriseit_fe/core/utils/format_utils.dart';
import 'package:categoriseit_fe/data/repositories/mock/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cats = MockData.allCategoriesSpending;
    final total = cats.fold(0.0, (s, c) => s + c.amount);
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
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.white, size: 20)),
                      ),
                      const SizedBox(width: 16),
                      const Text('All Categories', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Total spending this month', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(formatRon(total), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w500)),
                  Text('Across ${cats.where((c) => c.amount > 0).length} categories', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: cats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final c = cats[i];
                  final color = CategoryUtils.colorFromHex(c.categoryColor);
                  final icon  = CategoryUtils.iconFromName(c.categoryIcon);
                  return GestureDetector(
                    onTap: () => context.push('/home/category-transactions', extra: c.categoryId),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
                              const SizedBox(width: 12),
                              Expanded(child: Text(c.categoryName, style: const TextStyle(color: Colors.white, fontSize: 14))),
                              Text(formatRon(c.amount), style: const TextStyle(color: Colors.white, fontSize: 14)),
                            ],
                          ),
                          if (c.amount > 0) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(value: c.percentage, minHeight: 5, backgroundColor: AppColors.divider, valueColor: AlwaysStoppedAnimation(color)),
                            ),
                          ],
                        ],
                      ),
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
}