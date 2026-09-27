// =============================================================
// features/dashboard/presentation/providers/dashboard_provider.dart
// -------------------------------------------------------------
// Maneja el ESTADO de la pantalla Panorama: si está cargando,
// si hubo error, las stats, la lista de zonas y el filtro/búsqueda
// activos. La pantalla (dashboard_screen.dart) solo "escucha"
// este provider y se redibuja cuando algo cambia.
//
// Usa ChangeNotifier (paquete `provider`) por ser el enfoque más
// simple y ampliamente enseñado. Si luego prefieres Riverpod o
// Bloc, solo se reescribe este archivo — el resto del feature
// no cambia.
// =============================================================

import 'package:flutter/material.dart';

import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/zone_summary.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../domain/usecases/get_zones_list.dart';

enum LoadStatus { initial, loading, success, error }

class DashboardProvider extends ChangeNotifier {
  final GetDashboardStats _getDashboardStats;
  final GetZonesList _getZonesList;

  DashboardProvider({
    required GetDashboardStats getDashboardStats,
    required GetZonesList getZonesList,
  })  : _getDashboardStats = getDashboardStats,
        _getZonesList = getZonesList {
    // Al crear el provider, carga los datos automáticamente.
    loadDashboard();
  }

  LoadStatus status = LoadStatus.initial;
  String? errorMessage;

  DashboardStats? stats;
  List<ZoneSummary> zones = [];

  // Filtro de nivel actualmente seleccionado: null = "Todos".
  String? activeFilter;
  String searchQuery = '';

  /// Carga inicial: pide stats y zonas en paralelo.
  Future<void> loadDashboard() async {
    status = LoadStatus.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _getDashboardStats(),
        _getZonesList(filterLevel: activeFilter, searchQuery: searchQuery),
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

  /// Se llama cuando el usuario toca un chip de filtro (Todos/Alto/Medio/Bajo).
  Future<void> setFilter(String? level) async {
    activeFilter = level;
    await _reloadZones();
  }

  /// Se llama en cada cambio del texto de búsqueda.
  Future<void> setSearchQuery(String query) async {
    searchQuery = query;
    await _reloadZones();
  }

  Future<void> _reloadZones() async {
    try {
      zones = await _getZonesList(filterLevel: activeFilter, searchQuery: searchQuery);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      status = LoadStatus.error;
      notifyListeners();
    }
  }
}
