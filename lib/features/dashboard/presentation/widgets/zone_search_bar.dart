// =============================================================
// features/dashboard/presentation/widgets/zone_search_bar.dart
// -------------------------------------------------------------
// Campo "Buscar por concesión, región o código..." (Imagen 2).
// =============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ZoneSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ZoneSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por concesión, región o código...',
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
    );
  }
}
