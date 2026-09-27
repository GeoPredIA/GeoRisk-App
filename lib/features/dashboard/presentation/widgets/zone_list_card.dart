// =============================================================
// features/dashboard/presentation/widgets/zone_list_card.dart
// -------------------------------------------------------------
// La card individual "Quellaveco Norte · ALTO 74/100" con las
// 3 mini-columnas Geo/Amb/Soc, vista en la Imagen 2. Al tocarla,
// navega al detalle de la zona (feature zone_detail).
// =============================================================

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/risk_badge.dart';
import '../../../../app/routes/app_router.dart';
import '../../domain/entities/zone_summary.dart';

class ZoneListCard extends StatelessWidget {
  final ZoneSummary zone;

  const ZoneListCard({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => AppRoutes.goToZoneDetail(context, zoneCode: zone.code),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tag "Inspección Activa" (solo si aplica)
              if (zone.hasActiveInspection)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.riskLow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '● Inspección Activa',
                    style: TextStyle(color: AppColors.riskLow, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),

              // Nombre de la zona + badge de riesgo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      zone.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  RiskBadge(score: zone.globalScore),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${zone.region} · ${zone.code}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Las 3 mini-columnas Geo / Amb / Soc
              Row(
                children: [
                  _MiniScore(label: 'Geo', value: zone.geoScore),
                  const SizedBox(width: 8),
                  _MiniScore(label: 'Amb', value: zone.envScore),
                  const SizedBox(width: 8),
                  _MiniScore(label: 'Soc', value: zone.socialScore),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget privado (solo se usa dentro de este archivo) para cada
/// una de las 3 mini-columnas de puntaje.
class _MiniScore extends StatelessWidget {
  final String label;
  final int value;

  const _MiniScore({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text('$value', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
