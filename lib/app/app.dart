// =============================================================
// app/app.dart
// -------------------------------------------------------------
// Widget raíz de la aplicación GeoPreIA.
// Inicializa MaterialApp y arranca directamente en el SplashScreen
// sin requerir credenciales ni login al usuario.
// =============================================================

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

class GeoRiskApp extends StatelessWidget {
  const GeoRiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoPreIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
