// =============================================================
// features/integration/presentation/screens/integration_screen.dart
// -------------------------------------------------------------
// PLACEHOLDER de la pestaña "Integración" (Imágenes 11 y 12):
// estado de los 5 sistemas SAP conectados y especificación del
// dataset (gobernanza OGC/ISO).
//
// SIGUIENTE PASO (mismo patrón que dashboard/):
//   1. domain/entities/sap_system_status.dart
//   2. data/datasources/sap_systems_status_datasource.dart
//      (health-check simple a cada endpoint de
//      core/constants/sap_endpoints.dart)
//   3. presentation/widgets/sap_system_card.dart
// =============================================================

import 'package:flutter/material.dart';

class IntegrationScreen extends StatelessWidget {
  const IntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integración')),
      body: const Center(
        child: Text('Estado de sistemas SAP conectados\n(pendiente de implementar)',
            textAlign: TextAlign.center),
      ),
    );
  }
}
