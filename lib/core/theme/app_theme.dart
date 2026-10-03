// =============================================================
// Colores y tipografía centralizados de GeoPredIA (SAP BTP Theme)
// =============================================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryDark = Color(0xFF0E3B2E);   // Verde oscuro institucional
  static const Color sidebarDark = Color(0xFF0C2B20);   // Sidebar oscuro
  static const Color background = Color(0xFFF7F3EC);    // Crema de fondo
  static const Color surface = Color(0xFFFFFFFF);       // Cards blancas
  static const Color headerGreen = Color(0xFFE7EFE5);   // Verde salvia suave
  static const Color terrainBrown = Color(0xFFA77A50);  // Tierra cálida

  static const Color riskHigh = Color(0xFFE0623B);      // Naranja/rojo - ALTO
  static const Color riskHighBg = Color(0xFFFFEBEE);    // Fondo suave ALTO
  static const Color riskMedium = Color(0xFFE3A93B);    // Ámbar - MEDIO
  static const Color riskMediumBg = Color(0xFFFFF8E1);  // Fondo suave MEDIO
  static const Color riskLow = Color(0xFF3E8E5A);       // Verde - BAJO
  static const Color riskLowBg = Color(0xFFE8F5E9);     // Fondo suave BAJO
  static const Color riskNoData = Color(0xFF757575);    // Gris - SIN DATOS
  static const Color riskNoDataBg = Color(0xFFEEEEEE);  // Fondo suave SIN DATOS

  static const Color coordinatorBg = Color(0xFFE3F2FD); // Azul suave Joule
  static const Color coordinatorBorder = Color(0xFF90CAF9);

  static const Color textPrimary = Color(0xFF1B1B1B);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color textMuted = Color(0xFF9E9E9E);
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
        backgroundColor: AppColors.headerGreen,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: false,
        shape: Border(
          bottom: BorderSide(color: Color(0xFFD5DFD1), width: 1),
        ),
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