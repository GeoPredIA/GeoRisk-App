// =============================================================
// features/multiagent_analysis/presentation/screens/multiagent_analysis_screen.dart
// -------------------------------------------------------------
// Pantalla de Analisis Multiagente con Trazabilidad - GeoPredIA.
//
// DISENO RENOVADO v2:
//   - Fondo propio claro (#F3F6F2) - NO transparente para legibilidad total.
//   - Header con gradiente verde institucional y score global prominente.
//   - Cards de especialista con sombras, borde de color segun nivel de riesgo.
//   - Tarjeta coordinador con gradiente premium y botones de accion claros.
//
// ESTRUCTURAS Y ALGORITMOS:
//   - Map<String,String> estatico para O(1) lookup de nombres de zonas.
//   - Ponderacion triangular Geo:Amb:Soc = 36%:34%:30%.
//   - Hash pseudoaleatorio por XOR con timestamp para trazabilidad.
// =============================================================

import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../app/navigation/app_nav_controller.dart';
import '../../../dashboard/data/services/mining_dataset_service.dart';
import '../../../review_approval/data/services/review_manager_service.dart';

// ---------------------------------------------------------------------------
// MODELOS DE DATOS
// ---------------------------------------------------------------------------

/// Datos de un especialista (geologico, ambiental, social).
class _SpecialistData {
  final int number;
  final String title;
  final String roleBadge;
  final IconData icon;
  final int score;
  final String narrative;
  final List<String> bulletPoints;
  final String evidenceCode;
  final String evidenceHash;
  final Map<String, String> detailedMetrics;
  final List<String> mitigationActions;

  const _SpecialistData({
    required this.number,
    required this.title,
    required this.roleBadge,
    required this.icon,
    required this.score,
    required this.narrative,
    required this.bulletPoints,
    required this.evidenceCode,
    required this.evidenceHash,
    required this.detailedMetrics,
    required this.mitigationActions,
  });
}

/// Reporte completo multiagente para una zona minera.
class _ZoneMultiagentReport {
  final String zoneCode;
  final String zoneName;
  final String region;
  final int globalScore;
  final String executionId;
  final String executionTimestamp;
  final String evaluationUuid;
  final _SpecialistData geological;
  final _SpecialistData environmental;
  final _SpecialistData social;
  final String coordinatorTitle;
  final String coordinatorNarrative;
  final List<String> coordinatorBullets;

  const _ZoneMultiagentReport({
    required this.zoneCode,
    required this.zoneName,
    required this.region,
    required this.globalScore,
    required this.executionId,
    required this.executionTimestamp,
    required this.evaluationUuid,
    required this.geological,
    required this.environmental,
    required this.social,
    required this.coordinatorTitle,
    required this.coordinatorNarrative,
    required this.coordinatorBullets,
  });
}

// ---------------------------------------------------------------------------
// WIDGET PRINCIPAL
// ---------------------------------------------------------------------------

class MultiagentAnalysisScreen extends StatefulWidget {
  const MultiagentAnalysisScreen({super.key});

  @override
  State<MultiagentAnalysisScreen> createState() =>
      _MultiagentAnalysisScreenState();
}

class _MultiagentAnalysisScreenState extends State<MultiagentAnalysisScreen> {
  String _selectedZoneCode = 'Z-001';

  // null=ninguno, 1/2/3=especialista individual, 99=todos expandidos
  int? _expandedAgentIndex;
  bool _isExecuting = false;
  String _currentExecutionHash = '6f09ea8f-6ae0-48ca-8461-8bf80c59b322';
  String _currentExecutionTimestamp = '27-set., 05:16 p.m.';

  // Historial LIFO (pila): insercion O(1) al frente
  final List<String> _executionHistory = [
    '27-set., 05:16 p.m. - Reglas - 6f09ea8f-6ae0-48ca-8461-8bf80c59b322',
    '26-set., 03:03 p.m. - Reglas - 1c9dd101-b50b-417e-952f-2f13ad9fbe50',
    '25-set., 10:45 a.m. - Reglas - 8fe15ff7-15a8-4a51-9f07-8cc5c53a4831',
  ];
  late String _selectedExecutionItem;

