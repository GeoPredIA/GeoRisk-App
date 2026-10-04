import '../../../dashboard/data/services/mining_dataset_service.dart';
import '../../../../core/constants/sap_endpoints.dart';
import '../../../../core/network/sap_api_client.dart';

class JouleAnswer {
  final String text;
  final String topic;
  final List<String> sources;

  const JouleAnswer({
    required this.text,
    required this.topic,
    required this.sources,
  });
}

class JouleDataAssistant {
  JouleDataAssistant() : _apiClient = SapApiClient();

  final SapApiClient _apiClient;

  Future<JouleAnswer> answer(String prompt) async {
    final zones = MiningDatasetService.instance.allZones;
    if (zones.isNotEmpty) {
      final query = _normalize(prompt);
      final selected = _findZone(query, zones) ?? zones.first;
      try {
        final response = await _apiClient.post(
          SapEndpoints.jouleBaseUrl,
          body: {'zone_id': selected.code, 'question': prompt},
        );
        final remoteText = response['answer']?.toString();
        if (remoteText != null && remoteText.isNotEmpty) {
          final facts = response['facts'] is List
              ? (response['facts'] as List).map((item) => item.toString()).toList()
              : <String>[];
          return JouleAnswer(
            topic: response['joule_deployed'] == true
                ? 'SAP Joule · GeoPredIA'
                : 'Acción Joule preparada · BTP',
            text: [remoteText, if (facts.isNotEmpty) facts.join('\n')].join('\n\n'),
            sources: const ['API GeoPredIA en SAP BTP'],
          );
        }
      } catch (_) {
        // Conserva el asistente local para la demo si no hay conectividad.
      }
    }
    return _answerLocal(prompt);
  }

  JouleAnswer _answerLocal(String prompt) {
    final dataset = MiningDatasetService.instance;
    final zones = dataset.allZones;
    final query = _normalize(prompt);

    if (zones.isEmpty) {
      return const JouleAnswer(
        topic: 'Datos locales',
        text:
            'Todavía se está cargando el dataset. Espera un momento y vuelve a preguntar.',
        sources: ['Carga local'],
      );
    }

    if (_containsAny(query,
        const ['hola', 'buenos dias', 'buenas tardes', 'buenas noches'])) {
      return JouleAnswer(
        topic: 'GeoPredIA · ${zones.length} zonas',
        text:
            '¡Hola! Puedo consultar cualquiera de las ${zones.length} zonas del dataset, explicar sus puntajes geológico, ambiental y social, revisar sus variables o comparar zonas. Puedes preguntar con el nombre o código, por ejemplo: “¿Qué riesgo tiene ${zones.first.name}?”',
        sources: ['Dataset local GeoPredIA'],
      );
    }

    if (_containsAny(query, const [
      'que puedes hacer',
      'como puedes ayudar',
      'ayuda',
      'capacidades'
    ])) {
      return const JouleAnswer(
        topic: 'Consultas disponibles',
        text:
            'Puedo buscar cualquier zona por nombre, código, departamento o provincia; explicar sus puntajes y variables; revisar su dictamen HITL; resumir el portafolio y ordenar las zonas de mayor o menor riesgo. Si preguntas algo que no aparece en el dataset, te lo indicaré en lugar de inventar datos.',
        sources: ['Dataset local GeoPredIA'],
      );
    }

    if (_containsAny(
        query, const ['comparar', 'compara', 'diferencia entre'])) {
      final mentionedZones = _findMentionedZones(query, zones);
      if (mentionedZones.length >= 2) {
        return _compareZones(mentionedZones.take(3).toList());
      }
    }

    final zone = _findZone(query, zones);
    if (zone != null) return _answerForZone(query, zone);

    if (_containsAny(query, [
      'mayor riesgo',
      'mas alto',
      'mas critica',
      'criticas',
      'peor riesgo'
    ])) {
      final highest = [...zones]
        ..sort((a, b) => b.globalScore.compareTo(a.globalScore));
      return _rankedAnswer('Zonas con mayor riesgo', highest.take(5).toList());
    }

    if (_containsAny(
        query, ['menor riesgo', 'mas bajo', 'menos riesgo', 'mas segura'])) {
      final lowest = [...zones]
        ..sort((a, b) => a.globalScore.compareTo(b.globalScore));
      return _rankedAnswer('Zonas con menor riesgo', lowest.take(5).toList());
    }

    if (_containsAny(query, [
      'cuantas zonas',
      'total de zonas',
      'resumen',
      'panorama general',
      'portafolio',
      'promedio'
    ])) {
      return _portfolioSummary(zones);
    }

    if (_containsAny(query, const [
      'que significa el puntaje',
      'como interpreto el riesgo',
      'interpretar el score',
      'escala de riesgo'
    ])) {
      return const JouleAnswer(
        topic: 'Cómo interpretar los puntajes',
        text:
            'Los puntajes de GeoPredIA van de 0 a 100 y representan nivel de riesgo, no probabilidad de accidente: 0–39 bajo, 40–69 moderado y 70–100 alto. El global combina las dimensiones geológica, ambiental y social. Úsalos para priorizar revisión; no sustituyen una evaluación profesional ni un dictamen HITL.',
        sources: ['Metodología de puntajes local'],
      );
    }

    return _openQuestionAnswer(query, zones);
  }

