// =============================================================
// features/multiagent_analysis/presentation/screens/multiagent_analysis_screen.dart
// -------------------------------------------------------------
// PLACEHOLDER de la pestaña "Multiagentes" (Imágenes 4, 5 y 6).
// Aquí es donde se integra SAP Joule / Joule Studio para generar
// los hallazgos de cada agente (Geotécnico, Hidrológico, Social)
// y el veredicto del "Coordinador Autónomo".
//
// SIGUIENTE PASO (mismo patrón que dashboard/):
//   1. domain/entities/agent_finding.dart y coordinator_verdict.dart
//   2. domain/usecases/get_deployed_agents.dart y submit_to_human_review.dart
//   3. data/datasources/joule_agents_datasource.dart
//      (llama a SAP Joule Studio con el skill correspondiente)
//   4. presentation/widgets/agent_finding_card.dart (card expandible)
//   5. Botón "Enviar a Revisión Humana" -> llama a
//      submit_to_human_review, que internamente crea la tarea en
//      SAP Build Process Automation (feature review_approval).
// =============================================================

import 'package:flutter/material.dart';

class MultiagentAnalysisScreen extends StatelessWidget {
  const MultiagentAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiagentes')),
      body: const Center(
        child: Text('Análisis multiagente (SAP Joule)\n(pendiente de implementar)',
            textAlign: TextAlign.center),
      ),
    );
  }
}
