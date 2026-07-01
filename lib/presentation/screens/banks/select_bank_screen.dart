import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers.dart';
import '../../../domain/models/bank.dart';

class SelectBankScreen extends ConsumerStatefulWidget {
  const SelectBankScreen({super.key});

  @override
  ConsumerState<SelectBankScreen> createState() => _SelectBankScreenState();
}

class _SelectBankScreenState extends ConsumerState<SelectBankScreen> {
  String? _loadingBank;

  Future<void> _select(Bank bank) async {
    setState(() => _loadingBank = bank.name);
    try {
      final result = await ref.read(bankConnectionRepositoryProvider).initiateAuth(
        aspspName: bank.name,
        aspspCountry: bank.country,
      );
      final uri = Uri.parse(result.url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open browser'), backgroundColor: AppColors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start connection: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingBank = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = ref.watch(availableBanksProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Select Bank', style: TextStyle(fontSize: 16)),
        elevation: 0,
      ),
      body: banksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: Colors.white)),
        ),
        data: (banks) => banks.isEmpty
            ? const Center(child: Text('No banks available', style: TextStyle(color: Colors.white)))
            : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: banks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final bank = banks[i];
                  final isLoading = _loadingBank == bank.name;
                  return GestureDetector(
                    onTap: _loadingBank != null ? null : () => _select(bank),
                    child: Opacity(
                      opacity: _loadingBank != null && !isLoading ? 0.5 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.emeraldSubtle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: bank.logo != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        bank.logo!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.account_balance,
                                          color: AppColors.emerald, size: 22,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.account_balance, color: AppColors.emerald, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(bank.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                  Text(bank.country, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                ],
                              ),
                            ),
                            if (isLoading)
                              const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emerald),
                              )
                            else
                              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}