  JouleAnswer _answerForZone(String query, MiningZoneRecord zone) {
    final identity = '${zone.name} (${zone.code})';
    final commonSource = [
      'Dataset local · ${zone.code}',
      if (zone.fechaEvaluacion.isNotEmpty) 'Registro ${zone.fechaEvaluacion}',
    ];

    if (_containsAny(query, [
      'revision',
      'dictamen',
      'revisor',
      'aprobada',
      'observada',
      'rechazada'
    ])) {
      final comment = zone.comentarioRevision.trim();
      return JouleAnswer(
        topic: 'Revisión humana · ${zone.code}',
        text:
            'La revisión de $identity figura como “${zone.estadoRevision}”. Dictamen: “${zone.decisionEspecialista}”. Revisor asignado: ${zone.revisorAsignado}.${comment.isEmpty ? '' : ' Comentario registrado: “$comment”.'}',
        sources: [...commonSource, 'Campos de revisión HITL'],
      );
    }

    if (_containsAny(query, [
      'social',
      'comunidad',
      'comunidades',
      'aceptacion',
      'conflicto',
      'paralizacion',
      'poblacion'
    ])) {
      return JouleAnswer(
        topic: 'Dimensión social · ${zone.code}',
        text:
            'En $identity, el puntaje de riesgo social es ${zone.socialScore}/100 (${_riskLabel(zone.socialScore)}). El índice de aceptación registrado es ${(zone.indiceAceptacionSocial * 100).toStringAsFixed(1)}%; hay ${zone.conflictos12m} conflictos y ${zone.diasParalizacion12m} días de paralización en los últimos 12 meses. El área registra ${zone.comunidadesNum} comunidades y una población de influencia de ${zone.poblacionInfluencia}.',
        sources: [...commonSource, 'Variables sociales'],
      );
    }

    if (_containsAny(query, [
      'ambiental',
      'ambiente',
      'agua',
      'hidrico',
      'hidrica',
      'aire',
      'pm10',
      'vegetacion',
      'vegetal',
      'ambientales'
    ])) {
      return JouleAnswer(
        topic: 'Dimensión ambiental · ${zone.code}',
        text:
            'En $identity, el puntaje de riesgo ambiental es ${zone.envScore}/100 (${_riskLabel(zone.envScore)}). El índice de estrés hídrico es ${(zone.indiceEstresHidrico * 100).toStringAsFixed(1)}%, la distancia al cuerpo de agua es ${zone.distanciaCuerpoAguaKm.toStringAsFixed(1)} km, PM10 es ${zone.calidadAirePm10.toStringAsFixed(1)} µg/m³ y la cobertura vegetal es ${zone.coberturaVegetalPct.toStringAsFixed(1)}%.',
        sources: [...commonSource, 'Variables ambientales'],
      );
    }

    if (_containsAny(query, [
      'geologico',
      'geologica',
      'sismicidad',
      'falla',
      'talud',
      'pendiente',
      'freatico',
      'acido',
      'geotecnic'
    ])) {
      return JouleAnswer(
        topic: 'Dimensión geológica · ${zone.code}',
        text:
            'En $identity, el puntaje de riesgo geológico es ${zone.geoScore}/100 (${_riskLabel(zone.geoScore)}). La sismicidad es ${zone.sismicidadIndice.toStringAsFixed(2)}/10, la estabilidad de talud ${zone.estabilidadTaludScore.toStringAsFixed(2)}/10, la distancia a falla ${zone.distanciaFallaKm.toStringAsFixed(1)} km, la pendiente ${zone.pendientePromedioPct.toStringAsFixed(1)}% y el nivel freático ${zone.nivelFreaticoM.toStringAsFixed(1)} m.',
        sources: [...commonSource, 'Variables geológicas'],
      );
    }

    if (_containsAny(query, [
      'empresa',
      'operadora',
      'mineral',
      'concesion',
      'fase',
      'ubicacion',
      'donde',
      'distrito',
      'provincia',
      'departamento'
    ])) {
      return JouleAnswer(
        topic: 'Ficha de zona · ${zone.code}',
        text:
            '$identity se ubica en ${zone.distrito}, ${zone.provincia}, ${zone.region}. La empresa operadora es ${zone.empresaOperadora}; el mineral principal es ${zone.mineralPrincipal}, la fase es ${zone.faseExploracion} y la concesión ${zone.concesionId} figura como ${zone.estadoConcesion}.',
        sources: [...commonSource, 'Ficha de concesión'],
      );
    }

    return JouleAnswer(
      topic: 'Resumen de zona · ${zone.code}',
      text:
          '$identity registra un riesgo global de ${zone.globalScore}/100 (${_riskLabel(zone.globalScore)}), compuesto por riesgo geológico ${zone.geoScore}, ambiental ${zone.envScore} y social ${zone.socialScore}. El dataset agrupa ${zone.totalEvaluations} evaluaciones para esta zona. La decisión registrada por revisión humana es “${zone.decisionEspecialista}”. ¿Qué dimensión quieres explorar con más detalle?',
      sources: [...commonSource, 'Puntajes Geo · Amb · Soc', 'Revisión HITL'],
    );
  }

