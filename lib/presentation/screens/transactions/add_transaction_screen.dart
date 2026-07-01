import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/category_utils.dart';
import '../../../data/providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountCtrl   = TextEditingController();
  final _merchantCtrl = TextEditingController();
  final _descCtrl     = TextEditingController();

  bool _isExpense = true;
  DateTime _date = DateTime.now();
  String? _categoryId;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _merchantCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.emerald,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount.');
      return;
    }
    if (_categoryId == null) {
      setState(() => _error = 'Please select a category.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await ref.read(transactionsMutationProvider.notifier).createTransaction(
        amount: amount,
        currency: 'RON',
        isExpense: _isExpense,
        bookingDate: _date,
        merchantName: _merchantCtrl.text.trim().isEmpty ? null : _merchantCtrl.text.trim(),
        description:  _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        categoryId: _categoryId,
      );
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added'), backgroundColor: AppColors.emerald),
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not add transaction.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Add Transaction', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.redBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],

              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  _ToggleHalf(label: 'Expense', selected: _isExpense, onTap: () => setState(() => _isExpense = true), color: AppColors.red),
                  _ToggleHalf(label: 'Income', selected: !_isExpense, onTap: () => setState(() => _isExpense = false), color: AppColors.emerald),
                ]),
              ),
              const SizedBox(height: 20),

              const _Label('Amount'),
              const SizedBox(height: 6),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: _dec('0.00', suffix: 'RON'),
              ),
              const SizedBox(height: 16),

              const _Label('Category'),
              const SizedBox(height: 6),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(color: AppColors.emerald),
                error: (e, _) => Text('Failed to load categories', style: const TextStyle(color: AppColors.red)),
                data: (cats) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _categoryId,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      hint: const Text('Select category', style: TextStyle(color: AppColors.textMuted)),
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                      items: cats.map((c) {
                        final color = CategoryUtils.colorFromHex(c.color);
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Row(children: [
                            Icon(CategoryUtils.iconFromName(c.icon), color: color, size: 18),
                            const SizedBox(width: 10),
                            Text(c.name, style: const TextStyle(color: Colors.white)),
                          ]),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const _Label('Date'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                        style: const TextStyle(color: Colors.white)),
                    const Icon(Icons.calendar_today, color: AppColors.textMuted, size: 18),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              const _Label('Merchant (optional)'),
              const SizedBox(height: 6),
              TextField(controller: _merchantCtrl, style: const TextStyle(color: Colors.white), decoration: _dec('e.g. Lidl')),
              const SizedBox(height: 16),

              const _Label('Description (optional)'),
              const SizedBox(height: 6),
              TextField(controller: _descCtrl, style: const TextStyle(color: Colors.white), decoration: _dec('Notes')),
              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Add Transaction', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String hint, {String? suffix}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13));
}

class _ToggleHalf extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  const _ToggleHalf({required this.label, required this.selected, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(color: selected ? color : AppColors.textMuted, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}