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
// Perfil y autenticación directa 

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoPredIA',
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
                        color: AppColors.headerGreen,
                        child: Padding(
                          padding: EdgeInsets.all(18),
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
                                status: SyncStatus.online,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Cada zona, una decisión informada',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Monitoreo predictivo multivariable geológico, ambiental y social.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Grilla de 4 KPI cards (2x2) ---
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth < 240 ? 1 : 2;
                          final cards = <Widget>[
                            KpiCard(
                              title: 'Zonas de exploración',
                              value: '${stats.totalZones}',
                              footer: Text(
                                '↑ +${stats.newZonesThisMonth} este mes',
                                style: const TextStyle(
                                  color: AppColors.riskLow,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            KpiCard(
                              title: 'Riesgo global prom.',
                              value: stats.avgGlobalRisk.toStringAsFixed(1),
                              suffix: '/100',
                              footer: Text(
                                '● ${stats.avgRiskLabel}',
                                style: const TextStyle(
                                  color: AppColors.riskMedium,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            KpiCard(
                              title: 'Pendientes de revisión',
                              value: '${stats.pendingReviews}',
                              footer: Text(
                                '● ${stats.pendingCriticality}',
                                style: const TextStyle(
                                  color: AppColors.riskHigh,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            KpiCard(
                              title: 'Evaluaciones completas',
                              value: '${stats.completedEvaluations}',
                              footer: Text(
                                '+ ${stats.aiConfidence}% conf. IA',
                                style: const TextStyle(
                                  color: AppColors.riskLow,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ];
                          final rowCount =
                              (cards.length + columns - 1) ~/ columns;

                          return Column(
                            children: [
                              for (var row = 0; row < rowCount; row++) ...[
                                if (row > 0)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    child: _MountainDivider(),
                                  ),
                                Row(
                                  children: [
                                    for (var column = 0;
                                        column < columns;
                                        column++) ...[
                                      if (column > 0) const SizedBox(width: 12),
                                      Expanded(
                                        child: row * columns + column <
                                                cards.length
                                            ? cards[row * columns + column]
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
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

class _MountainDivider extends StatelessWidget {
  const _MountainDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 54,
      width: double.infinity,
      child: CustomPaint(painter: _MountainDividerPainter()),
    );
  }
}

class _MountainDividerPainter extends CustomPainter {
  const _MountainDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = AppColors.terrainBrown.withValues(alpha: 0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final distantOutline = Paint()
      ..color = AppColors.terrainBrown.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final ridge = Path()
      ..moveTo(0, size.height * 0.82)
      ..lineTo(size.width * 0.13, size.height * 0.38)
      ..lineTo(size.width * 0.23, size.height * 0.61)
      ..lineTo(size.width * 0.4, size.height * 0.13)
      ..lineTo(size.width * 0.51, size.height * 0.52)
      ..lineTo(size.width * 0.68, size.height * 0.04)
      ..lineTo(size.width * 0.82, size.height * 0.47)
      ..lineTo(size.width * 0.92, size.height * 0.22)
      ..lineTo(size.width, size.height * 0.53);
    canvas.drawPath(ridge, outline);

    final distantRidge = Path()
      ..moveTo(0, size.height * 0.96)
      ..lineTo(size.width * 0.19, size.height * 0.55)
      ..lineTo(size.width * 0.31, size.height * 0.78)
      ..lineTo(size.width * 0.49, size.height * 0.35)
      ..lineTo(size.width * 0.63, size.height * 0.76)
      ..lineTo(size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.75);
    canvas.drawPath(distantRidge, distantOutline);
  }

  @override
  bool shouldRepaint(covariant _MountainDividerPainter oldDelegate) => false;
}