  JouleAnswer _portfolioSummary(List<MiningZoneRecord> zones) {
    final totalRisk = zones.fold<int>(0, (sum, zone) => sum + zone.globalScore);
    final averageRisk = totalRisk / zones.length;
    final highRisk = zones.where((zone) => zone.globalScore >= 70).length;
    final pending = zones.where((zone) {
      final status = _normalize(zone.estadoRevision);
      return status.contains('pendiente') || status.contains('observada');
    }).length;
    final highest = [...zones]
      ..sort((a, b) => b.globalScore.compareTo(a.globalScore));

    return JouleAnswer(
      topic: 'Resumen del portafolio',
      text:
          'El dataset contiene ${zones.length} zonas únicas. El riesgo global promedio es ${averageRisk.toStringAsFixed(1)}/100; ${_riskLabel(averageRisk.round())}. $highRisk zonas tienen puntaje alto (70 o más) y $pending aparecen pendientes u observadas en revisión. La zona con mayor puntaje actual es ${highest.first.name} (${highest.first.code}), con ${highest.first.globalScore}/100.',
      sources: const [
        'Dataset local GeoPredIA',
        'Puntajes de riesgo',
        'Estado HITL'
      ],
    );
  }

  JouleAnswer _rankedAnswer(String topic, List<MiningZoneRecord> zones) {
    final lines = zones.map((zone) {
      return '• ${zone.name} (${zone.code}) · ${zone.globalScore}/100 · ${zone.region}';
    }).join('\n');
    return JouleAnswer(
      topic: topic,
      text: 'Según el puntaje global del dataset:\n$lines',
      sources: const ['Dataset local GeoPredIA', 'Puntajes globales'],
    );
  }

  List<MiningZoneRecord> _findMentionedZones(
    String query,
    List<MiningZoneRecord> zones,
  ) {
    return zones.where((zone) {
      final code = _normalize(zone.code);
      final name = _normalize(zone.name);
      return (code.isNotEmpty &&
              RegExp(r'\b' + RegExp.escape(code) + r'\b').hasMatch(query)) ||
          (name.length > 4 && query.contains(name));
    }).toList();
  }

  JouleAnswer _compareZones(List<MiningZoneRecord> zones) {
    final rows = zones.map((zone) {
      return '${zone.name} (${zone.code}): riesgo global ${zone.globalScore}/100 '
          '(${_riskLabel(zone.globalScore)}); geológico ${zone.geoScore}, '
          'ambiental ${zone.envScore}, social ${zone.socialScore}.';
    }).join('\n');
    return JouleAnswer(
      topic: 'Comparación de zonas',
      text:
          '$rows\nLos valores comparan los registros disponibles; revisa la fecha y el estado HITL antes de tomar decisiones.',
      sources: const ['Dataset local GeoPredIA', 'Puntajes Geo · Amb · Soc'],
    );
  }

  JouleAnswer _rankedDimensionAnswer(
    String topic,
    List<MiningZoneRecord> zones,
    int Function(MiningZoneRecord) scoreOf,
  ) {
    final rows = zones.take(5).map((zone) {
      return '• ${zone.name} (${zone.code}): ${scoreOf(zone)}/100';
    }).join('\n');
    return JouleAnswer(
      topic: topic,
      text:
          'Zonas con los puntajes más altos en esta dimensión:\n$rows\nUn valor alto indica más riesgo y requiere revisar la evidencia de la zona.',
      sources: const ['Dataset local GeoPredIA', 'Puntajes por dimensión'],
    );
  }

