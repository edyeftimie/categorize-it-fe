import 'package:categoriseit_fe/core/theme/app_colors.dart';
import 'package:categoriseit_fe/core/utils/category_utils.dart';
import 'package:categoriseit_fe/data/providers.dart';
import 'package:categoriseit_fe/domain/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  Category? _selectedCategory;
  final _amountController = TextEditingController();
  String _currency = 'RON';
  bool _saving = false;

  @override
  void dispose() { _amountController.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_selectedCategory == null || _amountController.text.isEmpty) return;
    setState(() => _saving = true);
    await ref.read(budgetsProvider.notifier).create(
      categoryId: _selectedCategory!.id,
      monthlyLimit: double.parse(_amountController.text),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Add Budget', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 32),
              Text('Category', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 8),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(color: AppColors.emerald),
                error: (e, _) => Text('$e'),
                data: (cats) => _CategoryPicker(
                  categories: cats,
                  selected: _selectedCategory,
                  onSelected: (c) => setState(() => _selectedCategory = c),
                ),
              ),
              const SizedBox(height: 20),
              Text('Monthly Limit', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 8),
              _AmountField(controller: _amountController, currency: _currency, onCurrencyChanged: (c) => setState(() => _currency = c)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Budget', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final List<Category> categories;
  final Category? selected;
  final ValueChanged<Category> onSelected;
  const _CategoryPicker({required this.categories, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            if (selected != null) ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: CategoryUtils.colorFromHex(selected!.color).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Icon(CategoryUtils.iconFromName(selected!.icon), color: CategoryUtils.colorFromHex(selected!.color), size: 18),
              ),
              const SizedBox(width: 10),
              Text(selected!.name, style: const TextStyle(color: Colors.white)),
            ] else
              Text('Select a category', style: TextStyle(color: AppColors.textMuted)),
            const Spacer(),
            Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: categories.map((cat) {
          final color = CategoryUtils.colorFromHex(cat.color);
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Icon(CategoryUtils.iconFromName(cat.icon), color: color, size: 18),
            ),
            title: Text(cat.name, style: const TextStyle(color: Colors.white)),
            onTap: () { onSelected(cat); Navigator.pop(context); },
          );
        }).toList(),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String currency;
  final ValueChanged<String> onCurrencyChanged;
  const _AmountField({required this.controller, required this.currency, required this.onCurrencyChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showCurrencySheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                Text(currency, style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 16),
              ]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 24),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 24),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCurrencySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['RON', 'EUR', 'USD'].map((c) => ListTile(
          title: Text(c, style: const TextStyle(color: Colors.white)),
          onTap: () { onCurrencyChanged(c); Navigator.pop(context); },
        )).toList(),
      ),
    );
  }
}