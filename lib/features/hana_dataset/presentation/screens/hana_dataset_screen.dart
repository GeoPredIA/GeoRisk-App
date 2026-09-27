import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_footer.dart';

class HanaDatasetScreen extends StatefulWidget {
  const HanaDatasetScreen({super.key});

  @override
  State<HanaDatasetScreen> createState() => _HanaDatasetScreenState();
}

class _HanaDatasetScreenState extends State<HanaDatasetScreen> {
  int _selectedTableIndex = 0;

  final List<Map<String, dynamic>> _hanaTables = [
    {
      'name': 'GEOPREDIA.ZONES_SPATIAL',
      'title': 'Zonas de Exploración y Polígonos',
      'records': '12 registros',
      'odataEndpoint': '/odata/v4/GeoRiskService/ZonesSpatial',
      'description': 'Entidad espacial principal con geometrías ST_POLYGON (SRID 4326), coordenadas UTM y cuencas.',
      'columns': [
        {'col': 'ZONE_CODE', 'type': 'NVARCHAR(16)', 'pk': true},
        {'col': 'NAME', 'type': 'NVARCHAR(128)', 'pk': false},
        {'col': 'DEPARTMENT', 'type': 'NVARCHAR(64)', 'pk': false},
        {'col': 'DEPOSIT_TYPE', 'type': 'NVARCHAR(64)', 'pk': false},
        {'col': 'GEO_SHAPE', 'type': 'ST_GEOMETRY(4326)', 'pk': false},
        {'col': 'UPDATED_AT', 'type': 'TIMESTAMP', 'pk': false},
      ],
    },
    {
      'name': 'GEOPREDIA.IOT_TELEMETRY',
      'title': 'Telemetría Sensorial en Vivo',
      'records': '1,420 mediciones',
      'odataEndpoint': '/odata/v4/GeoRiskService/SensorTelemetry',
      'description': 'Series temporales de humedad, piezómetros, turbidez hídrica y estaciones meteorológicas vía MQTT/LoRaWAN.',
      'columns': [
        {'col': 'TELEMETRY_ID', 'type': 'BIGINT', 'pk': true},
        {'col': 'ZONE_CODE', 'type': 'NVARCHAR(16)', 'pk': false},
        {'col': 'SENSOR_ID', 'type': 'NVARCHAR(32)', 'pk': false},
        {'col': 'METRIC_NAME', 'type': 'NVARCHAR(64)', 'pk': false},
        {'col': 'VALUE', 'type': 'DECIMAL(10,3)', 'pk': false},
        {'col': 'TIMESTAMP', 'type': 'TIMESTAMP', 'pk': false},
      ],
    },
    {
      'name': 'GEOPREDIA.HITL_AUDIT_LOGS',
      'title': 'Auditoría HITL y Dictámenes',
      'records': '64 dictámenes',
      'odataEndpoint': '/odata/v4/GeoRiskService/HitlAuditLogs',
      'description': 'Registro inmutable de revisiones humanas con hash SHA-256 de aprobación en SAP Build Process Automation.',
      'columns': [
        {'col': 'AUDIT_ID', 'type': 'NVARCHAR(36)', 'pk': true},
        {'col': 'ZONE_CODE', 'type': 'NVARCHAR(16)', 'pk': false},
        {'col': 'GATE_LEVEL', 'type': 'NVARCHAR(16)', 'pk': false},
        {'col': 'DECISION', 'type': 'NVARCHAR(32)', 'pk': false},
        {'col': 'REVIEWER_EMAIL', 'type': 'NVARCHAR(128)', 'pk': false},
        {'col': 'SIGNATURE_HASH', 'type': 'VARCHAR(64)', 'pk': false},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeTable = _hanaTables[_selectedTableIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.storage, color: AppColors.primaryDark),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dataset HANA Cloud',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Esquemas Espaciales & Endpoints OData v4',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.primaryDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cloud_done, color: Colors.greenAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'SAP HANA Cloud · Instancia BTP Activa',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esquema espacial multivariado GEOPREDIA_PROD con soporte nativo para '
                    'geocálculos ST_Contains, ST_Distance y federación de datos en tiempo real.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildPill('ISO 19115 Acreditado', Colors.tealAccent),
                      _buildPill('SRID: 4326 WGS84', Colors.lightBlueAccent),
                      _buildPill('OData v4 REST', Colors.amberAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Entidades del Modelo Semántico',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_hanaTables.length, (index) {
                final tbl = _hanaTables[index];
                final isSelected = _selectedTableIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tbl['name'] as String),
                    selected: isSelected,
                    selectedColor: AppColors.primaryDark,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedTableIndex = index);
                    },
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activeTable['title'] as String,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          activeTable['records'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeTable['description'] as String,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: AppColors.primaryDark),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activeTable['odataEndpoint'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Esquema DDL de Columnas',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderSubtle),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: (activeTable['columns'] as List).map<Widget>((c) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (c['pk'] == true) ...[
                                const Icon(Icons.key, size: 14, color: Colors.amber),
                                const SizedBox(width: 6),
                              ] else
                                const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  c['col'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                c['type'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const AppFooter(
            customMessage: 'SAP HANA Cloud Spatial Engine · ISO 19115 Metadata Standard',
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}