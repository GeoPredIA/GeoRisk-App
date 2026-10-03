// =============================================================
// El chip " ALTO 74/100" que se repite en:
//   - dashboard (lista de zonas)
//   - zone_detail (encabezado)
//   - multiagent_analysis (cada agente)
//   - review_approval (cada tarea)
// =============================================================

import 'package:flutter/material.dart';
import '../utils/risk_level_formatter.dart';

class RiskBadge extends StatelessWidget {
  /// Puntaje de 0 a 100. El color y la etiqueta se calculan solos.
  final num score;

  /// Si es true, muestra "ALTO 74/100"; si es false, solo "ALTO".
  final bool showScore;

  const RiskBadge({
    super.key,
    required this.score,
    this.showScore = true,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = RiskLevelFormatter.describe(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // El puntito de color, tal como aparece en los mockups ("●")
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            showScore ? '$label ${score.toInt()}/100' : label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
