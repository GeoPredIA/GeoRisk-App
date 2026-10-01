// =============================================================
// features/iot_sentinel/presentation/screens/iot_sentinel_screen.dart
// -------------------------------------------------------------
// Pantalla oficial de Monitoreo IoT (Telemetría de campo).
// Conectada en tiempo real a las zonas mineras y a Revisión Humana.
// =============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/data/services/mining_dataset_service.dart';
import '../../../review_approval/data/services/review_manager_service.dart';
import '../../../../app/navigation/app_nav_controller.dart';

class IotSentinelScreen extends StatefulWidget {
  const IotSentinelScreen({super.key});

  @override
  State<IotSentinelScreen> createState() => _IotSentinelScreenState();
}

class _IotSentinelScreenState extends State<IotSentinelScreen> {
  String _selectedZoneCode = 'Z-001';
  String _selectedZoneName = 'Z-001 · Andes Norte';

  // Valores de telemetría simulados dinámicamente
  double _tempAire = 21.8;
  double _humAire = 44.8;
  double _humSuelo = 25.9;
  double _tempAgua = 18.6;
  String _lastTimestamp = '26-set., 03:10 p. m.';

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadInitialZone();
  }

  void _loadInitialZone() {
    if (MiningDatasetService.instance.isLoaded &&
        MiningDatasetService.instance.allZones.isNotEmpty) {
      final first = MiningDatasetService.instance.allZones.first;
      _selectedZoneCode = first.code;
      _selectedZoneName = '${first.code} · ${first.name}';
    }
  }

  void _simulateReading() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'p. m.' : 'a. m.';

    setState(() {
      _tempAire =
          double.parse((18.0 + _random.nextDouble() * 9.0).toStringAsFixed(1));
      _humAire =
          double.parse((38.0 + _random.nextDouble() * 25.0).toStringAsFixed(1));
      _humSuelo =
          double.parse((18.0 + _random.nextDouble() * 22.0).toStringAsFixed(1));
      _tempAgua =
          double.parse((14.0 + _random.nextDouble() * 8.0).toStringAsFixed(1));
      _lastTimestamp = '${now.day}-set., $hour:$min $ampm';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nueva telemetría recibida para $_selectedZoneName'),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendToReview({required String zoneCode, required String zoneName}) {
    final newId =
        'REV-IOT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final task = ReviewTaskItem(
      id: newId,
      zoneCode: zoneCode,
      zoneName: zoneName,
      origin: 'Monitoreo IoT',
      status: 'Pendiente',
      globalScore: _tempAire > 25.0 || _humSuelo > 30.0 ? 72 : 45,
      geoScore: 50,
      envScore: _tempAgua > 20.0 ? 78 : 55,
      socialScore: 40,
      date: _lastTimestamp,
      summary:
          'Telemetría de campo: Temp Aire $_tempAire°C, Hum Aire $_humAire%, Hum Suelo $_humSuelo%, Temp Agua $_tempAgua°C.',
      reviewer: 'Ing. Alejandro Samir',
    );

    ReviewManagerService.instance.addTask(task);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Telemetría enviada a Revisión HITL',
          softWrap: true,
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Ver bandeja',
          textColor: Colors.greenAccent,
          onPressed: () => AppNavController.goToTab(3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zones = MiningDatasetService.instance.allZones;
    final screenWidth = MediaQuery.sizeOf(context).width;
    MiningZoneRecord? selectedZone;
    for (final zone in zones) {
      if (zone.code == _selectedZoneCode) {
        selectedZone = zone;
        break;
      }
    }
    selectedZone ??= zones.isNotEmpty ? zones.first : null;
    final selectedZoneCode = selectedZone?.code ?? _selectedZoneCode;
    final selectedZoneName = selectedZone == null
        ? _selectedZoneName
        : '${selectedZone.code} · ${selectedZone.name}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Monitoreo IoT',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Ir a Revisión Humana',
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () => AppNavController.goToTab(3),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Título principal con estilo oficial
          const Text(
            'Monitoreo ambiental',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const Text(
            'directamente desde campo.',
            style: TextStyle(
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Los sensores registran temperatura y humedad para detectar cambios en las condiciones ambientales de cada zona.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Barra de selección de zona + botón de lectura simulada
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              final zoneDropdown = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    itemHeight: null,
                    menuMaxHeight: 420,
                    value: selectedZoneCode,
                    items: zones.isEmpty
                        ? [
                            const DropdownMenuItem(
                              value: 'Z-001',
                              child: Text('Z-001 · Andes Norte'),
                            ),
                          ]
                        : zones
                            .map(
                              (zone) => DropdownMenuItem(
                                value: zone.code,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    '${zone.code} · ${zone.name}',
                                    softWrap: true,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    selectedItemBuilder: (context) => zones.isEmpty
                        ? [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Z-001 · Andes Norte'),
                            ),
                          ]
                        : zones
                            .map(
                              (zone) => Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${zone.code} · ${zone.name}',
                                  softWrap: true,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: zones.isEmpty
                        ? null
                        : (value) {
                            if (value == null) return;
                            final match = zones.firstWhere(
                              (zone) => zone.code == value,
                            );
                            setState(() {
                              _selectedZoneCode = value;
                              _selectedZoneName =
                                  '${match.code} · ${match.name}';
                            });
                          },
                  ),
                ),
              );
              final readingButton = ElevatedButton.icon(
                onPressed: _simulateReading,
                icon: const Icon(Icons.sensors, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                label: const Text(
                  'Generar lectura simulada',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              );

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4ED),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Zona seleccionada',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          zoneDropdown,
                          const SizedBox(height: 8),
                          readingButton,
                        ],
                      )
                    : Row(
                        children: [
                          const Text(
                            'Zona seleccionada',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: zoneDropdown),
                          const SizedBox(width: 10),
                          readingButton,
                        ],
                      ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Las 4 Cards de Métricas Principales (Grid 2x2)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: screenWidth < 600 ? 0.95 : 1.35,
            children: [
              _SensorKpiCard(
                title: 'Temperatura del aire',
                value: '$_tempAire °C',
                sensor: 'DHT11',
                time: 'Simulador · $_lastTimestamp',
                color: const Color(0xFFE65100),
              ),
              _SensorKpiCard(
                title: 'Humedad del aire',
                value: '$_humAire %',
                sensor: 'DHT11',
                time: 'Simulador · $_lastTimestamp',
                color: const Color(0xFF0288D1),
              ),
              _SensorKpiCard(
                title: 'Humedad del suelo',
                value: '$_humSuelo %',
                sensor: 'Índice relativo calibrado',
                time: 'Simulador · $_lastTimestamp',
                color: const Color(0xFF689F38),
              ),
              _SensorKpiCard(
                title: 'Temperatura del agua',
                value: '$_tempAgua °C',
                sensor: 'DS18B20',
                time: 'Simulador · $_lastTimestamp',
                color: const Color(0xFF0097A7),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Card Izquierda: Registro de Mediciones (Últimas observaciones)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REGISTRO DE MEDICIONES',
                    style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Últimas observaciones',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lectura simulada · $_lastTimestamp',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Temperatura del aire: $_tempAire °C · Humedad del aire: $_humAire % · Humedad del suelo: $_humSuelo % · Temperatura del agua: $_tempAgua °C',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Zona: $_selectedZoneCode · simulator-ui',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _sendToReview(
                        zoneCode: selectedZoneCode,
                        zoneName: selectedZoneName,
                      ),
                      icon: const Icon(Icons.send_rounded,
                          size: 14, color: AppColors.primaryDark),
                      label: const Text(
                        'Enviar telemetría a Revisión Humana HITL',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryDark),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Card Derecha: Variables Observadas (Tabla de Sensores)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VARIABLES OBSERVADAS',
                    style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Señales ambientales para complementar la evaluación.',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  const _SensorTableRow(
                      label: 'Temperatura del aire', sensor: 'DHT11'),
                  const Divider(height: 14),
                  const _SensorTableRow(
                      label: 'Humedad relativa del aire', sensor: 'DHT11'),
                  const Divider(height: 14),
                  const _SensorTableRow(
                      label: 'Humedad relativa del suelo',
                      sensor: 'Sensor capacitivo'),
                  const Divider(height: 14),
                  const _SensorTableRow(
                      label: 'Temperatura del agua', sensor: 'DS18B20'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SensorKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String sensor;
  final String time;
  final Color color;

  const _SensorKpiCard({
    required this.title,
    required this.value,
    required this.sensor,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sensor,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                Text(time,
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorTableRow extends StatelessWidget {
  final String label;
  final String sensor;

  const _SensorTableRow({required this.label, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            softWrap: true,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            sensor,
            textAlign: TextAlign.right,
            softWrap: true,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
