// =============================================================
// features/dashboard/presentation/providers/dashboard_provider.dart
// -------------------------------------------------------------
// Provider del Panorama: gestiona datos, filtros geográficos
// (Región / Provincia / Distrito) y búsqueda en tiempo real.
// =============================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/zone_summary.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../domain/usecases/get_zones_list.dart';
import '../../data/services/mining_dataset_service.dart';

enum LoadStatus { initial, loading, success, error }

class DashboardProvider extends ChangeNotifier {
  final GetDashboardStats _getDashboardStats;
  final GetZonesList _getZonesList;

  DashboardProvider({
    required GetDashboardStats getDashboardStats,
    required GetZonesList getZonesList,
  })  : _getDashboardStats = getDashboardStats,
        _getZonesList = getZonesList {
    loadDashboard();
  }

  LoadStatus status = LoadStatus.initial;
  String? errorMessage;

  DashboardStats? stats;
  List<ZoneSummary> zones = [];

  // Filtros activos
  String? activeFilter; // null = "TODOS", 'ALTO', 'MEDIO', 'BAJO'
  String searchQuery = '';
  Timer? _searchDebounce;
  int _reloadRevision = 0;

  // Filtros geográficos en cascada
  String? selectedRegion;
  String? selectedProvince;
  String? selectedDistrict;

  List<String> get regions => MiningDatasetService.instance.regions;
  List<String> get provinces =>
      MiningDatasetService.instance.getProvinces(selectedRegion);
  List<String> get districts => MiningDatasetService.instance
      .getDistricts(selectedRegion, selectedProvince);

  /// Carga inicial: pide stats y zonas en paralelo.
  Future<void> loadDashboard() async {
    status = LoadStatus.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _getDashboardStats(),
        _getZonesList(
          filterLevel: activeFilter,
          searchQuery: searchQuery,
          region: selectedRegion,
          province: selectedProvince,
          district: selectedDistrict,
        ),
      ]);
      stats = results[0] as DashboardStats;
      zones = results[1] as List<ZoneSummary>;
      status = LoadStatus.success;
    } catch (e) {
      errorMessage = e.toString();
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Chip de filtro por nivel de riesgo (Todos / Alto / Medio / Bajo)
  Future<void> setFilter(String? level) async {
    activeFilter = level;
    await _reloadZones();
  }

  /// Búsqueda de texto en vivo
  Future<void> setSearchQuery(String query) async {
    searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), _reloadZones);
  }

  /// Selección de Departamento / Región
  Future<void> setRegion(String? region) async {
    if (selectedRegion == region) return;
    selectedRegion =
        (region == 'Todas' || region == null || region.isEmpty) ? null : region;
    selectedProvince = null;
    selectedDistrict = null;
    await _reloadZones();
  }

  /// Selección de Provincia
  Future<void> setProvince(String? province) async {
    if (selectedProvince == province) return;
    selectedProvince =
        (province == 'Todas' || province == null || province.isEmpty)
            ? null
            : province;
    selectedDistrict = null;
    await _reloadZones();
  }

  /// Selección de Distrito
  Future<void> setDistrict(String? district) async {
    if (selectedDistrict == district) return;
    selectedDistrict =
        (district == 'Todos' || district == null || district.isEmpty)
            ? null
            : district;
    await _reloadZones();
  }

  /// Limpiar todos los filtros geográficos
  Future<void> clearGeographyFilters() async {
    selectedRegion = null;
    selectedProvince = null;
    selectedDistrict = null;
    await _reloadZones();
  }

  Future<void> _reloadZones() async {
    final revision = ++_reloadRevision;
    try {
      final result = await _getZonesList(
        filterLevel: activeFilter,
        searchQuery: searchQuery,
        region: selectedRegion,
        province: selectedProvince,
        district: selectedDistrict,
      );
      if (revision != _reloadRevision) return;
      zones = result;
      notifyListeners();
    } catch (e) {
      if (revision != _reloadRevision) return;
      errorMessage = e.toString();
      status = LoadStatus.error;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
