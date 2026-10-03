// =============================================================
// features/dashboard/presentation/widgets/zone_list_card.dart
// -------------------------------------------------------------
// Card interactiva de cada zona de exploración minera del dataset.
// =============================================================

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/risk_badge.dart';
import '../../../../app/routes/app_router.dart';
import '../../domain/entities/zone_summary.dart';

class ZoneListCard extends StatelessWidget {
  final ZoneSummary zone;

  const ZoneListCard({super.key, required this.zone});

  Color _getMineralColor(String mineral) {
    final m = mineral.toLowerCase();
    if (m.contains('cobre')) return const Color(0xFFD35400);
    if (m.contains('oro')) return const Color(0xFFD4AC0D);
    if (m.contains('plata')) return const Color(0xFF5D6D7E);
    if (m.contains('zinc')) return const Color(0xFF2E86C1);
    if (m.contains('hierro')) return const Color(0xFF78281F);
    return AppColors.primaryDark;
  }

  @override
  Widget build(BuildContext context) {
    final mineralColor = _getMineralColor(zone.mineral);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1.1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => AppRoutes.goToZoneDetail(context, zoneCode: zone.code),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tags superiores: Mineral + Estado de Inspección
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: mineralColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: mineralColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.diamond_outlined,
                            size: 12, color: mineralColor),
                        const SizedBox(width: 4),
                        Text(
                          zone.mineral,
                          style: TextStyle(
                            color: mineralColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  if (zone.hasActiveInspection)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.riskHigh.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '● En Revisión HITL',
                        style: TextStyle(
                            color: AppColors.riskHigh,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),

                  const Spacer(),
                  // Conteo de evaluaciones históricas registradas en el dataset
                  Text(
                    '${zone.totalEvaluaciones} evals.',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Nombre de la zona + Badge de riesgo
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${zone.region} · Código: ${zone.code}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  RiskBadge(score: zone.globalScore),
                ],
              ),

              if (zone.empresa.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.business,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${zone.empresa} (${zone.fase})',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 14),

              // Las 3 mini-columnas Geo / Amb / Soc con barra sutil
              Row(
                children: [
                  _MiniScore(
                    label: 'Geológico',
                    value: zone.geoScore,
                    accentColor: const Color(0xFF8D6E63),
                  ),
                  const SizedBox(width: 8),
                  _MiniScore(
                    label: 'Ambiental',
                    value: zone.envScore,
                    accentColor: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 8),
                  _MiniScore(
                    label: 'Social',
                    value: zone.socialScore,
                    accentColor: const Color(0xFFE65100),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniScore extends StatelessWidget {
  final String label;
  final int value;
  final Color accentColor;

  const _MiniScore({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: AppColors.borderSubtle.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '$value',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: accentColor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (value / 100.0).clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
