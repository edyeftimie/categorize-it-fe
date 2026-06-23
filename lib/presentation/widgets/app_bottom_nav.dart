import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadCount;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap, this.unreadCount = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(icon: Icons.home_outlined,           label: 'Home',         active: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.format_list_bulleted,    label: 'Transactions', active: currentIndex == 1, onTap: () => onTap(1)),
              _InsightsButton(active: currentIndex == 2, badge: unreadCount,       onTap: () => onTap(2)),
              _NavItem(icon: Icons.pie_chart_outline,       label: 'Budgets',      active: currentIndex == 3, onTap: () => onTap(3)),
              _NavItem(icon: Icons.person_outline,          label: 'Account',      active: currentIndex == 4, onTap: () => onTap(4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.emerald : AppColors.textMuted;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _InsightsButton extends StatelessWidget {
  final bool active;
  final int badge;
  final VoidCallback onTap;

  const _InsightsButton({required this.active, required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -16,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.emerald, AppColors.emeraldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.emerald.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2)],
                ),
                child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
              ),
            ),
            if (badge > 0)
              Positioned(
                top: -24,
                right: 20,
                child: Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                  child: Center(child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}