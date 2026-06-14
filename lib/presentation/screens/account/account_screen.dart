import 'package:categoriseit_fe/domain/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers.dart';
import '../../../domain/models/bank_connection.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _State();
}

class _State extends ConsumerState<AccountScreen> {
  final _expanded = <String>{};

  void _toggle(String id) => setState(() =>
      _expanded.contains(id) ? _expanded.remove(id) : _expanded.add(id));

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);       // ← read from repo
    final connectionsAsync = ref.watch(bankConnectionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            const Text('Account', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            userAsync.when(
              loading: () => const SizedBox(height: 88, child: Center(child: CircularProgressIndicator(color: AppColors.emerald))),
              error: (_, __) => const SizedBox.shrink(),
              data: (user) => _ProfileCard(user: user),     // ← pass user
            ),
            const SizedBox(height: 24),
            Text('CONNECTED BANKS', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            connectionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
              error: (e, _) => Text('$e'),
              data: (conns) => Column(
                children: [
                  ...conns.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ConnectionCard(connection: c, expanded: _expanded.contains(c.id), onToggle: () => _toggle(c.id)),
                  )),
                  _AddBankButton(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('ACCOUNT', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            _OutlineButton(label: 'Log out', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final User? user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final name     = user?.username ?? user?.email ?? 'User';
    final email    = user?.email ?? '';
    final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle),
                child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600))),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,  style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(email, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0, right: 0,
            child: Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 18),
          ),
        ],
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final BankConnection connection;
  final bool expanded;
  final VoidCallback onToggle;
  const _ConnectionCard({required this.connection, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isActive  = connection.isActive;
    final color     = isActive ? AppColors.emerald : AppColors.orange;
    final colorBg   = isActive ? AppColors.emeraldSubtle : AppColors.orangeSubtle;

    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          GestureDetector(
            onTap: isActive ? onToggle : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: colorBg, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.account_balance, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(connection.aspspName, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: colorBg, borderRadius: BorderRadius.circular(20)),
                            child: Text(connection.status, style: TextStyle(color: color, fontSize: 11)),
                          ),
                        ]),
                        const SizedBox(height: 2),
                        Text(
                          isActive
                            ? '${connection.bankAccounts.length} accounts • Expires ${connection.validUntil.month}/${connection.validUntil.year}'
                            : 'Reconnect to sync transactions',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (isActive) Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _ExpandedContent(connection: connection),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          if (!isActive)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(border: Border.all(color: AppColors.emerald), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('Reconnect', style: TextStyle(color: AppColors.emerald, fontSize: 14))),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  final BankConnection connection;
  const _ExpandedContent({required this.connection});

  @override
  Widget build(BuildContext context) {
    final lastSync = connection.bankAccounts.firstOrNull?.lastSyncedAt;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          ...connection.bankAccounts.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.name ?? 'Account', style: const TextStyle(color: Colors.white, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(a.maskedIban, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
          )),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.refresh, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(lastSync != null ? 'Last synced: ${_ago(lastSync)}' : 'Never synced', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ]),
              const Text('Disconnect', style: TextStyle(color: AppColors.red, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  String _ago(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _AddBankButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border, style: BorderStyle.solid, width: 2),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add, color: AppColors.emerald, size: 20),
        SizedBox(width: 8),
        Text('Connect another bank', style: TextStyle(color: AppColors.emerald, fontSize: 14)),
      ],
    ),
  );
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
      child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14))),
    ),
  );
}