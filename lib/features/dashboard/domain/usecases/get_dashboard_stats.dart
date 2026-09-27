// =============================================================
// features/dashboard/domain/usecases/get_dashboard_stats.dart
// -------------------------------------------------------------
// Caso de uso: una acción de negocio concreta y con un solo
// propósito. El provider (presentation) llama a este usecase,
// nunca directamente al repository.
//
// Aquí es donde, si en el futuro necesitas aplicar alguna regla
// de negocio antes de mostrar las stats (ej. redondear, validar
// rangos), la agregas — sin tocar la UI ni la capa data.
// =============================================================

import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStats {
  final DashboardRepository _repository;

  const GetDashboardStats(this._repository);

  Future<DashboardStats> call() {
    return _repository.getStats();
  }
}
