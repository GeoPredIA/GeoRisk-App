// =============================================================
// Punto de entrada de la aplicación GeoPredIA.
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/di/injector.dart';

void main() {
  // Asegura que los bindings de Flutter estén listos antes de
  // hacer cualquier configuración (necesario si luego agregas
  // inicialización de SDKs de SAP, Firebase, etc. antes del runApp).
  WidgetsFlutterBinding.ensureInitialized();

  // Registra todas las dependencias (repositorios, datasources,
  // providers) en el contenedor de inyección de dependencias.
  // Ver: lib/app/di/injector.dart
  final providers = Injector.buildProviders();

  runApp(
    // MultiProvider expone todos los ChangeNotifier/Provider
    // registrados en injector.dart a TODA la app (todos los widgets
    // hijos pueden acceder a ellos con context.watch/context.read).
    MultiProvider(
      providers: providers,
      child: const GeoPredIAApp(),
    ),
  );
}
