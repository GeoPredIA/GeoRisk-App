// =============================================================
// features/dashboard/domain/entities/dashboard_stats.dart
// -------------------------------------------------------------
// Entidad de dominio para las 4 tarjetas KPI de la Imagen 1:
// "42 Zonas de exploración", "48.2 Riesgo global prom.",
// "7 Pendientes de revisión", "135 Evaluaciones completadas".
// =============================================================

class DashboardStats {
  final int totalZones;            // 42
  final int newZonesThisMonth;     // +3 este mes
  final double avgGlobalRisk;      // 48.2
  final String avgRiskLabel;       // "Moderado"
  final int pendingReviews;        // 7
  final String pendingCriticality; // "Alta criticidad"
  final int completedEvaluations;  // 135
  final double aiConfidence;       // 94.8 (%)

  const DashboardStats({
    required this.totalZones,
    required this.newZonesThisMonth,
    required this.avgGlobalRisk,
    required this.avgRiskLabel,
    required this.pendingReviews,
    required this.pendingCriticality,
    required this.completedEvaluations,
    required this.aiConfidence,
  });
}
