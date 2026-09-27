// =============================================================
// features/dashboard/domain/entities/zone_summary.dart
// -------------------------------------------------------------
// Entidad de DOMINIO: el objeto "limpio" con el que trabaja la
// UI del Panorama. No sabe nada de JSON ni de SAP — eso es
// responsabilidad de la capa data/models.
//
// Corresponde a cada card de la lista "Zonas bajo evaluación"
// (Imagen 2 de tus mockups): "Quellaveco Norte · ALTO 74/100 ...".
// =============================================================

class ZoneSummary {
  final String code;            // "QN-402"
  final String name;            // "Quellaveco Norte"
  final String region;          // "Moquegua · Cuadrángulo 34-u"
  final int globalScore;        // 74
  final int geoScore;           // 72  (Geológico)
  final int envScore;           // 68  (Ambiental)
  final int socialScore;        // 78  (Social)
  final bool hasActiveInspection; // true -> muestra tag "Inspección Activa"

  const ZoneSummary({
    required this.code,
    required this.name,
    required this.region,
    required this.globalScore,
    required this.geoScore,
    required this.envScore,
    required this.socialScore,
    this.hasActiveInspection = false,
  });
}
