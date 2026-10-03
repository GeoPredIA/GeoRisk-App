// =============================================================
// Controlador reactivo simple para cambiar de pestaña desde cualquier pantalla, multiagentes o IoT hacia Revisión.
// =============================================================

import 'package:flutter/material.dart';

class AppNavController {
  AppNavController._();

  static final ValueNotifier<int> currentTab = ValueNotifier<int>(0);

  static void goToTab(int index) {
    currentTab.value = index;
  }
}