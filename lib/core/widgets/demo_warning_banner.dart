import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DemoWarningBanner extends StatelessWidget {
  final VoidCallback? onSyncPressed;

  const DemoWarningBanner({super.key, this.onSyncPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primaryDark.withValues(alpha: 0.88),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.bolt, color: Colors.amberAccent, size: 16),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PILOTO EN VIVO · HACKATHON 2026',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w800,
                    color: Colors.amberAccent,
                  ),
                ),
                Text(
                  'Datos espaciales enlazados a SAP HANA Cloud · OData v4',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onSyncPressed != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              onPressed: onSyncPressed,
              tooltip: 'Sincronizar con SAP HANA Cloud',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
            ),
        ],
      ),
    );
  }
}