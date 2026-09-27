// =============================================================
// features/iot_sentinel/presentation/screens/iot_sentinel_screen.dart
// -------------------------------------------------------------
// PLACEHOLDER de la pestaña "IoT Sentinel" (Imágenes 7 y 8):
// telemetría en vivo de sensores (humedad, caudal, microclima)
// y alertas activas.
//
// SIGUIENTE PASO (mismo patrón que dashboard/):
//   1. domain/entities/sensor_reading.dart y telemetry_alert.dart
//   2. data/datasources/iot_telemetry_datasource.dart
//      (idealmente un Stream, ya que son datos en vivo vía
//      MQTT/LoRaWAN -> SAP HANA Cloud)
//   3. presentation/widgets/telemetry_line_chart.dart
//      (usa un paquete como fl_chart para el gráfico de
//      "Evolución Dinámica: Humedad del Suelo")
// =============================================================

import 'package:flutter/material.dart';

class IotSentinelScreen extends StatelessWidget {
  const IotSentinelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IoT Sentinel')),
      body: const Center(
        child: Text('Telemetría en vivo (Red LoRaWAN)\n(pendiente de implementar)',
            textAlign: TextAlign.center),
      ),
    );
  }
}
