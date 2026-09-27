// =============================================================
// features/dashboard/data/datasources/dashboard_remote_datasource.dart
// -------------------------------------------------------------
// Es el ÚNICO archivo que debería hacer la llamada HTTP real a
// SAP HANA Cloud para el Panorama.
//
// ESTADO ACTUAL: usa datos MOCK (simulados) para que puedas
// desarrollar la UI sin depender de que el ambiente Trial de SAP
// ya esté configurado. Los datos mock replican EXACTAMENTE lo
// que se ve en tus Imágenes 1 y 2.
//
// CUÁNDO CONECTAR SAP REAL: reemplaza el cuerpo de cada método
// (marcado con TODO) por la llamada real usando `_apiClient.get(...)`
// y el endpoint de core/constants/sap_endpoints.dart. La firma del
// método (lo que recibe/devuelve) NO cambia, así que
// dashboard_repository_impl.dart no se entera del cambio.
// =============================================================

import '../../../../core/network/sap_api_client.dart';
import '../models/zone_summary_model.dart';
import '../models/dashboard_stats_model.dart';

class DashboardRemoteDatasource {
  // ignore: unused_field
  final SapApiClient _apiClient;

  const DashboardRemoteDatasource(this._apiClient);

  Future<DashboardStatsModel> fetchStats() async {
    // TODO (SAP real): descomentar cuando el endpoint esté disponible.
    // final json = await _apiClient.get(
    //   '${SapEndpoints.hanaCloudBaseUrl}/DashboardStats',
    // );
    // return DashboardStatsModel.fromJson(json);

    // --- MOCK: simula latencia de red y devuelve datos de prueba ---
    await Future.delayed(const Duration(milliseconds: 400));
    return const DashboardStatsModel(
      totalZones: 42,
      newZonesThisMonth: 3,
      avgGlobalRisk: 48.2,
      avgRiskLabel: 'Moderado',
      pendingReviews: 7,
      pendingCriticality: 'Alta criticidad',
      completedEvaluations: 135,
      aiConfidence: 94.8,
    );
  }

  Future<List<ZoneSummaryModel>> fetchZones({String? filterLevel, String? searchQuery}) async {
    // TODO (SAP real): descomentar y ajustar los queryParams según
    // cómo tu API OData espere filtrar (por ejemplo $filter en OData).
    // final json = await _apiClient.get(
    //   '${SapEndpoints.hanaCloudBaseUrl}${SapEndpoints.zonesPath}',
    //   queryParams: {
    //     if (filterLevel != null) 'riskLevel': filterLevel,
    //     if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
    //   },
    // );
    // final list = (json['value'] as List).cast<Map<String, dynamic>>();
    // return list.map(ZoneSummaryModel.fromJson).toList();

    // --- MOCK: réplica de las 5 zonas visibles en la Imagen 2 ---
    await Future.delayed(const Duration(milliseconds: 400));
    final allZones = <ZoneSummaryModel>[
      const ZoneSummaryModel(
        code: 'QN-402', name: 'Quellaveco Norte', region: 'Moquegua · Cuadrángulo 34-u',
        globalScore: 74, geoScore: 72, envScore: 68, socialScore: 78,
        hasActiveInspection: true,
      ),
      const ZoneSummaryModel(
        code: 'AP-118', name: 'Antamina Profunda', region: 'Áncash',
        globalScore: 45, geoScore: 45, envScore: 52, socialScore: 38,
      ),
      const ZoneSummaryModel(
        code: 'TT-892', name: 'Tintaya Sur / Coroccohuayco', region: 'Cusco',
        globalScore: 76, geoScore: 58, envScore: 81, socialScore: 84,
      ),
      const ZoneSummaryModel(
        code: 'TE-084', name: 'Toromocho Expansión', region: 'Junín',
        globalScore: 61, geoScore: 64, envScore: 59, socialScore: 62,
      ),
      const ZoneSummaryModel(
        code: 'CV-310', name: 'Cerro Verde Sector IV', region: 'Arequipa',
        globalScore: 28, geoScore: 28, envScore: 32, socialScore: 25,
      ),
    ];

    // Aplica el filtro de nivel y de búsqueda localmente sobre el mock,
    // igual que lo haría el backend real.
    return allZones.where((zone) {
      final matchesLevel = filterLevel == null || _levelLabel(zone.globalScore) == filterLevel;
      final query = (searchQuery ?? '').toLowerCase();
      final matchesSearch = query.isEmpty ||
          zone.name.toLowerCase().contains(query) ||
          zone.code.toLowerCase().contains(query) ||
          zone.region.toLowerCase().contains(query);
      return matchesLevel && matchesSearch;
    }).toList();
  }

  String _levelLabel(int score) {
    if (score >= 70) return 'ALTO';
    if (score >= 40) return 'MEDIO';
    return 'BAJO';
  }
}
