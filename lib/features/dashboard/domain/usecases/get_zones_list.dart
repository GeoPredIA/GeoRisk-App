// =============================================================
// features/dashboard/domain/usecases/get_zones_list.dart
// -------------------------------------------------------------
// Caso de uso: obtener la lista de zonas mineras con filtros.
// =============================================================

import '../entities/zone_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetZonesList {
  final DashboardRepository _repository;

  const GetZonesList(this._repository);

  Future<List<ZoneSummary>> call({
    String? filterLevel,
    String? searchQuery,
    String? region,
    String? province,
    String? district,
  }) {
    return _repository.getZones(
      filterLevel: filterLevel,
      searchQuery: searchQuery,
      region: region,
      province: province,
      district: district,
    );
  }
}