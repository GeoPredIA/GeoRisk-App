// =============================================================
// features/dashboard/data/services/mining_dataset_service.dart
// -------------------------------------------------------------
// Servicio singleton para cargar, indexar y filtrar el dataset
// de exploraciones mineras (11,458 registros / 140 zonas únicas).
// =============================================================

import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/zone_summary.dart';

class MiningZoneRecord {
  final String code;
  final String name;
  final String region;
  final String provincia;
  final String distrito;
  final double latitud;
  final double longitud;
  final double altitudMsnm;
  final double superficieHa;
  final String tipoYacimiento;
  final String mineralPrincipal;
  final String concesionId;
  final String estadoConcesion;
  final String empresaOperadora;
  final String faseExploracion;
  final String metodoEvaluacion;

  // Metricas geologicas
  final double sismicidadIndice;
  final double distanciaFallaKm;
  final double estabilidadTaludScore;
  final double pendientePromedioPct;
  final double nivelFreaticoM;
  final double potencialDrenajePh;

  // Metricas ambientales
  final double distanciaCuerpoAguaKm;
  final double indiceEstresHidrico;
  final double coberturaVegetalPct;
  final double calidadAirePm10;

  // Metricas sociales
  final double indiceAceptacionSocial;
  final int conflictos12m;
  final int diasParalizacion12m;
  final int comunidadesNum;
  final int poblacionInfluencia;

  // Revision humana HITL
  final String estadoRevision;
  final String revisorAsignado;
  final String decisionEspecialista;
  final String comentarioRevision;
  final String fechaEvaluacion;

  // Puntajes calculados (0-100)
  final int geoScore;
  final int envScore;
  final int socialScore;
  final int globalScore;
  final int totalEvaluations;

  const MiningZoneRecord({
    required this.code,
    required this.name,
    required this.region,
    required this.provincia,
    required this.distrito,
    required this.latitud,
    required this.longitud,
    required this.altitudMsnm,
    required this.superficieHa,
    required this.tipoYacimiento,
    required this.mineralPrincipal,
    required this.concesionId,
    required this.estadoConcesion,
    required this.empresaOperadora,
    required this.faseExploracion,
    required this.metodoEvaluacion,
    required this.sismicidadIndice,
    required this.distanciaFallaKm,
    required this.estabilidadTaludScore,
    required this.pendientePromedioPct,
    required this.nivelFreaticoM,
    required this.potencialDrenajePh,
    required this.distanciaCuerpoAguaKm,
    required this.indiceEstresHidrico,
    required this.coberturaVegetalPct,
    required this.calidadAirePm10,
    required this.indiceAceptacionSocial,
    required this.conflictos12m,
    required this.diasParalizacion12m,
    required this.comunidadesNum,
    required this.poblacionInfluencia,
    required this.estadoRevision,
    required this.revisorAsignado,
    required this.decisionEspecialista,
    required this.comentarioRevision,
    required this.fechaEvaluacion,
    required this.geoScore,
    required this.envScore,
    required this.socialScore,
    required this.globalScore,
    required this.totalEvaluations,
  });

  ZoneSummary toZoneSummary() {
    return ZoneSummary(
      code: code,
      name: name,
      region: '$region · $provincia · $distrito',
      globalScore: globalScore,
      geoScore: geoScore,
      envScore: envScore,
      socialScore: socialScore,
      hasActiveInspection: estadoRevision.toLowerCase().contains('revision') ||
          estadoRevision.toLowerCase().contains('observada') ||
          metodoEvaluacion.toLowerCase().contains('campo'),
      departamento: region,
      provincia: provincia,
      distrito: distrito,
      mineral: mineralPrincipal,
      empresa: empresaOperadora,
      fase: faseExploracion,
      altitud: altitudMsnm,
      tipoYacimiento: tipoYacimiento,
      superficieHa: superficieHa,
      estadoRevision: estadoRevision,
      decisionEspecialista: decisionEspecialista,
      comentarioRevision: comentarioRevision,
      totalEvaluaciones: totalEvaluations,
    );
  }
}

class MiningDatasetService {
  MiningDatasetService._();
  static final MiningDatasetService instance = MiningDatasetService._();

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  final Map<String, MiningZoneRecord> _zonesMap = {};
  final List<MiningZoneRecord> _allZones = [];

