// =============================================================
// features/dashboard/domain/repositories/dashboard_repository.dart
// -------------------------------------------------------------
// CONTRATO (interfaz abstracta): define QUÉ se puede pedir,
// sin decir CÓMO se obtiene. Esto permite que domain/usecases
// dependan de esta interfaz y no de la implementación concreta
// (que sí sabe hablar con SAP HANA Cloud).
//
// Ventaja práctica: en tests, puedes crear un
// "FakeDashboardRepository" que implemente esto mismo, sin
// necesitar conexión real a SAP.
// =============================================================

import '../entities/zone_summary.dart';
import '../entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getStats();

  /// [filterLevel] puede ser null (Todos), 'ALTO', 'MEDIO' o 'BAJO'.
  /// [searchQuery] filtra por nombre, región o código.
  Future<List<ZoneSummary>> getZones({
    String? filterLevel,
    String? searchQuery,
  });
}
