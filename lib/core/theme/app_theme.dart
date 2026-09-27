// =============================================================
// core/theme/app_theme.dart
// -------------------------------------------------------------
// Colores y tipografía centralizados, tomados de tus mockups:
// - Verde oscuro institucional (headers, botones principales)
// - Naranja/rojo para riesgo ALTO
// - Amarillo/ámbar para riesgo MEDIO
// - Verde para riesgo BAJO
// - Fondo crema/beige claro
//
// Cualquier pantalla debe usar estos colores en vez de escribir
// valores hexadecimales sueltos, así mantienes consistencia visual.
// =============================================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Evita que se instancie esta clase

  static const Color primaryDark = Color(0xFF0E3B2E);   // Verde oscuro (headers, botones)
  static const Color background = Color(0xFFF7F3EC);     // Crema de fondo
  static const Color surface = Color(0xFFFFFFFF);        // Cards blancas

  static const Color riskHigh = Color(0xFFE0623B);       // Naranja/rojo - ALTO
  static const Color riskMedium = Color(0xFFE3A93B);     // Ámbar - MEDIO
  static const Color riskLow = Color(0xFF3E8E5A);        // Verde - BAJO

  static const Color textPrimary = Color(0xFF1B1B1B);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color borderSubtle = Color(0xFFE4DFD3);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDark,
        primary: AppColors.primaryDark,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
