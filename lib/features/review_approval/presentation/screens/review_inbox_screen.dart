// =============================================================
// features/review_approval/presentation/screens/review_inbox_screen.dart
// -------------------------------------------------------------
// PLACEHOLDER de la pestaña "Revisión" (Imagen 9): bandeja de
// tareas HITL (Human-in-the-Loop) pendientes de dictamen.
// ESTE ES TU REQUISITO CLAVE: la app requiere aprobación humana
// antes de dar por válida una evaluación de riesgo.
//
// SIGUIENTE PASO (mismo patrón que dashboard/):
//   1. domain/entities/review_task.dart (código, zona, nivel,
//      estado: Crítica/Observada/En Proceso)
//   2. domain/usecases/get_pending_reviews.dart, submit_decision.dart
//   3. data/datasources/sap_bpa_datasource.dart
//      (llama a SAP Build Process Automation: lista de workflows
//      pendientes en la "compuerta 2" que se ve en tus mockups)
//   4. presentation/widgets/review_task_card.dart
//      (tarjeta "QN-402 · Moquegua · Alto Riesgo 74/100")
//   5. Al tocar una card -> AppRoutes.goToReviewDetail(context,
//      taskId: task.id) para ir a la pantalla de detalle
//      (ver review_detail_screen_placeholder.dart en esta misma carpeta).
// =============================================================

import 'package:flutter/material.dart';

class ReviewInboxScreen extends StatelessWidget {
  const ReviewInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revisión Humana')),
      body: const Center(
        child: Text(
          'Bandeja HITL (SAP Build Process Automation)\n(pendiente de implementar)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
