// =============================================================
// El chip " HANA Cloud" / " Sincronizado" que aparece en varios
// headers (Panorama, Integración). Indica en vivo si un sistema
// SAP está conectado, en cola, o desconectado.
// =============================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SyncStatus { online, syncing, queued, offline }

class SyncStatusChip extends StatelessWidget {
  final String label; // Ej: "HANA Cloud", "Sincronizado"
  final SyncStatus status;

  const SyncStatusChip({
    super.key,
    required this.label,
    required this.status,
  });

  Color get _color {
    switch (status) {
      case SyncStatus.online:
      case SyncStatus.syncing:
        return AppColors.riskLow; // verde
      case SyncStatus.queued:
        return AppColors.riskMedium; // ámbar
      case SyncStatus.offline:
        return AppColors.riskHigh; // rojo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              softWrap: true,
              style: TextStyle(
                color: _color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
