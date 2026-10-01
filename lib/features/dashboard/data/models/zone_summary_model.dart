// =============================================================
// features/dashboard/data/models/zone_summary_model.dart
// -------------------------------------------------------------
// Modelo de DATOS para ZoneSummary.
// =============================================================

import '../../domain/entities/zone_summary.dart';

class ZoneSummaryModel extends ZoneSummary {
  const ZoneSummaryModel({
    required super.code,
    required super.name,
    required super.region,
    required super.globalScore,
    required super.geoScore,
    required super.envScore,
    required super.socialScore,
    super.hasActiveInspection,
    super.departamento,
    super.provincia,
    super.distrito,
    super.mineral,
    super.empresa,
    super.fase,
    super.altitud,
    super.tipoYacimiento,
    super.superficieHa,
    super.estadoRevision,
    super.decisionEspecialista,
    super.comentarioRevision,
    super.totalEvaluaciones,
  });

  /// Construye el modelo a partir del JSON devuelto por SAP HANA Cloud.
  factory ZoneSummaryModel.fromJson(Map<String, dynamic> json) {
    return ZoneSummaryModel(
      code: json['ZoneCode'] as String? ?? '',
      name: json['ZoneName'] as String? ?? '',
      region: json['Region'] as String? ?? '',
      globalScore: (json['GlobalScore'] as num?)?.toInt() ?? 50,
      geoScore: (json['GeoScore'] as num?)?.toInt() ?? 50,
      envScore: (json['EnvScore'] as num?)?.toInt() ?? 50,
      socialScore: (json['SocialScore'] as num?)?.toInt() ?? 50,
      hasActiveInspection: json['HasActiveInspection'] as bool? ?? false,
      departamento: json['Departamento'] as String? ?? '',
      provincia: json['Provincia'] as String? ?? '',
      distrito: json['Distrito'] as String? ?? '',
      mineral: json['Mineral'] as String? ?? 'Cobre',
      empresa: json['Empresa'] as String? ?? 'Operadora Minera',
      fase: json['Fase'] as String? ?? 'Exploración',
      altitud: (json['Altitud'] as num?)?.toDouble() ?? 3500.0,
      tipoYacimiento: json['TipoYacimiento'] as String? ?? 'Pórfido',
      superficieHa: (json['SuperficieHa'] as num?)?.toDouble() ?? 1000.0,
      estadoRevision: json['EstadoRevision'] as String? ?? 'Revisada',
      decisionEspecialista: json['DecisionEspecialista'] as String? ?? 'Continuar monitoreo',
      comentarioRevision: json['ComentarioRevision'] as String? ?? '',
      totalEvaluaciones: (json['TotalEvaluaciones'] as num?)?.toInt() ?? 1,
    );
  }
}