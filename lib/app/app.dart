// =============================================================
// app/app.dart
// -------------------------------------------------------------
// Widget raíz de la aplicación. Define el MaterialApp, el tema
// visual global y cuál es la pantalla inicial (la navegación
// principal con las 5 pestañas).
// =============================================================

import 'package:flutter/material.dart';

import 'navigation/main_bottom_nav.dart';
import '../core/theme/app_theme.dart';

class GeoRiskApp extends StatelessWidget {
  const GeoRiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoRisk',
      debugShowCheckedModeBanner: false,

      // El tema visual (colores, tipografía) vive en core/theme,
      // NO aquí, para que cualquier pantalla pueda reutilizarlo
      // sin depender de este archivo.
      theme: AppTheme.light,

      // La app arranca directamente en la navegación de 5 pestañas
      // (Panorama, Multiagentes, IoT Sentinel, Revisión, Integración).
      // Si más adelante agregas login, aquí se pondría un
      // AuthGate/SplashScreen en su lugar.
      home: const MainBottomNav(),
    );
  }
}
