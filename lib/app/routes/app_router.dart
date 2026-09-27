// =============================================================
// app/routes/app_router.dart
// -------------------------------------------------------------
// Centraliza los nombres de ruta y la navegación hacia pantallas
// que NO forman parte de las 5 pestañas principales (por ejemplo,
// el detalle de una zona, al que se llega tocando una card).
//
// Por qué existe: si mañana cambias de Navigator 1.0 a go_router
// o a otra librería, solo tocas este archivo — las pantallas no
// deberían saber "cómo" se navega, solo "a dónde".
// =============================================================

import 'package:flutter/material.dart';

import '../../features/zone_detail/presentation/screens/zone_detail_screen.dart';
import '../../features/review_approval/presentation/screens/review_inbox_screen.dart';

class AppRoutes {
  static const String zoneDetail = '/zone-detail';
  static const String reviewInbox = '/review-inbox';

  /// Navega al detalle de una zona pasando su código como argumento.
  static void goToZoneDetail(BuildContext context, {required String zoneCode}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ZoneDetailScreen(zoneCode: zoneCode),
      ),
    );
  }

  /// Navega a la bandeja de revisión humana HITL.
  static void goToReviewDetail(BuildContext context, {String? taskId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ReviewInboxScreen(),
      ),
    );
  }
}
