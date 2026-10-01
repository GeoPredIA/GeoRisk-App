// =============================================================
// features/dashboard/data/repositories/dashboard_repository_impl.dart
// -------------------------------------------------------------
// Implementación CONCRETA del contrato DashboardRepository.
// =============================================================

import '../../domain/entities/zone_summary.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource _datasource;

  const DashboardRepositoryImpl(this._datasource);

  @override
  Future<DashboardStats> getStats() {
    return _datasource.fetchStats();
  }

  @override
  Future<List<ZoneSummary>> getZones({
    String? filterLevel,
    String? searchQuery,
    String? region,
    String? province,
    String? district,
  }) {
    return _datasource.fetchZones(
      filterLevel: filterLevel,
      searchQuery: searchQuery,
      region: region,
      province: province,
      district: district,
    );
  }
}