  JouleAnswer _openQuestionAnswer(String query, List<MiningZoneRecord> zones) {
    if (_containsAny(query, const ['social', 'comunitario', 'comunidades'])) {
      final ranked = [...zones]
        ..sort((a, b) => b.socialScore.compareTo(a.socialScore));
      return _rankedDimensionAnswer(
        'Riesgo social por zona',
        ranked,
        (zone) => zone.socialScore,
      );
    }
    if (_containsAny(
        query, const ['ambiental', 'ambiente', 'hidrico', 'agua'])) {
      final ranked = [...zones]
        ..sort((a, b) => b.envScore.compareTo(a.envScore));
      return _rankedDimensionAnswer(
        'Riesgo ambiental por zona',
        ranked,
        (zone) => zone.envScore,
      );
    }
    if (_containsAny(query, const ['geologico', 'geotecnic', 'sismicidad'])) {
      final ranked = [...zones]
        ..sort((a, b) => b.geoScore.compareTo(a.geoScore));
      return _rankedDimensionAnswer(
        'Riesgo geológico por zona',
        ranked,
        (zone) => zone.geoScore,
      );
    }
    if (_containsAny(query, const [
      'mitigar',
      'mitigacion',
      'reducir el riesgo',
      'recomendacion'
    ])) {
      final highest = [...zones]
        ..sort((a, b) => b.globalScore.compareTo(a.globalScore));
      final focus = highest.take(3).map((zone) {
        return '${zone.name} (${zone.code}), con riesgo ${zone.globalScore}/100';
      }).join('; ');
      return JouleAnswer(
        topic: 'Orientación general · mitigación',
        text:
            'Como orientación general, prioriza verificar la evidencia de campo, revisar por separado los riesgos geológicos, ambientales y sociales, y asignar medidas con responsables y fechas. En el dataset, los casos que conviene revisar primero son: $focus. Las medidas concretas deben validarse con especialistas y con la comunidad; el sistema no reemplaza ese proceso.',
        sources: const [
          'Dataset local GeoPredIA',
          'Revisión humana recomendada'
        ],
      );
    }

    final ranked = [...zones]
      ..sort((a, b) => b.globalScore.compareTo(a.globalScore));
    final averageRisk =
        zones.fold<int>(0, (sum, zone) => sum + zone.globalScore) /
            zones.length;

    return JouleAnswer(
      topic: 'Análisis abierto',
      text:
          'Sobre “$query”: puedo contrastar tu pregunta con el dataset local de ${zones.length} zonas. El riesgo global promedio registrado es ${averageRisk.toStringAsFixed(1)}/100; ${ranked.first.name} (${ranked.first.code}) tiene el puntaje mayor (${ranked.first.globalScore}/100).\n\nNo tengo una fuente local para afirmar datos externos o eventos en tiempo real. Si me indicas una zona, tema o criterio, relaciono la respuesta con sus variables y te digo qué datos respaldan la conclusión.',
      sources: const ['Dataset local GeoPredIA', 'Resumen de riesgo'],
    );
  }

  MiningZoneRecord? _findZone(
    String query,
    List<MiningZoneRecord> zones,
  ) {
    for (final zone in zones) {
      final code = _normalize(zone.code);
      if (code.isNotEmpty &&
          RegExp(r'\b' + RegExp.escape(code) + r'\b').hasMatch(query)) {
        return zone;
      }

      final name = _normalize(zone.name);
      if (name.length > 4 && query.contains(name)) return zone;
      final company = _normalize(zone.empresaOperadora);
      if (company.length > 5 && query.contains(company)) return zone;
    }

    const ignored = {
      'zona',
      'riesgo',
      'global',
      'analiza',
      'analizar',
      'explica',
      'explicar',
      'dime',
      'quiero',
      'sobre',
      'tiene',
      'tienen',
      'esta',
      'estan',
      'para',
      'como',
      'cual',
      'cuales',
      'nivel',
      'puntaje',
      'score',
      'datos',
    };
    final terms = query
        .split(' ')
        .where((term) => term.length >= 4 && !ignored.contains(term))
        .toSet();
    if (terms.isEmpty) return null;

    MiningZoneRecord? best;
    var bestScore = 0;
    var tied = false;
    for (final zone in zones) {
      final nameTerms = _normalize(zone.name).split(' ').toSet();
      final locationTerms =
          _normalize('${zone.region} ${zone.provincia} ${zone.distrito}')
              .split(' ')
              .toSet();
      final otherTerms =
          _normalize('${zone.empresaOperadora} ${zone.mineralPrincipal}')
              .split(' ')
              .toSet();
      final score = terms.intersection(nameTerms).length * 3 +
          terms.intersection(locationTerms).length * 2 +
          terms.intersection(otherTerms).length;
      if (score > bestScore) {
        best = zone;
        bestScore = score;
        tied = false;
      } else if (score != 0 && score == bestScore) {
        tied = true;
      }
    }
    return bestScore >= 2 && !tied ? best : null;
  }

  bool _containsAny(String text, List<String> phrases) =>
      phrases.any((phrase) => text.contains(_normalize(phrase)));

  String _riskLabel(int score) =>
      score >= 70 ? 'alto' : (score >= 40 ? 'moderado' : 'bajo');

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâ]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöô]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}
