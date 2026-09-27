// =============================================================
// core/widgets/kpi_card.dart
// -------------------------------------------------------------
// Tarjeta genérica de estadística, usada en el Panorama para
// mostrar "42 Zonas de exploración", "48.2 Riesgo global prom.",
// "7 Pendientes de revisión", "135 Evaluaciones completadas".
// =============================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class KpiCard extends StatelessWidget {
  final String title;          // "Zonas de exploración"
  final String value;          // "42"
  final String? suffix;        // "/100" en el caso del riesgo promedio
  final Widget? trailingIcon;  // ícono pequeño arriba a la derecha
  final Widget? footer;        // texto pequeño abajo, ej: "↑ +3 este mes"

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.suffix,
    this.trailingIcon,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (trailingIcon != null) trailingIcon!,
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (suffix != null)
                    TextSpan(
                      text: suffix,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: 6),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