  // HashMap estatico: O(1) lookup por codigo de zona
  static const Map<String, String> _zoneNames = {
    'Z-001': 'Andes Norte (Cajamarca)',
    'Z-002': 'Cordillera Central (Junin)',
    'Z-003': 'Valle Sur (Arequipa)',
    'Z-004': 'Sierra Oriental (Cusco)',
    'Z-005': 'Cuenca Alta (Ancash)',
    'Z-006': 'Altiplano (Puno)',
  };

  @override
  void initState() {
    super.initState();
    _selectedExecutionItem = _executionHistory.first;
    _checkInitialZone();
  }

  void _checkInitialZone() {
    final svc = MiningDatasetService.instance;
    if (svc.isLoaded && svc.allZones.isNotEmpty) {
      _selectedZoneCode = svc.allZones.first.code;
    }
  }

  List<MapEntry<String, String>> _getZoneOptions() {
    final zones = MiningDatasetService.instance.allZones;
    if (zones.isNotEmpty) {
      return zones
          .map((zone) => MapEntry(
                zone.code,
                '${zone.name}\n${zone.distrito}, ${zone.provincia}, ${zone.region}',
              ))
          .toList();
    }
    return _zoneNames.entries.toList();
  }

  // ---------------------------------------------------------------------------
  // REPORTE: Algoritmo de ponderacion triangular Geo:Amb:Soc = 36:34:30
  // ---------------------------------------------------------------------------
  _ZoneMultiagentReport _getReportForZone(String zoneCode) {
    final record = MiningDatasetService.instance.getZoneByCode(zoneCode);
    final zoneName = record?.name ?? (_zoneNames[zoneCode] ?? 'Zona $zoneCode');
    final region = record != null
        ? '${record.region} - ${record.provincia}'
        : _getFallbackRegion(zoneCode);

    final geo = record?.geoScore ?? _getFallbackGeoScore(zoneCode);
    final env = record?.envScore ?? _getFallbackEnvScore(zoneCode);
    final soc = record?.socialScore ?? _getFallbackSocialScore(zoneCode);
    final global = record?.globalScore ??
        ((geo * 0.36) + (env * 0.34) + (soc * 0.30)).round();

    // Datos especificos de la maqueta para Z-001
    if (zoneCode == 'Z-001') {
      return _ZoneMultiagentReport(
        zoneCode: 'Z-001',
        zoneName: 'Andes Norte',
        region: 'Cajamarca',
        globalScore: 28,
        executionId: _currentExecutionHash,
        executionTimestamp: _currentExecutionTimestamp,
        evaluationUuid: '3146010b-4d6c-434a-863d-9842b1da24c5',
        geological: const _SpecialistData(
          number: 1,
          title: 'Especialista Geologico',
          roleBadge: 'Evidencia revisada',
          icon: Icons.terrain_outlined,
          score: 28,
          narrative:
              'Subindice geologico: 28/100. Nivel bajo segun umbrales operacionales. '
              '1 evidencia disponible. Incluye datos sinteticos, sin verificacion de campo.',
          bulletPoints: [
            'Validar evidencias sinteticas con datos de campo antes de cualquier decision real.',
            'Confirmar comportamiento de roca encajonante en sectores con pendientes sobre el 28%.',
          ],
          evidenceCode: 'Z-001-geological',
          evidenceHash: 'sha256:7c8b21...9f01a',
          detailedMetrics: {
            'Sismicidad regional': '4.2 / 10 (Moderado-bajo)',
            'Estabilidad de talud': '3.8 / 10 (Margen aceptable)',
            'Pendiente media': '28.4% (Relieve montanoso moderado)',
            'Distancia a falla activa': '14.8 km (Falla Chonta)',
            'Nivel freatico': '18.5 m (Profundidad segura)',
            'Potencial drenaje acido': 'pH 6.8 (Cerca de neutralidad)',
          },
          mitigationActions: [
            'Instalar 2 piezometros de cuerda vibrante en pie de talud.',
            'Mapeo estructural geomecanico 1:5,000 en cuadrangulo norte.',
          ],
        ),
        environmental: const _SpecialistData(
          number: 2,
          title: 'Especialista Ambiental',
          roleBadge: 'Evidencia revisada',
          icon: Icons.eco_outlined,
          score: 34,
          narrative: 'Subindice ambiental: 34/100. Nivel bajo. '
              'IoT: Temperatura 21.8 C, Humedad 44.8%, Temp. agua 18.6 C. '
              'Datos sinteticos; no mide pH, metales ni turbidez.',
          bulletPoints: [
            'Validar evidencias sinteticas con datos de campo.',
            'Monitorear variaciones estacionales en bofedales y rios tributarios.',
          ],
          evidenceCode: 'Z-001-environmental',
          evidenceHash: 'sha256:8fe15ff7-15a8-4a51-9f07',
          detailedMetrics: {
            'Estres hidrico de cuenca': '0.32 (Moderado - Estacion seca)',
            'Distancia a rios': '1.2 km (Rio Mashcon tributario)',
            'Cobertura vegetal': '42.0% (Pastizales andinos)',
            'Calidad aire PM10': '28.4 ug/m3 (Dentro de ECA)',
            'Telemetria IoT en vivo': 'DHT11: 21.8 C / 44.8% Hum',
            'Cobertura instrumental': 'Kit basico (Sin metales/turbidez)',
          },
          mitigationActions: [
            'Anadir sondas multiparametricas para turbidez y conductividad.',
            'Zanjas de coronacion con sedimentadores en plataformas.',
          ],
        ),
        social: const _SpecialistData(
          number: 3,
          title: 'Especialista Social',
          roleBadge: 'Evidencia revisada',
          icon: Icons.groups_outlined,
          score: 22,
          narrative: 'Subindice social: 22/100. Nivel bajo. '
              'Las mediciones IoT no permiten inferir aceptacion comunitaria '
              'ni sustituyen la consulta humana formal.',
          bulletPoints: [
            'La telemetria IoT no reemplaza el dialogo formal ni actas comunales.',
            'Mantener mesa de concertacion activa con dirigentes comunales.',
          ],
          evidenceCode: 'Z-001-social',
          evidenceHash: 'sha256:4a92c0...2b11e',
          detailedMetrics: {
            'Aceptacion comunitaria': '78.0% (Favorable con acuerdos activos)',
            'Conflictos en 12 meses': '0 eventos registrados',
            'Dias de paralisis previa': '0 dias',
            'Comunidades en area': '2 comunidades campesinas',
            'Poblacion en influencia': '1,420 habitantes aprox.',
            'Instrumento consulta': 'Convenio de servidumbre suscrito',
          },
          mitigationActions: [
            'Mesa de dialogo mensual con dirigentes comunales.',
            'Priorizar contratacion de mano de obra local en campo.',
          ],
        ),
        coordinatorTitle: 'La decision sigue en manos del equipo',
        coordinatorNarrative:
            'Los tres especialistas revisaron el escenario de demostracion. '
            'Las puntuaciones se conservaron sin recalcular. '
            'La decision y su justificacion corresponden al revisor humano.',
        coordinatorBullets: [
          'Validar evidencias sinteticas con datos de campo antes de decisiones reales.',
          'La telemetria incluye muestras sinteticas de demostracion.',
          'Completar o importar el calculo oficial desde SAP Analytics Cloud.',
        ],
      );
    }

    // Configuracion dinamica para cualquier otra zona del dataset
    return _ZoneMultiagentReport(
      zoneCode: zoneCode,
      zoneName: zoneName,
      region: region,
      globalScore: global,
      executionId: _currentExecutionHash,
      executionTimestamp: _currentExecutionTimestamp,
      evaluationUuid:
          'eval-${zoneCode.toLowerCase()}-${Random().nextInt(9000) + 1000}',
      geological: _SpecialistData(
        number: 1,
        title: 'Especialista Geologico',
        roleBadge: geo >= 70
            ? 'Alerta critica'
            : (geo >= 40 ? 'Riesgo moderado' : 'Evidencia revisada'),
        icon: Icons.terrain_outlined,
        score: geo,
        narrative:
            'Subindice geologico: $geo/100. Nivel ${geo >= 70 ? "alto" : (geo >= 40 ? "medio" : "bajo")}. '
            'Analisis sobre formaciones locales, lineamientos de falla y litologia competente.',
        bulletPoints: [
          'Validar fallas estructurales y estabilidad de taludes con testigos de perforacion.',
          if (geo >= 60)
            'Riesgo geomecanico alto: implementar monitoreo microsismico continuo.',
        ],
        evidenceCode: '$zoneCode-geological',
        evidenceHash: 'sha256:${zoneCode.hashCode.toRadixString(16)}00ae41',
        detailedMetrics: {
          'Sismicidad estimada': '${(geo * 0.09).toStringAsFixed(1)} / 10',
          'Estabilidad de talud':
              '${(10.0 - geo * 0.08).clamp(1.0, 9.5).toStringAsFixed(1)} / 10',
          'Pendiente promedio': '${(20.0 + geo * 0.35).toStringAsFixed(1)}%',
          'Distancia a falla':
              '${(25.0 - geo * 0.22).clamp(1.5, 30.0).toStringAsFixed(1)} km',
          'Nivel freatico': '${(12.0 + geo * 0.15).toStringAsFixed(1)} m',
          'Potencial drenaje':
              'pH ${(7.4 - geo * 0.03).clamp(3.5, 8.5).toStringAsFixed(1)}',
        },
        mitigationActions: [
          'Instalacion de prismas topograficos y radares SAR en taludes criticos.',
          'Mapeo geologico y ensayos de corte directo en discontinuidades.',
        ],
      ),
      environmental: _SpecialistData(
        number: 2,
        title: 'Especialista Ambiental',
        roleBadge: env >= 70
            ? 'Alerta hidrica'
            : (env >= 40 ? 'Seguimiento' : 'Evidencia revisada'),
        icon: Icons.eco_outlined,
        score: env,
        narrative:
            'Subindice ambiental: $env/100. Nivel ${env >= 70 ? "alto" : (env >= 40 ? "medio" : "bajo")}. '
            'Evalua redes hidrograficas, balance hidrico y telemetria IoT.',
        bulletPoints: [
          'Monitoreo de calidad de agua aguas abajo de plataformas.',
          if (env >= 60)
            'Estres hidrico detectado: restringir captacion en estiaje.',
        ],
        evidenceCode: '$zoneCode-environmental',
        evidenceHash: 'sha256:${zoneCode.hashCode.toRadixString(16)}8fe15a',
        detailedMetrics: {
          'Estres hidrico':
              (env * 0.01).clamp(0.1, 0.95).toStringAsFixed(2),
          'Distancia a rios':
              '${(15.0 - env * 0.14).clamp(0.5, 20.0).toStringAsFixed(1)} km',
          'Cobertura vegetal':
              '${(60.0 - env * 0.45).clamp(8.0, 75.0).toStringAsFixed(1)}%',
          'Material PM10': '${(20.0 + env * 0.6).toStringAsFixed(1)} ug/m3',
          'IoT Sentinel': 'Enlace activo con 4 nodos de campo',
          'Linea base agua': 'Parametros en rango referencial',
        },
        mitigationActions: [
          'Planes de contingencia para lodos de perforacion biodegradable.',
          'Muestreo trimestral certificado de metales en efluentes.',
        ],
      ),
      social: _SpecialistData(
        number: 3,
        title: 'Especialista Social',
        roleBadge: soc >= 70
            ? 'Alerta comunitaria'
            : (soc >= 40 ? 'Dialogo activo' : 'Evidencia revisada'),
        icon: Icons.groups_outlined,
        score: soc,
        narrative:
            'Subindice social: $soc/100. Nivel ${soc >= 70 ? "alto" : (soc >= 40 ? "medio" : "bajo")}. '
            'Refleja gobernanza comunitaria, acuerdos y percepcion de impacto hidrico.',
        bulletPoints: [
          'La telemetria IoT no reemplaza la consulta previa ni actas comunales.',
          if (soc >= 60)
            'Alta sensibilidad: priorizar comites de vigilancia participativa.',
        ],
        evidenceCode: '$zoneCode-social',
        evidenceHash: 'sha256:${zoneCode.hashCode.toRadixString(16)}soc91f',
        detailedMetrics: {
          'Aceptacion comunitaria':
              '${(100.0 - soc).clamp(10.0, 95.0).toStringAsFixed(1)}%',
          'Conflictos registrados': '${(soc / 25).floor()} eventos',
          'Dias de paralisis': '${soc > 50 ? (soc - 50) * 2 : 0} dias',
          'Comunidades en entorno':
              '${max(1, (soc / 18).floor() + 1)} comunidades',
          'Poblacion aprox.': '${max(800, soc * 95)} habitantes',
          'Mesa concertacion': 'Con mediacion de autoridades distritales',
        },
        mitigationActions: [
          'Monitoreo Ambiental Participativo con delegados locales.',
          'Fortalecer comunicacion radial en idioma materno.',
        ],
      ),
      coordinatorTitle: 'La decision sigue en manos del equipo',
      coordinatorNarrative:
          'Tres especialistas revisaron el escenario para $zoneName ($zoneCode). '
          'Las ponderaciones fueron integradas con trazabilidad completa. '
          'La decision final corresponde al ingeniero revisor.',
      coordinatorBullets: [
        'Validar evidencias con datos de campo antes de iniciar obras civiles.',
        'La telemetria complementa las observaciones cuantitativas de los especialistas.',
        'Calculo vinculante sujeto a validacion en Revision Humana (HITL).',
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FALLBACKS para zonas sin datos en el dataset local
  // ---------------------------------------------------------------------------
  String _getFallbackRegion(String code) {
    const r = {
      'Z-001': 'Cajamarca',
      'Z-002': 'Junin',
      'Z-003': 'Arequipa',
      'Z-004': 'Cusco',
      'Z-005': 'Ancash',
      'Z-006': 'Puno',
    };
    return r[code] ?? 'Peru';
  }

  int _getFallbackGeoScore(String code) {
    const s = {
      'Z-001': 28,
      'Z-002': 72,
      'Z-003': 43,
      'Z-004': 36,
      'Z-005': 55,
      'Z-006': 24
    };
    return s[code] ?? 35;
  }

  int _getFallbackEnvScore(String code) {
    const s = {
      'Z-001': 34,
      'Z-002': 64,
      'Z-003': 78,
      'Z-004': 41,
      'Z-005': 52,
      'Z-006': 26
    };
    return s[code] ?? 40;
  }

  int _getFallbackSocialScore(String code) {
    const s = {
      'Z-001': 22,
      'Z-002': 58,
      'Z-003': 46,
      'Z-004': 81,
      'Z-005': 39,
      'Z-006': 31
    };
    return s[code] ?? 30;
  }

  // ---------------------------------------------------------------------------
  // LOGICA: Ejecucion de analisis y envio a HITL
  // ---------------------------------------------------------------------------

  void _runAnalysisExecution() {
    setState(() => _isExecuting = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      // Hash pseudoaleatorio por XOR con timestamp para trazabilidad
      final rng = Random();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final p1 = (ts ^ rng.nextInt(0xFFFF)).toRadixString(16).padLeft(8, '0');
      final p2 = rng.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0');
      final newHash =
          '$p1-$p2-48ca-8461-${rng.nextInt(0xFFFFFF).toRadixString(16)}';

      final now = DateTime.now();
      final pm = now.hour >= 12 ? 'p.m.' : 'a.m.';
      final h12 =
          now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
      final fmt =
          '${now.day}-set., ${h12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $pm';

      setState(() {
        _isExecuting = false;
        _currentExecutionHash = newHash;
        _currentExecutionTimestamp = fmt;
        _executionHistory.insert(0, '$fmt - Reglas - $newHash'); // O(1)
        _selectedExecutionItem = _executionHistory.first;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analisis actualizado para $_selectedZoneCode',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.primaryDark,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  void _sendToHumanReview(_ZoneMultiagentReport report) {
    final task = ReviewTaskItem(
      id: 'REV-${DateTime.now().microsecondsSinceEpoch}',
      zoneCode: report.zoneCode,
      zoneName: report.zoneName,
      origin: 'Multiagentes',
      status: 'Pendiente',
      globalScore: report.globalScore,
      geoScore: report.geological.score,
      envScore: report.environmental.score,
      socialScore: report.social.score,
      date: _currentExecutionTimestamp,
      summary: 'Dictamen integrado de 3 especialistas para ${report.zoneName}. '
          'Requiere dictamen humano vinculante.',
      reviewer: 'Ing. Alejandro Samir',
    );

    ReviewManagerService.instance.addTask(task);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enviado a Revision Humana',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(
              'Zona: ${report.zoneName}  |  Global: ${report.globalScore}/100',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        action: SnackBarAction(
          label: 'IR AHORA',
          textColor: const Color(0xFF7FFFD4),
          onPressed: () => AppNavController.goToTab(3),
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD PRINCIPAL
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final zoneOptions = _getZoneOptions();
    final selectedZoneCode =
        zoneOptions.any((zone) => zone.key == _selectedZoneCode)
            ? _selectedZoneCode
            : zoneOptions.first.key;
    final report = _getReportForZone(selectedZoneCode);

    return Scaffold(
      // Fondo claro propio - NO transparente para maxima legibilidad sobre el
      // fondo topografico de la app. Las cards tienen color blanco explicito.
      backgroundColor: const Color(0xFFF3F6F2),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text(
          'Multiagentes',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Re-ejecutar analisis',
            icon: _isExecuting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isExecuting ? null : _runAnalysisExecution,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(report),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDemoBanner(),
                const SizedBox(height: 14),
                _buildZoneSelector(),
                const SizedBox(height: 12),
                _buildContextNote(),
                const SizedBox(height: 14),
                _buildExecutionHistory(report),
                const SizedBox(height: 20),
                _buildSpecialistsHeader(),
                const SizedBox(height: 10),
                _buildSpecialistCard(
                  specialist: report.geological,
                  isExpanded:
                      _expandedAgentIndex == 1 || _expandedAgentIndex == 99,
                  onTap: () => setState(() {
                    _expandedAgentIndex = (_expandedAgentIndex == 1) ? null : 1;
                  }),
                ),
                const SizedBox(height: 10),
                _buildSpecialistCard(
                  specialist: report.environmental,
                  isExpanded:
                      _expandedAgentIndex == 2 || _expandedAgentIndex == 99,
                  onTap: () => setState(() {
                    _expandedAgentIndex = (_expandedAgentIndex == 2) ? null : 2;
                  }),
                ),
                const SizedBox(height: 10),
                _buildSpecialistCard(
                  specialist: report.social,
                  isExpanded:
                      _expandedAgentIndex == 3 || _expandedAgentIndex == 99,
                  onTap: () => setState(() {
                    _expandedAgentIndex = (_expandedAgentIndex == 3) ? null : 3;
                  }),
                ),
                const SizedBox(height: 20),
                _buildCoordinatorCard(report),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER - Gradiente verde institucional con score global
  // ---------------------------------------------------------------------------

  Widget _buildHeader(_ZoneMultiagentReport report) {
    final isHigh = report.globalScore >= 70;
    final isMedium = report.globalScore >= 40;
    final scoreColor = isHigh
        ? const Color(0xFFFF7043)
        : (isMedium ? const Color(0xFFFFB300) : const Color(0xFF69F0AE));
    final riskLabel =
        isHigh ? 'RIESGO ALTO' : (isMedium ? 'RIESGO MEDIO' : 'RIESGO BAJO');

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A2D22), Color(0xFF1A5940)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ANALISIS CON TRAZABILIDAD',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9EC9B2),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tres perspectivas.',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const Text(
            'Una revision fundamentada.',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: Color(0xFFB8D9C8),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Score global prominente
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score Global',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.65),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${report.globalScore}/100',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        riskLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${report.zoneName} - ${report.region}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Ejecutado: ${report.executionTimestamp}',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.55)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BANNER DE DEMOSTRACION
  // ---------------------------------------------------------------------------

  Widget _buildDemoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7E7),
        border: Border.all(color: const Color(0xFFEEDBB8)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Modo demostracion local - Los datos son ilustrativos. '
        'Las evaluaciones importadas conservan los valores del CSV. '
        'Las integraciones externas requieren configuracion adicional.',
        style: TextStyle(fontSize: 11.5, height: 1.4, color: Color(0xFF7A5822)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SELECTOR DE ZONA + BOTON EJECUTAR
  // ---------------------------------------------------------------------------

  Widget _buildZoneSelector() {
    final zoneOptions = _getZoneOptions();
    final selectedZoneCode =
        zoneOptions.any((zone) => zone.key == _selectedZoneCode)
            ? _selectedZoneCode
            : zoneOptions.first.key;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: Color(0xFF0E3B2E)),
              SizedBox(width: 6),
              Text(
                'Zona de analisis',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B3128)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCDD6C9)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                itemHeight: null,
                menuMaxHeight: 420,
                value: selectedZoneCode,
                icon:
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF285444)),
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B3128)),
                items: zoneOptions.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(
                      '${e.key} - ${e.value}',
                      softWrap: true,
                    ),
                  );
                }).toList(),
                onChanged: (newCode) {
                  if (newCode != null && newCode != _selectedZoneCode) {
                    setState(() {
                      _selectedZoneCode = newCode;
                      _expandedAgentIndex = null;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Agentes por reglas - Inferencia trazable',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7F76)),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E3B2E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                ),
                onPressed: _isExecuting ? null : _runAnalysisExecution,
                icon: _isExecuting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 17),
                label: Text(
                  _isExecuting ? 'Analizando...' : 'Ejecutar',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NOTA DE CONTEXTO SAP
  // ---------------------------------------------------------------------------

  Widget _buildContextNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2EB),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
            left: BorderSide(color: Color(0xFF1E604C), width: 3.5)),
      ),
      child: const Text(
        'Los agentes explican los resultados y senalan vacios. '
        'El calculo oficial corresponde a SAP Analytics Cloud '
        'y la decision final a una persona.',
        style: TextStyle(
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: Color(0xFF234437)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HISTORIAL DE EJECUCION
  // ---------------------------------------------------------------------------

  Widget _buildExecutionHistory(_ZoneMultiagentReport report) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, size: 14, color: Color(0xFF4C6157)),
              SizedBox(width: 5),
              Text(
                'Ejecucion registrada',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C6157)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8F5),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: const Color(0xFFD3DCD0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                itemHeight: null,
                menuMaxHeight: 320,
                value: _selectedExecutionItem,
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                style:
                    const TextStyle(fontSize: 11.5, color: Color(0xFF22352D)),
                items: _executionHistory.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, softWrap: true),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedExecutionItem = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ID: ${report.evaluationUuid}',
            style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF8A9D93),
                fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CABECERA DE ESPECIALISTAS
  // ---------------------------------------------------------------------------

  Widget _buildSpecialistsHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Especialistas asignados',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
                color: Color(0xFF13251E)),
          ),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          onPressed: () {
            setState(() {
              _expandedAgentIndex = _expandedAgentIndex == 99 ? null : 99;
            });
          },
          icon: Icon(
            _expandedAgentIndex == 99
                ? Icons.unfold_less_rounded
                : Icons.unfold_more_rounded,
            size: 16,
            color: const Color(0xFF1B5945),
          ),
          label: Text(
            _expandedAgentIndex == 99 ? 'Ver resumen' : 'Ver detalle',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5945)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TARJETA DE ESPECIALISTA - Diseno renovado con sombra y colores de riesgo
  // ---------------------------------------------------------------------------

  Widget _buildSpecialistCard({
    required _SpecialistData specialist,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    final numText = specialist.number.toString().padLeft(2, '0');
    final isHigh = specialist.score >= 70;
    final isMedium = specialist.score >= 40 && specialist.score < 70;

    final scoreColor = isHigh
        ? const Color(0xFFD32F2F)
        : (isMedium ? const Color(0xFFE65100) : const Color(0xFF2E7D32));
    final headerBg = isHigh
        ? const Color(0xFFFFF8F8)
        : (isMedium ? const Color(0xFFFFFBF5) : const Color(0xFFF5FAF6));
    final borderColor = isExpanded
        ? const Color(0xFF1B5945)
        : (isHigh
            ? const Color(0xFFFFCDD2)
            : (isMedium ? const Color(0xFFFFE0B2) : const Color(0xFFC8E6C9)));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isExpanded ? 1.8 : 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // Cabecera clickeable
          InkWell(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    numText,
                    style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w200,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF9EB5A8),
                        height: 1.0),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          specialist.title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF142921)),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(specialist.icon, size: 13, color: scoreColor),
                            const SizedBox(width: 4),
                            Text(
                              specialist.roleBadge,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: scoreColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Score badge grande
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: scoreColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${specialist.score}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: scoreColor,
                          height: 1.0),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra de progreso de riesgo
          ClipRRect(
            child: LinearProgressIndicator(
              value: (specialist.score / 100).clamp(0.05, 1.0),
              minHeight: 4,
              backgroundColor: const Color(0xFFECF0EB),
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ),

          // Cuerpo de la card
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialist.narrative,
                  style: const TextStyle(
                      fontSize: 12.5, height: 1.5, color: Color(0xFF2E4138)),
                ),
                const SizedBox(height: 10),

                for (final bullet in specialist.bulletPoints)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                              color: scoreColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            bullet,
                            style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF3A5045)),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),
                // Pie: evidencia + toggle
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Evidencia: ${specialist.evidenceCode}',
                        style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF7A8D85),
                            fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isExpanded ? 'Ocultar' : 'Ver todo',
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5945)),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18,
                            color: const Color(0xFF1B5945),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Detalle expandido
                if (isExpanded) ...[
                  const SizedBox(height: 14),
                  const Divider(thickness: 0.8, color: Color(0xFFE0E8DE)),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.bar_chart_rounded,
                          size: 15, color: Color(0xFF1B5945)),
                      SizedBox(width: 5),
                      Text(
                        'Metricas en observacion',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5945)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE1EAE0)),
                    ),
                    child: Column(
                      children: [
                        for (final e in specialist.detailedMetrics.entries) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF3B5247)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    e.value,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF192A22)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (e.key != specialist.detailedMetrics.keys.last)
                            const Divider(
                                height: 1,
                                thickness: 0.6,
                                color: Color(0xFFE6EDE4)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Acciones de mitigacion recomendadas:',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A2F)),
                  ),
                  const SizedBox(height: 6),
                  for (final act in specialist.mitigationActions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 15, color: Color(0xFF287955)),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              act,
                              style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: Color(0xFF2D4439)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4EE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security_outlined,
                            size: 14, color: Color(0xFF5B7167)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            specialist.evidenceHash,
                            style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: Color(0xFF4C6157)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TARJETA COORDINADOR - Gradiente y botones HITL
  // ---------------------------------------------------------------------------

  Widget _buildCoordinatorCard(_ZoneMultiagentReport report) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF4EC), Color(0xFFE6F0E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCDE0C9), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3B2E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_tree_outlined,
                    size: 18, color: Color(0xFF0E3B2E)),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COORDINADOR',
                    style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Color(0xFF496456)),
                  ),
                  Text(
                    'Sintesis para revision',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF3A5347),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            report.coordinatorTitle,
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
                color: Color(0xFF12281F)),
          ),
          const SizedBox(height: 8),
          Text(
            report.coordinatorNarrative,
            style: const TextStyle(
                fontSize: 13, height: 1.5, color: Color(0xFF2F463B)),
          ),
          const SizedBox(height: 12),
          for (final bullet in report.coordinatorBullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                        color: Color(0xFF1E604C), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: Color(0xFF3A5346)),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          const Divider(thickness: 0.8, color: Color(0xFFC4D9BF)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side:
                        const BorderSide(color: Color(0xFF0E3B2E), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () => AppNavController.goToTab(3),
                  icon: const Icon(Icons.open_in_new_rounded,
                      size: 16, color: Color(0xFF0E3B2E)),
                  label: const Text(
                    'Ir a revision',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0E3B2E)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E3B2E),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () => _sendToHumanReview(report),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text(
                    'Enviar a HITL',
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
