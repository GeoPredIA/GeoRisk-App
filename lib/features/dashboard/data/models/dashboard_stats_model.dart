// =============================================================
// features/dashboard/data/models/dashboard_stats_model.dart
// -------------------------------------------------------------
// Igual que ZoneSummaryModel, pero para las 4 tarjetas KPI del
// Panorama. Traduce el JSON de SAP a la entidad DashboardStats.
// =============================================================

import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalZones,
    required super.newZonesThisMonth,
    required super.avgGlobalRisk,
    required super.avgRiskLabel,
    required super.pendingReviews,
    required super.pendingCriticality,
    required super.completedEvaluations,
    required super.aiConfidence,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalZones: json['TotalZones'] as int,
      newZonesThisMonth: json['NewZonesThisMonth'] as int,
      avgGlobalRisk: (json['AvgGlobalRisk'] as num).toDouble(),
      avgRiskLabel: json['AvgRiskLabel'] as String,
      pendingReviews: json['PendingReviews'] as int,
      pendingCriticality: json['PendingCriticality'] as String,
      completedEvaluations: json['CompletedEvaluations'] as int,
      aiConfidence: (json['AiConfidence'] as num).toDouble(),
    );
  }
}
