import 'package:categoriseit_fe/core/network/api_exception.dart';
import 'package:categoriseit_fe/core/theme/app_colors.dart';
import 'package:categoriseit_fe/core/utils/category_utils.dart';
import 'package:categoriseit_fe/data/providers.dart';
import 'package:categoriseit_fe/domain/models/budget.dart';
import 'package:categoriseit_fe/domain/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetForm extends ConsumerStatefulWidget {
  final Budget? existingBudget;
  final VoidCallback? onCompleted;

  const BudgetForm({super.key, this.existingBudget, this.onCompleted});

  @override
  ConsumerState<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends ConsumerState<BudgetForm> {
  Category? _selectedCategory;
  final _amountController = TextEditingController();
  String _currency = 'RON';
  bool _saving = false;
  String? _error;

  bool get _isEditMode => widget.existingBudget != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _amountController.text = widget.existingBudget!.monthlyLimit.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    if (!_isEditMode && _selectedCategory == null) return;

    setState(() { _saving = true; _error = null; });
    try {
      final notifier = ref.read(budgetsProvider.notifier);

      if (_isEditMode) {
        await notifier.update(widget.existingBudget!.id, monthlyLimit: amount);
      } else {
        final list = ref.read(budgetsProvider).valueOrNull ?? [];
        final existing = list.where((b) => b.categoryId == _selectedCategory!.id);
        if (existing.isNotEmpty) {
          await notifier.update(existing.first.id, monthlyLimit: amount);
        } else {
          await notifier.create(categoryId: _selectedCategory!.id, monthlyLimit: amount);
        }
      }

      if (mounted) widget.onCompleted?.call();
    } on ApiException catch (e) {
      if (mounted) setState(() { _saving = false; _error = e.message; });
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = '$e'; });
    }
  }

  Future<void> _delete() async {
    final budget = widget.existingBudget!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete budget', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete budget for ${budget.categoryName}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() { _saving = true; _error = null; });
    try {
      await ref.read(budgetsProvider.notifier).delete(budget.id);
      if (mounted) widget.onCompleted?.call();
    } on ApiException catch (e) {
      if (mounted) setState(() { _saving = false; _error = e.message; });
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = '$e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        if (_isEditMode)
          _LockedCategory(budget: widget.existingBudget!)
        else
          categoriesAsync.when(
            loading: () => const LinearProgressIndicator(color: AppColors.emerald),
            error: (e, _) => Text('$e', style: const TextStyle(color: AppColors.red, fontSize: 13)),
            data: (cats) => _CategoryPicker(
              categories: cats,
              selected: _selectedCategory,
              onSelected: (c) => setState(() => _selectedCategory = c),
            ),
          ),
        const SizedBox(height: 20),
        const Text('Monthly limit', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        _AmountField(
          controller: _amountController,
          currency: _currency,
          onCurrencyChanged: (c) => setState(() => _currency = c),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
        ],
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
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isEditMode ? 'Update budget' : 'Save budget', style: const TextStyle(fontSize: 16)),
          ),
        ),
        if (_isEditMode) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _saving ? null : _delete,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Delete budget', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ],
    );
  }
}

class _LockedCategory extends StatelessWidget {
  final Budget budget;
  const _LockedCategory({required this.budget});

  @override
  Widget build(BuildContext context) {
    final color = CategoryUtils.colorFromHex(budget.categoryColor);
    final icon  = CategoryUtils.iconFromName(budget.categoryIcon);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Text(budget.categoryName, style: const TextStyle(color: Colors.white)),
          const Spacer(),
          const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 16),
        ],
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
                decoration: BoxDecoration(
                  color: CategoryUtils.colorFromHex(selected!.color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(CategoryUtils.iconFromName(selected!.icon), color: CategoryUtils.colorFromHex(selected!.color), size: 18),
              ),
              const SizedBox(width: 10),
              Text(selected!.name, style: const TextStyle(color: Colors.white)),
            ] else
              const Text('Select a category', style: TextStyle(color: AppColors.textMuted)),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
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
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
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
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 16),
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