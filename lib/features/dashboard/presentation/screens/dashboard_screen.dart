// =============================================================
// features/dashboard/presentation/screens/dashboard_screen.dart
// -------------------------------------------------------------
// Pantalla completa del PANORAMA (pestaña 1), correspondiente a
// las Imágenes 1 y 2 de tus mockups. Combina:
//   - Header con intro + estado de sincronización
//   - 4 KpiCard (core/widgets)
//   - Buscador + chips de filtro
//   - Lista de ZoneListCard
//
// Esta pantalla NO pide datos directamente: solo "escucha" al
// DashboardProvider (patrón Provider/ChangeNotifier) y reacciona
// a sus cambios de estado.
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/kpi_card.dart';
import '../../../../core/widgets/sync_status_chip.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/zone_filter_chips.dart';
import '../widgets/zone_search_bar.dart';
import '../widgets/zone_list_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoRisk', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(child: Icon(Icons.person_outline)),
          ),
        ],
      ),
      // Consumer se re-construye automáticamente cada vez que
      // DashboardProvider llama a notifyListeners().
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.status == LoadStatus.loading && provider.stats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.status == LoadStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text(provider.errorMessage ?? 'Ocurrió un error', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: provider.loadDashboard,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final stats = provider.stats!;

          return RefreshIndicator(
            onRefresh: provider.loadDashboard,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- Card de introducción ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            SyncStatusChip(label: 'Inteligencia para la exploración', status: SyncStatus.online),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SyncStatusChip(label: 'SAP HANA Cloud · Sincronizado', status: SyncStatus.online),
                        const SizedBox(height: 12),
                        const Text(
                          'Cada zona, una decisión informada',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Monitoreo predictivo multivariable geológico, ambiental y social.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Grilla de 4 KPI cards (2x2) ---
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    KpiCard(
                      title: 'Zonas de exploración',
                      value: '${stats.totalZones}',
                      footer: Text('↑ +${stats.newZonesThisMonth} este mes',
                          style: const TextStyle(color: AppColors.riskLow, fontSize: 12)),
                    ),
                    KpiCard(
                      title: 'Riesgo global prom.',
                      value: stats.avgGlobalRisk.toStringAsFixed(1),
                      suffix: '/100',
                      footer: Text('● ${stats.avgRiskLabel}',
                          style: const TextStyle(color: AppColors.riskMedium, fontSize: 12)),
                    ),
                    KpiCard(
                      title: 'Pendientes de revisión',
                      value: '${stats.pendingReviews}',
                      footer: Text('● ${stats.pendingCriticality}',
                          style: const TextStyle(color: AppColors.riskHigh, fontSize: 12)),
                    ),
                    KpiCard(
                      title: 'Evaluaciones compl.',
                      value: '${stats.completedEvaluations}',
                      footer: Text('+ ${stats.aiConfidence}% conf. IA',
                          style: const TextStyle(color: AppColors.riskLow, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text('Zonas bajo evaluación',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                ZoneSearchBar(onChanged: provider.setSearchQuery),
                const SizedBox(height: 12),
                ZoneFilterChips(
                  activeFilter: provider.activeFilter,
                  onFilterChanged: provider.setFilter,
                ),
                const SizedBox(height: 16),

                // --- Lista de zonas (ya filtrada por el provider) ---
                ...provider.zones.map((zone) => ZoneListCard(zone: zone)),
              ],
            ),
          );
        },
      ),
    );
  }
}
