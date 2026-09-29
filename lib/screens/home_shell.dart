import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'ovulation_screen.dart';
import 'protection_screen.dart';
import 'pcos_screen.dart';
import 'endo_screen.dart';
import 'learn_screen.dart';
import 'settings_screen.dart';
import 'ai_checkin_screen.dart';

// The app's main shell after sign-in: a bottom nav bar switching between
// the 8 primary tabs (now includes AI Check-in). Each tab's screen is kept
// alive in an IndexedStack so switching tabs doesn't rebuild/reset their state.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;

  /// Navigate to a specific tab by name or index
  void _navigateToTab(String tabName) {
    final tabMap = {
      'cycle': 0,
      'ovulation': 1,
      'protection': 2,
      'pcos': 3,
      'endo': 4,
      'learn': 5,
      'settings': 6,
      'checkin': 7,
    };

    final newIndex = tabMap[tabName] ?? 0;
    setState(() => _tabIndex = newIndex);
  }

  final List<_NavItem> _navItems = [
    const _NavItem(
      icon: Icons.nightlight_round,
      label: 'Cycle',
      shortLabel: 'Cycle',
    ),
    const _NavItem(
      icon: Icons.egg_outlined,
      label: 'Ovulation',
      shortLabel: 'Ovu',
    ),
    const _NavItem(
      icon: Icons.shield_outlined,
      label: 'Protection',
      shortLabel: 'Prot',
    ),
    const _NavItem(
      icon: Icons.bubble_chart_outlined,
      label: 'PCOS',
      shortLabel: 'PCOS',
    ),
    const _NavItem(
      icon: Icons.local_florist_outlined,
      label: 'Endo',
      shortLabel: 'Endo',
    ),
    const _NavItem(
      icon: Icons.menu_book_outlined,
      label: 'Learn',
      shortLabel: 'Learn',
    ),
    const _NavItem(
      icon: Icons.settings_outlined,
      label: 'Settings',
      shortLabel: 'Set',
    ),
    const _NavItem(
      icon: Icons.favorite_rounded,
      label: 'Check-in',
      shortLabel: 'Chat',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Build tabs here in build() so _navigateToTab is available
    final tabs = [
      HomeScreen(onNavigateToTab: _navigateToTab),
      const OvulationScreen(),
      const ProtectionScreen(),
      const PcosScreen(),
      const EndoScreen(),
      const LearnScreen(),
      const SettingsScreen(),
      AiCheckinScreen(onNavigateToTab: _navigateToTab),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(index: _tabIndex, children: tabs),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final active = _tabIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tabIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 18,
                          color: active
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.shortLabel,
                          style: AppTextStyles.sans(
                            size: 7.5,
                            weight: active ? FontWeight.w600 : FontWeight.w500,
                            color: active
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String shortLabel;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.shortLabel,
  });
}
