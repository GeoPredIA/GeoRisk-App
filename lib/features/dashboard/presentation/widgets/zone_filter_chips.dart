// =============================================================
// features/dashboard/presentation/widgets/zone_filter_chips.dart
// -------------------------------------------------------------
// Fila de chips "Todos (42) · Alto (5) · Medio (12) · Bajo (2)"
// vista en la Imagen 1-2. Es específico del dashboard (por eso
// vive en presentation/widgets/ del feature, no en core/).
// =============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ZoneFilterChips extends StatelessWidget {
  final String? activeFilter; // null = "Todos"
  final ValueChanged<String?> onFilterChanged;

  const ZoneFilterChips({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Los conteos aquí son solo de ejemplo visual; en una versión
    // más avanzada podrían venir calculados desde DashboardStats.
    final options = <String?, String>{
      null: 'Todos',
      'ALTO': 'Alto',
      'MEDIO': 'Medio',
      'BAJO': 'Bajo',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.entries.map((entry) {
          final isSelected = activeFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(entry.key),
              selectedColor: AppColors.primaryDark,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
