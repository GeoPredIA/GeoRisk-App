// =============================================================
// Convierte un puntaje numérico (0-100) en su nivel de riesgo
// (ALTO / MEDIO / BAJO) y el color correspondiente, según los
// umbrales vistos en tus mockups:
//   - ALTO:  70-100  (naranja/rojo)
//   - MEDIO: 40-69   (ámbar)
//   - BAJO:  0-39    (verde)
//
// Se usa en risk_badge.dart, zone_list_card.dart, y en cualquier
// otro widget que necesite mostrar un score con su color/etiqueta.
// =============================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum RiskLevel { high, medium, low }

class RiskLevelFormatter {
  RiskLevelFormatter._();

  /// Determina el nivel de riesgo a partir del score (0-100).
  static RiskLevel levelFromScore(num score) {
    if (score >= 70) return RiskLevel.high;
    if (score >= 40) return RiskLevel.medium;
    return RiskLevel.low;
  }

  /// Etiqueta en español.
  static String labelFor(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return 'ALTO';
      case RiskLevel.medium:
        return 'MEDIO';
      case RiskLevel.low:
        return 'BAJO';
    }
  }

  /// Color asociado a cada nivel, tomado de core/theme/app_theme.dart.
  static Color colorFor(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return AppColors.riskHigh;
      case RiskLevel.medium:
        return AppColors.riskMedium;
      case RiskLevel.low:
        return AppColors.riskLow;
    }
  }

  /// Atajo: de un score directo a su etiqueta+color, sin pasos intermedios.
  static (String label, Color color) describe(num score) {
    final level = levelFromScore(score);
    return (labelFor(level), colorFor(level));
  }
}
