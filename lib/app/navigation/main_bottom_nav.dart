// =============================================================
// app/navigation/main_bottom_nav.dart
// -------------------------------------------------------------
// Widget global que contiene la barra de navegación inferior
// con las 5 secciones vistas en TODOS los mockups:
// Panorama, Multiagentes, IoT Sentinel, Revisión, Integración.
//
// Por qué vive en app/ y no en core/ ni en un feature:
// no es una "herramienta compartida" (como un botón reutilizable),
// es la estructura de navegación raíz de la app completa.
// =============================================================

import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/multiagent_analysis/presentation/screens/multiagent_analysis_screen.dart';
import '../../features/iot_sentinel/presentation/screens/iot_sentinel_screen.dart';
import '../../features/review_approval/presentation/screens/review_inbox_screen.dart';
import '../../features/integration/presentation/screens/integration_screen.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  // Índice de la pestaña actualmente seleccionada.
  int _currentIndex = 0;

  // Una pantalla completa por cada pestaña. El orden aquí debe
  // coincidir EXACTAMENTE con el orden de los BottomNavigationBarItem
  // más abajo, porque ambos se indexan con _currentIndex.
  final List<Widget> _screens = const [
    DashboardScreen(),              // 0 - Panorama
    MultiagentAnalysisScreen(),     // 1 - Multiagentes
    IotSentinelScreen(),            // 2 - IoT Sentinel
    ReviewInboxScreen(),            // 3 - Revisión
    IntegrationScreen(),            // 4 - Integración
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantiene el estado de cada pantalla al cambiar
      // de pestaña (por ejemplo, si el usuario escribió algo en el
      // buscador del dashboard y luego va a otra pestaña, no se pierde).
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // necesario para 5 ítems fijos
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
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
            label: 'IoT Sentinel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Revisión',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hub),
            label: 'Integración',
          ),
        ],
      ),
    );
  }
}
