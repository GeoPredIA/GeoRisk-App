// =============================================================
// app/app.dart
// -------------------------------------------------------------
// Widget raíz de la aplicación GeoPredIA.
// =============================================================

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

class GeoPredIAApp extends StatelessWidget {
  const GeoPredIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoPredIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
