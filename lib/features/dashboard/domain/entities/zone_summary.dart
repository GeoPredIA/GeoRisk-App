// =============================================================
// features/dashboard/domain/entities/zone_summary.dart
// -------------------------------------------------------------
// Entidad de DOMINIO para cada zona de exploración minera.
// =============================================================

class ZoneSummary {
  final String code;            // "QN-402" o "Z0001"
  final String name;            // "Quellaveco Norte"
  final String region;          // "Moquegua · Cuadrángulo 34-u"
  final int globalScore;        // 74
  final int geoScore;           // 72  (Geológico)
  final int envScore;           // 68  (Ambiental)
  final int socialScore;        // 78  (Social)
  final bool hasActiveInspection; // true -> muestra tag "Inspección Activa"

  // Metadatos de exploración minera del dataset
  final String departamento;
  final String provincia;
  final String distrito;
  final String mineral;
  final String empresa;
  final String fase;
  final double altitud;
  final String tipoYacimiento;
  final double superficieHa;
  final String estadoRevision;
  final String decisionEspecialista;
  final String comentarioRevision;
  final int totalEvaluaciones;

  const ZoneSummary({
    required this.code,
    required this.name,
    required this.region,
    required this.globalScore,
    required this.geoScore,
    required this.envScore,
    required this.socialScore,
    this.hasActiveInspection = false,
    this.departamento = '',
    this.provincia = '',
    this.distrito = '',
    this.mineral = 'Cobre',
    this.empresa = 'Operadora Minera',
    this.fase = 'Exploración',
    this.altitud = 3500.0,
    this.tipoYacimiento = 'Pórfido',
    this.superficieHa = 1000.0,
    this.estadoRevision = 'Revisada',
    this.decisionEspecialista = 'Continuar monitoreo',
    this.comentarioRevision = '',
    this.totalEvaluaciones = 1,
  });
}