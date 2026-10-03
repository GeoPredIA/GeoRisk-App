// =============================================================
// features/zone_detail/presentation/screens/zone_detail_screen.dart
// -------------------------------------------------------------
// Pantalla detallada e interactiva de cada zona de exploración
// minera basada en el dataset real (11,458 evaluaciones).
// =============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/risk_badge.dart';
import '../../../dashboard/data/services/mining_dataset_service.dart';

class ZoneDetailScreen extends StatelessWidget {
  final String zoneCode;

  const ZoneDetailScreen({super.key, required this.zoneCode});

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
    final zone = MiningDatasetService.instance.getZoneByCode(zoneCode);

    if (zone == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Zona $zoneCode')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline,
                  size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('Información de la zona $zoneCode no disponible.'),
            ],
          ),
        ),
      );
    }

    final mineralColor = _getMineralColor(zone.mineralPrincipal);
    final riskColor = zone.globalScore >= 70
        ? AppColors.riskHigh
        : (zone.globalScore >= 40 ? AppColors.riskMedium : AppColors.riskLow);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(zone.code,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: mineralColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: mineralColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond, size: 14, color: mineralColor),
                const SizedBox(width: 4),
                Text(
                  zone.mineralPrincipal,
                  style: TextStyle(
                      color: mineralColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card Principal de la Zona
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.place,
                                    size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${zone.region} · ${zone.provincia} · ${zone.distrito}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      RiskBadge(score: zone.globalScore),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MetaInfo(
                          label: 'Operadora', value: zone.empresaOperadora),
                      _MetaInfo(label: 'Fase', value: zone.faseExploracion),
                      _MetaInfo(
                          label: 'Historial',
                          value: '${zone.totalEvaluations} evals.'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Resumen de Riesgo Multivariable
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  riskColor.withValues(alpha: 0.15),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: riskColor.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: riskColor.withValues(alpha: 0.2),
                    border: Border.all(color: riskColor, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      '${zone.globalScore}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: riskColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Índice de Riesgo Combinado: ${zone.globalScore}/100',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Calculado mediante modelos multivariables en base a ${zone.totalEvaluations} evaluaciones históricas y telemetría de campo.',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sección 1: Dimensión Geotécnica
          _DimensionSectionCard(
            title: 'Dimensión Geotécnica',
            score: zone.geoScore,
            icon: Icons.terrain,
            color: const Color(0xFF8D6E63),
            items: [
              _MetricRow(
                  label: 'Índice de Sismicidad',
                  value: '${zone.sismicidadIndice.toStringAsFixed(2)} / 10'),
              _MetricRow(
                  label: 'Estabilidad de Talud',
                  value:
                      '${zone.estabilidadTaludScore.toStringAsFixed(2)} / 10'),
              _MetricRow(
                  label: 'Distancia a Falla Geológica',
                  value: '${zone.distanciaFallaKm.toStringAsFixed(1)} km'),
              _MetricRow(
                  label: 'Pendiente Promedio',
                  value: '${zone.pendientePromedioPct.toStringAsFixed(1)} %'),
              _MetricRow(
                  label: 'Nivel Freático',
                  value: '${zone.nivelFreaticoM.toStringAsFixed(1)} m'),
              _MetricRow(
                  label: 'Potencial Drenaje Ácido',
                  value: 'pH ${zone.potencialDrenajePh.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 16),

          // Sección 2: Dimensión Ambiental
          _DimensionSectionCard(
            title: 'Dimensión Ambiental',
            score: zone.envScore,
            icon: Icons.eco,
            color: const Color(0xFF2E7D32),
            items: [
              _MetricRow(
                  label: 'Índice de Estrés Hídrico',
                  value:
                      '${(zone.indiceEstresHidrico * 100).toStringAsFixed(1)} %'),
              _MetricRow(
                  label: 'Calidad de Aire (PM10)',
                  value: '${zone.calidadAirePm10.toStringAsFixed(1)} µg/m³'),
              _MetricRow(
                  label: 'Distancia a Cuerpo de Agua',
                  value: '${zone.distanciaCuerpoAguaKm.toStringAsFixed(1)} km'),
              _MetricRow(
                  label: 'Cobertura Vegetal',
                  value: '${zone.coberturaVegetalPct.toStringAsFixed(1)} %'),
            ],
          ),
          const SizedBox(height: 16),

          // Sección 3: Dimensión Socioambiental
          _DimensionSectionCard(
            title: 'Dimensión Socioambiental',
            score: zone.socialScore,
            icon: Icons.groups,
            color: const Color(0xFFE65100),
            items: [
              _MetricRow(
                  label: 'Aceptación Social',
                  value:
                      '${(zone.indiceAceptacionSocial * 100).toStringAsFixed(1)} %'),
              _MetricRow(
                  label: 'Conflictos Registrados (12m)',
                  value: '${zone.conflictos12m}'),
              _MetricRow(
                  label: 'Días de Paralización (12m)',
                  value: '${zone.diasParalizacion12m} días'),
              _MetricRow(
                  label: 'Comunidades de Influencia',
                  value: '${zone.comunidadesNum}'),
              _MetricRow(
                  label: 'Población en Influencia',
                  value: '${zone.poblacionInfluencia} hab.'),
            ],
          ),
          const SizedBox(height: 16),

          // Ficha Técnica de Concesión y Yacimiento
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 18, color: AppColors.primaryDark),
                      SizedBox(width: 8),
                      Text('Ficha de Concesión Minera',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MetricRow(
                      label: 'Código de Concesión', value: zone.concesionId),
                  _MetricRow(
                      label: 'Estado de Concesión',
                      value: zone.estadoConcesion),
                  _MetricRow(
                      label: 'Tipo de Yacimiento', value: zone.tipoYacimiento),
                  _MetricRow(
                      label: 'Altitud',
                      value: '${zone.altitudMsnm.toStringAsFixed(0)} msnm'),
                  _MetricRow(
                      label: 'Superficie Concesionada',
                      value: '${zone.superficieHa.toStringAsFixed(1)} Ha'),
                  _MetricRow(
                      label: 'Coordenadas GPS',
                      value:
                          '${zone.latitud.toStringAsFixed(4)}, ${zone.longitud.toStringAsFixed(4)}'),
                  _MetricRow(
                      label: 'Método de Evaluación',
                      value: zone.metodoEvaluacion),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Revisión Humana HITL & Decisión
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.coordinatorBorder, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_outlined,
                        size: 18, color: Color(0xFF1565C0)),
                    SizedBox(width: 8),
                    Text('Revisión Técnica del Especialista (HITL)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 10),
                _MetricRow(
                    label: 'Estado de Revisión', value: zone.estadoRevision),
                _MetricRow(
                    label: 'Especialista Asignado',
                    value: zone.revisorAsignado),
                _MetricRow(
                    label: 'Decisión Técnica',
                    value: zone.decisionEspecialista),
                if (zone.comentarioRevision.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Dictamen: "${zone.comentarioRevision}"',
                      style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  final String label;
  final String value;

  const _MetaInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

class _DimensionSectionCard extends StatelessWidget {
  final String title;
  final int score;
  final IconData icon;
  final Color color;
  final List<Widget> items;

  const _DimensionSectionCard({
    required this.title,
    required this.score,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '$score / 100',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (score / 100.0).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 14),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
