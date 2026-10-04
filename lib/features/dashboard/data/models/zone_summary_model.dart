// =============================================================
// features/dashboard/data/models/zone_summary_model.dart
// -------------------------------------------------------------
// Modelo de DATOS para ZoneSummary.
// =============================================================

import '../../domain/entities/zone_summary.dart';
import '../services/mining_dataset_service.dart';

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
      decisionEspecialista:
          json['DecisionEspecialista'] as String? ?? 'Continuar monitoreo',
      comentarioRevision: json['ComentarioRevision'] as String? ?? '',
      totalEvaluaciones: (json['TotalEvaluaciones'] as num?)?.toInt() ?? 1,
    );
  }

  /// Traduce la respuesta del backend GeoPredIA desplegado en SAP BTP.
  factory ZoneSummaryModel.fromGeoPrediaApi(
    Map<String, dynamic> json, {
    MiningZoneRecord? localRecord,
  }) {
    final evaluation = json['latest_evaluation'] is Map
        ? Map<String, dynamic>.from(json['latest_evaluation'] as Map)
        : <String, dynamic>{};
    final subindices = evaluation['subindices'] is Map
        ? Map<String, dynamic>.from(evaluation['subindices'] as Map)
        : <String, dynamic>{};
    int score(dynamic value) => value is num ? value.round() : 0;

    return ZoneSummaryModel(
      code: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      region: localRecord == null
          ? json['region']?.toString() ?? ''
          : '${localRecord.region} · ${localRecord.provincia} · ${localRecord.distrito}',
      globalScore: score(evaluation['global_risk']),
      geoScore: score(subindices['geological']),
      envScore: score(subindices['environmental']),
      socialScore: score(subindices['social']),
      hasActiveInspection:
          evaluation['review_status']?.toString().toLowerCase() == 'pending' ||
              localRecord?.estadoRevision.toLowerCase().contains('revision') ==
                  true ||
              localRecord?.estadoRevision.toLowerCase().contains('observada') ==
                  true ||
              localRecord?.metodoEvaluacion.toLowerCase().contains('campo') ==
                  true,
      departamento: localRecord?.region ?? json['region']?.toString() ?? '',
      provincia: localRecord?.provincia ?? '',
      distrito: localRecord?.distrito ?? '',
      mineral: localRecord?.mineralPrincipal ?? 'Cobre',
      empresa: localRecord?.empresaOperadora ?? 'Operadora Minera',
      fase: localRecord?.faseExploracion ?? 'Exploración',
      altitud: localRecord?.altitudMsnm ?? 3500.0,
      tipoYacimiento: localRecord?.tipoYacimiento ?? 'Pórfido',
      superficieHa: localRecord?.superficieHa ?? 1000.0,
      estadoRevision: evaluation['review_status']?.toString() ?? 'Pendiente',
      decisionEspecialista:
          localRecord?.decisionEspecialista ?? 'Continuar monitoreo',
      comentarioRevision: localRecord?.comentarioRevision ?? '',
      totalEvaluaciones: (json['record_count'] as num?)?.toInt() ??
          (evaluation.isEmpty ? 0 : 1),
    );
  }
}
