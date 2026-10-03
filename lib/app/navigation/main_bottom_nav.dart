// =============================================================
// app/navigation/main_bottom_nav.dart
// -------------------------------------------------------------
// Barra de navegación inferior con las 5 secciones oficiales:
// Panorama, Multiagentes, IoT Sentinel, Revisión, Asistente Joule.
// Conectada a AppNavController para navegación reactiva entre pestañas.
// =============================================================

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/multiagent_analysis/presentation/screens/multiagent_analysis_screen.dart';
import '../../features/iot_sentinel/presentation/screens/iot_sentinel_screen.dart';
import '../../features/review_approval/presentation/screens/review_inbox_screen.dart';
import '../../features/assistant/presentation/screens/assistant_screen.dart';
import 'app_nav_controller.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _currentIndex = 0;

  static const List<BottomNavigationBarItem> _navigationItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.grid_view_rounded),
      label: 'Panorama',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.hub_outlined),
      label: 'Multiagentes',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.sensors),
      label: 'Monitoreo\nIoT',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.fact_check_outlined),
      label: 'Revisión\nHumana',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.auto_awesome),
      label: 'Asistente\nJoule',
    ),
  ];

  final List<Widget> _screens = const [
    DashboardScreen(), // 0 - Panorama
    MultiagentAnalysisScreen(), // 1 - Multiagentes
    IotSentinelScreen(), // 2 - IoT Sentinel
    ReviewInboxScreen(), // 3 - Revisión Humana HITL
    AssistantScreen(), // 4 - Asistente Joule
  ];

  @override
  void initState() {
    super.initState();
    AppNavController.currentTab.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (mounted && _currentIndex != AppNavController.currentTab.value) {
      setState(() {
        _currentIndex = AppNavController.currentTab.value;
      });
    }
  }

  @override
  void dispose() {
    AppNavController.currentTab.removeListener(_handleTabChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: List.generate(_navigationItems.length, (index) {
                final item = _navigationItems[index];
                final selected = _currentIndex == index;
                final color = selected
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.textSecondary;
                final label = item.label!;

                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label: label.replaceAll('\n', ' '),
                    child: InkWell(
                      onTap: () => AppNavController.goToTab(index),
                      child: SizedBox.expand(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 4,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color: selected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.09)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 24,
                                  child: AnimatedScale(
                                    scale: selected ? 1.08 : 1,
                                    duration: const Duration(milliseconds: 180),
                                    child: IconTheme(
                                      data:
                                          IconThemeData(color: color, size: 21),
                                      child: selected
                                          ? item.activeIcon
                                          : item.icon,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  label,
                                  maxLines: 2,
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 9,
                                    height: 1.1,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
