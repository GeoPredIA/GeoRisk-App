// =============================================================
// features/dashboard/domain/usecases/get_zones_list.dart
// -------------------------------------------------------------
// Caso de uso: obtener la lista de zonas, aplicando el filtro de
// nivel de riesgo (Todos/Alto/Medio/Bajo) y el texto de búsqueda
// que ves en la Imagen 2 de tus mockups.
// =============================================================

import '../entities/zone_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetZonesList {
  final DashboardRepository _repository;

  const GetZonesList(this._repository);

  Future<List<ZoneSummary>> call({String? filterLevel, String? searchQuery}) {
    return _repository.getZones(filterLevel: filterLevel, searchQuery: searchQuery);
  }
}
