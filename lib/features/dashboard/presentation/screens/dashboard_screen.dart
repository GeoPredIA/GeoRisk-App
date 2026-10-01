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
import '../widgets/geography_cascade_filter.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
// Perfil y autenticación directa (sin login previo)

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoPreIA',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Operador del Sistema',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProfileScreen(),
              ),
            ),
            icon: const CircleAvatar(child: Icon(Icons.person_outline)),
          ),
          const SizedBox(width: 8),
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
                    const Icon(Icons.cloud_off,
                        size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text(provider.errorMessage ?? 'Ocurrió un error',
                        textAlign: TextAlign.center),
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
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // --- Card de introducción ---
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SyncStatusChip(
                                      label: 'Inteligencia para la exploración',
                                      status: SyncStatus.online,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              SyncStatusChip(
                                  label: 'SAP HANA Cloud · Sincronizado',
                                  status: SyncStatus.online),
                              SizedBox(height: 12),
                              Text(
                                'Cada zona, una decisión informada',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Monitoreo predictivo multivariable geológico, ambiental y social.',
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Grilla de 4 KPI cards (2x2) ---
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 720
                              ? 4
                              : (constraints.maxWidth < 240 ? 1 : 2);
                          final aspectRatio = columns == 1
                              ? 1.2
                              : (constraints.maxWidth < 360
                                  ? 1.1
                                  : (constraints.maxWidth < 480
                                      ? 1.2
                                      : (constraints.maxWidth < 720
                                          ? 1.65
                                          : 1.3)));

                          return GridView.count(
                            crossAxisCount: columns,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: aspectRatio,
                            children: [
                              KpiCard(
                                title: 'Zonas de exploración',
                                value: '${stats.totalZones}',
                                footer: Text(
                                    '↑ +${stats.newZonesThisMonth} este mes',
                                    style: const TextStyle(
                                        color: AppColors.riskLow,
                                        fontSize: 12)),
                              ),
                              KpiCard(
                                title: 'Riesgo global prom.',
                                value: stats.avgGlobalRisk.toStringAsFixed(1),
                                suffix: '/100',
                                footer: Text('● ${stats.avgRiskLabel}',
                                    style: const TextStyle(
                                        color: AppColors.riskMedium,
                                        fontSize: 12)),
                              ),
                              KpiCard(
                                title: 'Pendientes de revisión',
                                value: '${stats.pendingReviews}',
                                footer: Text('● ${stats.pendingCriticality}',
                                    style: const TextStyle(
                                        color: AppColors.riskHigh,
                                        fontSize: 12)),
                              ),
                              KpiCard(
                                title: 'Evaluaciones compl.',
                                value: '${stats.completedEvaluations}',
                                footer: Text(
                                    '+ ${stats.aiConfidence}% conf. IA',
                                    style: const TextStyle(
                                        color: AppColors.riskLow,
                                        fontSize: 12)),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Selector geográfico en cascada (Departamento -> Provincia -> Distrito)
                      GeographyCascadeFilter(provider: provider),

                      const Text('Zonas bajo evaluación',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      ZoneSearchBar(onChanged: provider.setSearchQuery),
                      const SizedBox(height: 12),
                      ZoneFilterChips(
                        activeFilter: provider.activeFilter,
                        onFilterChanged: provider.setFilter,
                      ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
                if (provider.zones.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        alignment: Alignment.center,
                        child: const Column(
                          children: [
                            Icon(Icons.search_off,
                                size: 48, color: AppColors.textMuted),
                            SizedBox(height: 10),
                            Text(
                              'No se encontraron zonas en esta ubicación',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Prueba seleccionando otro distrito o limpiando los filtros.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            ZoneListCard(zone: provider.zones[index]),
                        childCount: provider.zones.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
