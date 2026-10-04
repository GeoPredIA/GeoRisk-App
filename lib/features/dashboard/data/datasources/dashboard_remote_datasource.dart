// =============================================================
// features/dashboard/data/datasources/dashboard_remote_datasource.dart
// -------------------------------------------------------------
// Datasource para el Panorama. Conecta directamente con
// MiningDatasetService (11,458 evaluaciones / 140 zonas de minería)
// y permite conectarse con SAP HANA Cloud en producción.
// =============================================================

import '../../../../core/network/sap_api_client.dart';
import '../../../../core/constants/sap_endpoints.dart';
import '../models/zone_summary_model.dart';
import '../models/dashboard_stats_model.dart';
import '../services/mining_dataset_service.dart';

class DashboardRemoteDatasource {
  final SapApiClient _apiClient;

  DashboardRemoteDatasource(this._apiClient);

  static const _remoteCacheDuration = Duration(minutes: 2);
  List<ZoneSummaryModel>? _remoteZonesCache;
  DateTime? _remoteZonesCachedAt;
  Future<List<ZoneSummaryModel>>? _remoteZonesRequest;

  Future<DashboardStatsModel> fetchStats() async {
    final remote = await _fetchRemoteZones();
    if (remote.isNotEmpty) {
      final average = remote.fold<int>(0, (sum, z) => sum + z.globalScore) /
          remote.length;
      final pending = remote.where((z) => z.hasActiveInspection).length;
      return DashboardStatsModel(
        totalZones: remote.length,
        newZonesThisMonth: 0,
        avgGlobalRisk: double.parse(average.toStringAsFixed(1)),
        avgRiskLabel: average >= 70 ? 'Alto' : (average >= 40 ? 'Moderado' : 'Bajo'),
        pendingReviews: pending,
        pendingCriticality: pending > 0 ? 'Requiere revisión' : 'Sin pendientes',
        completedEvaluations:
            remote.fold<int>(0, (sum, z) => sum + z.totalEvaluaciones),
        aiConfidence: 96.8,
      );
    }
    if (!MiningDatasetService.instance.isLoaded) {
      await MiningDatasetService.instance.init();
    }

    if (MiningDatasetService.instance.isLoaded &&
        MiningDatasetService.instance.allZones.isNotEmpty) {
      final zones = MiningDatasetService.instance.allZones;
      final total = zones.length;
      final sumRisk = zones.fold<int>(0, (acc, z) => acc + z.globalScore);
      final avgRisk = sumRisk / (total > 0 ? total : 1);
      final pendingReviews = zones.where((z) =>
          z.estadoRevision.toLowerCase().contains('revision') ||
          z.estadoRevision.toLowerCase().contains('pendiente') ||
          z.estadoRevision.toLowerCase().contains('observada')).length;

      return DashboardStatsModel(
        totalZones: total,
        newZonesThisMonth: 14,
        avgGlobalRisk: double.parse(avgRisk.toStringAsFixed(1)),
        avgRiskLabel: avgRisk >= 70 ? 'Alto' : (avgRisk >= 40 ? 'Moderado' : 'Bajo'),
        pendingReviews: pendingReviews,
        pendingCriticality: 'Alta criticidad',
        completedEvaluations: 11458,
        aiConfidence: 96.8,
      );
    }

    // --- MOCK fallback: si no hay dataset disponible ---
    await Future.delayed(const Duration(milliseconds: 300));
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

  Future<List<ZoneSummaryModel>> fetchZones({
    String? filterLevel,
    String? searchQuery,
    String? region,
    String? province,
    String? district,
  }) async {
    final remote = await _fetchRemoteZones();
    if (remote.isNotEmpty) {
      final query = (searchQuery ?? '').trim().toLowerCase();
      return remote.where((zone) {
        final level = _levelLabel(zone.globalScore);
        final matchesLevel = filterLevel == null ||
            filterLevel == 'TODOS' ||
            filterLevel == level;
        final matchesRegion = region == null || zone.departamento == region;
        final matchesProvince = province == null || zone.provincia == province;
        final matchesDistrict = district == null || zone.distrito == district;
        final matchesSearch = query.isEmpty ||
            zone.name.toLowerCase().contains(query) ||
            zone.code.toLowerCase().contains(query) ||
            zone.region.toLowerCase().contains(query) ||
            zone.mineral.toLowerCase().contains(query) ||
            zone.empresa.toLowerCase().contains(query);
        return matchesLevel &&
            matchesRegion &&
            matchesProvince &&
            matchesDistrict &&
            matchesSearch;
      }).toList();
    }
    if (!MiningDatasetService.instance.isLoaded) {
      await MiningDatasetService.instance.init();
    }

    if (MiningDatasetService.instance.isLoaded &&
        MiningDatasetService.instance.allZones.isNotEmpty) {
      final records = MiningDatasetService.instance.filter(
        region: region,
        province: province,
        district: district,
        riskLevel: filterLevel,
        searchQuery: searchQuery,
      );

      return records.map((r) => ZoneSummaryModel(
        code: r.code,
        name: r.name,
        region: '${r.region} · ${r.provincia} · ${r.distrito}',
        globalScore: r.globalScore,
        geoScore: r.geoScore,
        envScore: r.envScore,
        socialScore: r.socialScore,
        hasActiveInspection: r.estadoRevision.toLowerCase().contains('revision') ||
            r.metodoEvaluacion.toLowerCase().contains('campo'),
        departamento: r.region,
        provincia: r.provincia,
        distrito: r.distrito,
        mineral: r.mineralPrincipal,
        empresa: r.empresaOperadora,
        fase: r.faseExploracion,
        altitud: r.altitudMsnm,
        tipoYacimiento: r.tipoYacimiento,
        superficieHa: r.superficieHa,
        estadoRevision: r.estadoRevision,
        decisionEspecialista: r.decisionEspecialista,
        comentarioRevision: r.comentarioRevision,
        totalEvaluaciones: r.totalEvaluations,
      )).toList();
    }

    // --- MOCK fallback si no se carga el CSV ---
    await Future.delayed(const Duration(milliseconds: 300));
    final allZones = <ZoneSummaryModel>[
      const ZoneSummaryModel(
        code: 'QN-402', name: 'Quellaveco Norte', region: 'Moquegua · Mariscal Nieto · Torata',
        globalScore: 74, geoScore: 72, envScore: 68, socialScore: 78,
        hasActiveInspection: true,
        mineral: 'Cobre', empresa: 'Anglo American Quellaveco',
      ),
      const ZoneSummaryModel(
        code: 'AP-118', name: 'Antamina Profunda', region: 'Áncash · Huari · San Marcos',
        globalScore: 45, geoScore: 45, envScore: 52, socialScore: 38,
        mineral: 'Cobre / Zinc', empresa: 'Compañía Minera Antamina',
      ),
      const ZoneSummaryModel(
        code: 'TT-892', name: 'Tintaya Sur / Coroccohuayco', region: 'Cusco · Espinar · Yauri',
        globalScore: 76, geoScore: 58, envScore: 81, socialScore: 84,
        mineral: 'Cobre', empresa: 'Glencore Antapaccay',
      ),
      const ZoneSummaryModel(
        code: 'TE-084', name: 'Toromocho Expansión', region: 'Junín · Yauli · Morococha',
        globalScore: 61, geoScore: 64, envScore: 59, socialScore: 62,
        mineral: 'Cobre / Molibdeno', empresa: 'Minera Chinalco Perú',
      ),
      const ZoneSummaryModel(
        code: 'CV-310', name: 'Cerro Verde Sector IV', region: 'Arequipa · Arequipa · Uchumayo',
        globalScore: 28, geoScore: 28, envScore: 32, socialScore: 25,
        mineral: 'Cobre', empresa: 'Sociedad Minera Cerro Verde',
      ),
    ];

    return allZones.where((zone) {
      final matchesLevel = filterLevel == null || filterLevel == 'TODOS' || _levelLabel(zone.globalScore) == filterLevel;
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

  Future<List<ZoneSummaryModel>> _fetchRemoteZones() async {
    final now = DateTime.now();
    final cachedAt = _remoteZonesCachedAt;
    final cached = _remoteZonesCache;
    if (cached != null &&
        cachedAt != null &&
        now.difference(cachedAt) < _remoteCacheDuration) {
      return cached;
    }

    final inFlight = _remoteZonesRequest;
    if (inFlight != null) return inFlight;

    final request = _loadRemoteZones();
    _remoteZonesRequest = request;
    try {
      final zones = await request;
      _remoteZonesCache = zones;
      _remoteZonesCachedAt = DateTime.now();
      return zones;
    } finally {
      _remoteZonesRequest = null;
    }
  }

  Future<List<ZoneSummaryModel>> _loadRemoteZones() async {
    try {
      final data = await _apiClient.getJson(
        '${SapEndpoints.backendBaseUrl}${SapEndpoints.zonesPath}',
      );
      if (data is! List) return const [];
      final dataset = MiningDatasetService.instance;
      return data
          .whereType<Map>()
          .map((item) {
            final json = Map<String, dynamic>.from(item);
            final localRecord = dataset.getZoneByCode(json['id']?.toString() ?? '');
            return ZoneSummaryModel.fromGeoPrediaApi(
              json,
              localRecord: localRecord,
            );
          })
          .where((zone) => zone.code.isNotEmpty)
          .toList();
    } catch (_) {
      // La app móvil sigue operativa con el dataset empaquetado si BTP cae.
      return const [];
    }
  }
}
