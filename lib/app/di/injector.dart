// =============================================================
// app/di/injector.dart
// -------------------------------------------------------------
// Aquí se "arma" el árbol de dependencias de cada feature:
// datasource -> repository -> usecases -> provider.
//
// Ventaja de tenerlo centralizado: si mañana cambias
// DashboardRemoteDatasource (mock) por una implementación real
// que llama a SAP HANA Cloud, SOLO cambias esta línea — el resto
// de la app (pantallas, providers) no se entera del cambio.
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/sap_api_client.dart';

// --- Dashboard ---
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_stats.dart';
import '../../features/dashboard/domain/usecases/get_zones_list.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';

class Injector {
  /// Devuelve la lista de providers que se inyectan en el MultiProvider
  /// del main.dart. Cada feature nuevo agrega su propio bloque aquí.
  static List<ChangeNotifierProvider> buildProviders() {
    // Cliente HTTP compartido por todos los datasources que hablan con SAP.
    final sapApiClient = SapApiClient();

    // ---------- Dashboard ----------
    final dashboardDatasource = DashboardRemoteDatasource(sapApiClient);
    final dashboardRepository = DashboardRepositoryImpl(dashboardDatasource);
    final getDashboardStats = GetDashboardStats(dashboardRepository);
    final getZonesList = GetZonesList(dashboardRepository);

    return [
      ChangeNotifierProvider<DashboardProvider>(
        create: (_) => DashboardProvider(
          getDashboardStats: getDashboardStats,
          getZonesList: getZonesList,
        ),
      ),

      // A medida que construyas zone_detail, multiagent_analysis,
      // iot_sentinel, review_approval e integration, agregas aquí
      // su propio ChangeNotifierProvider siguiendo el mismo patrón.
    ];
  }
}