  final Set<String> _regions = {};
  final Map<String, Set<String>> _provincesByRegion = {};
  final Map<String, Set<String>> _districtsByProvince = {};

  List<MiningZoneRecord> get allZones => List.unmodifiable(_allZones);
  List<String> get regions => _regions.toList()..sort();

  List<String> getProvinces(String? region) {
    if (region == null || region.isEmpty || region == 'Todas') {
      final allProv = <String>{};
      for (final pSet in _provincesByRegion.values) {
        allProv.addAll(pSet);
      }
      return allProv.toList()..sort();
    }
    return (_provincesByRegion[region]?.toList() ?? [])..sort();
  }

  List<String> getDistricts(String? region, String? province) {
    if (province == null || province.isEmpty || province == 'Todas') {
      final allDist = <String>{};
      for (final dSet in _districtsByProvince.values) {
        allDist.addAll(dSet);
      }
      return allDist.toList()..sort();
    }
    final key = '${region ?? ""}|$province';
    return (_districtsByProvince[key]?.toList() ??
        _districtsByProvince[province]?.toList() ??
        [])..sort();
  }

  MiningZoneRecord? getZoneByCode(String code) {
    return _zonesMap[code];
  }

  Future<void> init() async {
    if (_isLoaded) return;

    try {
      String rawCsv = '';
      try {
        rawCsv = await rootBundle.loadString('assets/data/zonas.csv');
      } catch (_) {
        rawCsv = await rootBundle.loadString('assets/data/dataset_tema2_georisk(in).csv');
      }

      final lines = rawCsv.split(RegExp(r'\r?\n'));
      if (lines.isEmpty) return;

      final countPerZone = <String, int>{};
      final latestRowPerZone = <String, List<String>>{};

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final parts = line.split(',');
        if (parts.length < 50) continue;

        final zoneId = parts[1].trim();
        countPerZone[zoneId] = (countPerZone[zoneId] ?? 0) + 1;
        latestRowPerZone[zoneId] = parts;
      }

      _zonesMap.clear();
      _allZones.clear();
      _regions.clear();
      _provincesByRegion.clear();
      _districtsByProvince.clear();

      for (final entry in latestRowPerZone.entries) {
        final zoneId = entry.key;
        final p = entry.value;

        final totalEvals = countPerZone[zoneId] ?? 1;
        final name = p[2].trim();
        final reg = p[3].trim();
        final prov = p[4].trim();
        final dist = p[5].trim();
        final lat = double.tryParse(p[6]) ?? 0.0;
        final lng = double.tryParse(p[7]) ?? 0.0;
        final alt = double.tryParse(p[8]) ?? 0.0;
        final sup = double.tryParse(p[9]) ?? 0.0;
        final yac = p[10].trim();
        final mineral = p[11].trim();
        final concesion = p[12].trim();
        final estConcesion = p[13].trim();
        final empresa = p[14].trim();
        final fase = p[19].trim();
        final fecha = p[23].trim();
        final metodo = p[25].trim();

        // Indicadores geologicos
        final sism = double.tryParse(p[26]) ?? 5.0;
        final distFalla = double.tryParse(p[27]) ?? 10.0;
        final talud = double.tryParse(p[28]) ?? 2.5;
        final pend = double.tryParse(p[29]) ?? 30.0;
        final freatico = double.tryParse(p[30]) ?? 20.0;
        final ph = double.tryParse(p[32]) ?? 5.0;

        // Indicadores ambientales
        final distAgua = double.tryParse(p[35]) ?? 15.0;
        final estresAgua = double.tryParse(p[36]) ?? 0.3;
        final veg = double.tryParse(p[37]) ?? 25.0;
        final pm10 = double.tryParse(p[38]) ?? 40.0;

        // Indicadores sociales
        final comNum = int.tryParse(p[43]) ?? 3;
        final poblacion = int.tryParse(p[44]) ?? 5000;
        final conf12m = int.tryParse(p[46]) ?? 0;
        final diasParal = int.tryParse(p[47]) ?? 0;
        final aceptSoc = double.tryParse(p[48]) ?? 0.5;

        // Revision
        final estRev = p.length > 56 ? p[56].trim() : 'Pendiente';
        final revisor = p.length > 57 ? p[57].trim() : 'D. Vargas';
        final decision = p.length > 58 ? p[58].trim() : 'En monitoreo';
        final coment = p.length > 60 ? p[60].trim() : '';

        // Calculo de Score 0-100
        final geoRiskCalc = ((sism * 8.5) + ((10.0 - talud.clamp(0.0, 10.0)) * 7.5) + (pend * 0.4)).clamp(15.0, 95.0).round();
        final envRiskCalc = ((estresAgua * 80.0) + (pm10 * 0.5) + ((100.0 - veg) * 0.3)).clamp(15.0, 95.0).round();
        final socRiskCalc = (((1.0 - aceptSoc.clamp(0.0, 1.0)) * 75.0) + (conf12m * 6.0) + (diasParal * 0.8)).clamp(15.0, 98.0).round();
        final globalRiskCalc = ((geoRiskCalc * 0.36) + (envRiskCalc * 0.34) + (socRiskCalc * 0.30)).round().clamp(10, 99);

        final record = MiningZoneRecord(
          code: zoneId,
          name: name,
          region: reg,
          provincia: prov,
          distrito: dist,
          latitud: lat,
          longitud: lng,
          altitudMsnm: alt,
          superficieHa: sup,
          tipoYacimiento: yac,
          mineralPrincipal: mineral,
          concesionId: concesion,
          estadoConcesion: estConcesion,
          empresaOperadora: empresa,
          faseExploracion: fase,
          metodoEvaluacion: metodo,
          sismicidadIndice: sism,
          distanciaFallaKm: distFalla,
          estabilidadTaludScore: talud,
          pendientePromedioPct: pend,
          nivelFreaticoM: freatico,
          potencialDrenajePh: ph,
          distanciaCuerpoAguaKm: distAgua,
          indiceEstresHidrico: estresAgua,
          coberturaVegetalPct: veg,
          calidadAirePm10: pm10,
          indiceAceptacionSocial: aceptSoc,
          conflictos12m: conf12m,
          diasParalizacion12m: diasParal,
          comunidadesNum: comNum,
          poblacionInfluencia: poblacion,
          estadoRevision: estRev.isEmpty ? 'Pendiente' : estRev,
          revisorAsignado: revisor,
          decisionEspecialista: decision,
          comentarioRevision: coment,
          fechaEvaluacion: fecha,
          geoScore: geoRiskCalc,
          envScore: envRiskCalc,
          socialScore: socRiskCalc,
          globalScore: globalRiskCalc,
          totalEvaluations: totalEvals,
        );

        _zonesMap[zoneId] = record;
        _allZones.add(record);

        _regions.add(reg);
        _provincesByRegion.putIfAbsent(reg, () => <String>{}).add(prov);
        _districtsByProvince.putIfAbsent('$reg|$prov', () => <String>{}).add(dist);
        _districtsByProvince.putIfAbsent(prov, () => <String>{}).add(dist);
      }

      _isLoaded = true;
    } catch (e) {
      // Ignora silenciosamente
    }
  }

  List<MiningZoneRecord> filter({
    String? region,
    String? province,
    String? district,
    String? riskLevel,
    String? searchQuery,
  }) {
    return _allZones.where((zone) {
      final matchesRegion = region == null || region.isEmpty || region == 'Todas' || zone.region == region;
      final matchesProv = province == null || province.isEmpty || province == 'Todas' || zone.provincia == province;
      final matchesDist = district == null || district.isEmpty || district == 'Todos' || zone.distrito == district;

      final level = zone.globalScore >= 70 ? 'ALTO' : (zone.globalScore >= 40 ? 'MEDIO' : 'BAJO');
      final matchesLevel = riskLevel == null || riskLevel.isEmpty || riskLevel == 'TODOS' || level == riskLevel;

      final query = (searchQuery ?? '').trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          zone.name.toLowerCase().contains(query) ||
          zone.code.toLowerCase().contains(query) ||
          zone.region.toLowerCase().contains(query) ||
          zone.provincia.toLowerCase().contains(query) ||
          zone.distrito.toLowerCase().contains(query) ||
          zone.mineralPrincipal.toLowerCase().contains(query) ||
          zone.empresaOperadora.toLowerCase().contains(query);

      return matchesRegion && matchesProv && matchesDist && matchesLevel && matchesSearch;
    }).toList();
  }
}