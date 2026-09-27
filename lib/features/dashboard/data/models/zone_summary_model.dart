// =============================================================
// features/dashboard/data/models/zone_summary_model.dart
// -------------------------------------------------------------
// Modelo de DATOS: sabe cómo leer el JSON exacto que devuelve
// SAP HANA Cloud (vía OData) y convertirlo en la entidad de
// dominio ZoneSummary. Es la ÚNICA capa que conoce los nombres
// de campo tal como los expone la API real.
//
// Ajusta los nombres de fromJson() cuando conectes el endpoint
// real de HANA Cloud (los nombres de campo OData pueden diferir).
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
  });

  /// Construye el modelo a partir del JSON devuelto por SAP HANA Cloud.
  factory ZoneSummaryModel.fromJson(Map<String, dynamic> json) {
    return ZoneSummaryModel(
      code: json['ZoneCode'] as String,
      name: json['ZoneName'] as String,
      region: json['Region'] as String,
      globalScore: (json['GlobalScore'] as num).toInt(),
      geoScore: (json['GeoScore'] as num).toInt(),
      envScore: (json['EnvScore'] as num).toInt(),
      socialScore: (json['SocialScore'] as num).toInt(),
      hasActiveInspection: json['HasActiveInspection'] as bool? ?? false,
    );
  }
}
