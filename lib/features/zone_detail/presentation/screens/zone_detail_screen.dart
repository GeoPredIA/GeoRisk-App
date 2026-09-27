// =============================================================
// features/zone_detail/presentation/screens/zone_detail_screen.dart
// -------------------------------------------------------------
// PLACEHOLDER de la pantalla "Detalle: Quellaveco Norte" (Imagen 3).
// Recibe el código de zona desde AppRoutes.goToZoneDetail().
//
// SIGUIENTE PASO para completar este feature (sigue el mismo
// patrón que dashboard/):
//   1. domain/entities/zone_detail.dart -> geoScore, envScore,
//      socialScore, hallazgo textual, lista de evidencias.
//   2. domain/usecases/get_zone_detail.dart
//   3. data/models + data/datasources/zone_detail_remote_datasource.dart
//      (llama a SAP HANA Cloud: GET /Zones/{code})
//   4. presentation/providers/zone_detail_provider.dart
//   5. Reemplazar el body de abajo por el diseño real con
//      RiskDimensionBar (barras Geológico/Ambiental/Social) y
//      el botón "Ver análisis multiagente ->" que navega a
//      multiagent_analysis_screen.dart
// =============================================================

import 'package:flutter/material.dart';

class ZoneDetailScreen extends StatelessWidget {
  final String zoneCode;

  const ZoneDetailScreen({super.key, required this.zoneCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle: $zoneCode')),
      body: Center(
        child: Text('Pantalla de detalle para la zona $zoneCode\n(pendiente de implementar)'),
      ),
    );
  }
}
