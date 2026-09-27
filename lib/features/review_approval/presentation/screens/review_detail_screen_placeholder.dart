// =============================================================
// features/review_approval/presentation/screens/review_detail_screen_placeholder.dart
// -------------------------------------------------------------
// PLACEHOLDER de la pantalla de detalle de revisión (Imagen 10):
// donde el especialista escribe su justificación, marca checklist
// de mitigación, y decide Observar / Rechazar / Registrar Decisión.
//
// SIGUIENTE PASO:
//   1. presentation/widgets/vulnerability_bar.dart (las 3 barras
//      de vulnerabilidad cuantitativa)
//   2. presentation/widgets/justification_textfield.dart
//   3. presentation/widgets/mitigation_checklist.dart
//   4. presentation/widgets/decision_action_bar.dart con los 3
//      botones -> cada uno llama a domain/usecases/submit_decision.dart
//      -> que hace POST a SAP Build Process Automation para
//      "Registrar Decisión & Firmar en SAP Build".
//
// NOTA: el nombre de archivo lleva "_placeholder" para diferenciarlo
// claramente del archivo final "review_detail_screen.dart" que
// deberás crear cuando implementes el feature completo; en ese
// momento actualiza también el import en app/routes/app_router.dart.
// =============================================================

import 'package:flutter/material.dart';

class ReviewDetailScreenPlaceholder extends StatelessWidget {
  final String taskId;

  const ReviewDetailScreenPlaceholder({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Revisión $taskId')),
      body: Center(
        child: Text('Detalle y dictamen de la tarea $taskId\n(pendiente de implementar)'),
      ),
    );
  }
}
