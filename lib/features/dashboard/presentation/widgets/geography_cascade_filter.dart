// =============================================================
// features/dashboard/presentation/widgets/geography_cascade_filter.dart
// -------------------------------------------------------------
// Selector en cascada: Departamento -> Provincia -> Distrito
// para explorar las zonas mineras del dataset de forma ágil y bonita.
// =============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';

class GeographyCascadeFilter extends StatelessWidget {
  final DashboardProvider provider;

  const GeographyCascadeFilter({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final hasGeoFilter = provider.selectedRegion != null ||
        provider.selectedProvince != null ||
        provider.selectedDistrict != null;

    final regions = provider.regions;
    final provinces = provider.provinces;
    final districts = provider.districts;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.travel_explore,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 7),
                  child: Text(
                    'Exploración Geográfica',
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (hasGeoFilter)
                TextButton.icon(
                  onPressed: provider.clearGeographyFilters,
                  icon: const Icon(
                    Icons.clear,
                    size: 14,
                    color: AppColors.riskHigh,
                  ),
                  label: const Text(
                    'Restablecer',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.riskHigh,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Selector de Departamento / Región
          _DropdownRow(
            label: 'Departamento:',
            icon: Icons.map,
            value: provider.selectedRegion,
            hint: 'Todos los departamentos (${regions.length})',
            items: regions,
            onChanged: (val) => provider.setRegion(val),
          ),
          const SizedBox(height: 10),

          // 2. Selector de Provincia
          _DropdownRow(
            label: 'Provincia:',
            icon: Icons.location_city,
            value: provider.selectedProvince,
            hint: provider.selectedRegion == null
                ? 'Seleccione o todas (${provinces.length})'
                : 'Todas las provincias de ${provider.selectedRegion}',
            items: provinces,
            onChanged: (val) => provider.setProvince(val),
          ),
          const SizedBox(height: 10),

          // 3. Selector de Distrito
          _DropdownRow(
            label: 'Distrito:',
            icon: Icons.place,
            value: provider.selectedDistrict,
            hint: provider.selectedProvince == null
                ? 'Seleccione o todos (${districts.length})'
                : 'Todos los distritos de ${provider.selectedProvince}',
            items: districts,
            onChanged: (val) => provider.setDistrict(val),
          ),

          const SizedBox(height: 12),
          // Resumen informativo del dataset
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Mostrando ${provider.zones.length} zonas de exploración minera activas',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          itemHeight: null,
          menuMaxHeight: 420,
          value: items.contains(value) ? value : null,
          hint: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 18, color: AppColors.textSecondary),
          items: [
            DropdownMenuItem<String>(
              value: '',
              child: Text('Todos / Todas ($label)',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            ...items.map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      item,
                      softWrap: true,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )),
          ],
          onChanged: (val) {
            if (val == '') {
              onChanged(null);
            } else {
              onChanged(val);
            }
          },
        ),
      ),
    );
  }
}
