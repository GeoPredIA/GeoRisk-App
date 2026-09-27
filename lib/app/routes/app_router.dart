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
import '../../features/review_approval/presentation/screens/review_detail_screen_placeholder.dart';

class AppRoutes {
  // Nombres de ruta como constantes evita errores de tipeo
  // al navegar (Navigator.pushNamed(context, AppRoutes.zoneDetail)).
  static const String zoneDetail = '/zone-detail';
  static const String reviewDetail = '/review-detail';

  /// Navega al detalle de una zona pasando su código como argumento.
  /// Se usa desde dashboard_screen.dart al tocar una ZoneListCard.
  static void goToZoneDetail(BuildContext context, {required String zoneCode}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ZoneDetailScreen(zoneCode: zoneCode),
      ),
    );
  }

  /// Navega al detalle de una tarea de revisión (feature review_approval).
  static void goToReviewDetail(BuildContext context, {required String taskId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewDetailScreenPlaceholder(taskId: taskId),
      ),
    );
  }
}
