// =============================================================
// features/dashboard/domain/repositories/dashboard_repository.dart
// -------------------------------------------------------------
// CONTRATO (interfaz abstracta): define QUÉ se puede pedir.
// =============================================================

import '../entities/zone_summary.dart';
import '../entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getStats();

  Future<List<ZoneSummary>> getZones({
    String? filterLevel,
    String? searchQuery,
    String? region,
    String? province,
    String? district,
  });
}