// =============================================================
// app/navigation/app_nav_controller.dart
// -------------------------------------------------------------
// Controlador reactivo simple para cambiar de pestaña desde cualquier
// pantalla (por ejemplo, desde Multiagentes o IoT hacia Revisión).
// =============================================================

import 'package:flutter/material.dart';

class AppNavController {
  AppNavController._();

  static final ValueNotifier<int> currentTab = ValueNotifier<int>(0);

  static void goToTab(int index) {
    currentTab.value = index;
  }
}