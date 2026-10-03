// Widget test básico de GeoPredIA
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:georisk/app/app.dart';
import 'package:georisk/app/di/injector.dart';
import 'package:georisk/app/navigation/main_bottom_nav.dart';
import 'package:georisk/core/widgets/kpi_card.dart';
import 'package:georisk/features/dashboard/data/services/mining_dataset_service.dart';
import 'package:georisk/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:georisk/features/dashboard/presentation/widgets/zone_list_card.dart';
import 'package:georisk/features/assistant/data/services/joule_data_assistant.dart';
import 'package:georisk/features/assistant/presentation/screens/assistant_screen.dart';
import 'package:georisk/features/iot_sentinel/presentation/screens/iot_sentinel_screen.dart';
import 'package:georisk/features/multiagent_analysis/presentation/screens/multiagent_analysis_screen.dart';
import 'package:georisk/features/review_approval/data/services/review_manager_service.dart';
import 'package:georisk/features/review_approval/presentation/screens/review_inbox_screen.dart';
import 'package:georisk/features/zone_detail/presentation/screens/zone_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('el selector de Multiagentes acepta los códigos del dataset',
      (WidgetTester tester) async {
    final dataset = MiningDatasetService.instance;
    await tester.runAsync(dataset.init);
    expect(dataset.allZones, isNotEmpty);

    final firstZone = dataset.allZones.first;
    await tester.pumpWidget(
      const MaterialApp(home: MultiagentAnalysisScreen()),
    );
    expect(tester.takeException(), isNull);
    expect(find.textContaining('${firstZone.code} - ${firstZone.name}'),
        findsOneWidget);
  });

  testWidgets('el detalle de zona presenta nomenclatura legible',
      (WidgetTester tester) async {
    await tester.runAsync(MiningDatasetService.instance.init);
    final zone = MiningDatasetService.instance.allZones.first;

    await tester.pumpWidget(
      MaterialApp(home: ZoneDetailScreen(zoneCode: zone.code)),
    );

    final scrollable = find.byType(Scrollable).first;
    final riskHeading = find.textContaining('Índice de Riesgo Combinado');
    await tester.scrollUntilVisible(riskHeading, 220, scrollable: scrollable);
    expect(riskHeading, findsOneWidget);

    for (final section in [
      'Dimensión Geotécnica',
      'Dimensión Ambiental',
      'Dimensión Socioambiental',
    ]) {
      final sectionHeading = find.text(section);
      await tester.scrollUntilVisible(sectionHeading, 220,
          scrollable: scrollable);
      expect(sectionHeading, findsOneWidget);
    }

    final airQuality = find.textContaining('µg/m³');
    await tester.scrollUntilVisible(airQuality, 220, scrollable: scrollable);
    expect(airQuality, findsOneWidget);
    expect(find.textContaining('Ã'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Joule consulta los 140 códigos y responde consultas abiertas',
      (WidgetTester tester) async {
    await tester.runAsync(MiningDatasetService.instance.init);
    final zones = MiningDatasetService.instance.allZones;
    expect(zones, isNotEmpty);
    const assistant = JouleDataAssistant();

    for (final zone in zones) {
      final answer = assistant.answer('Resume la zona ${zone.code}');
      expect(answer.text, contains(zone.name), reason: zone.code);
    }

    final firstZone = zones.first;
    final secondZone = zones.last;
    final comparison = assistant.answer(
      'Compara ${firstZone.code} con ${secondZone.code}',
    );
    expect(comparison.text, contains(firstZone.name));
    expect(comparison.text, contains(secondZone.name));

    final openQuestion = assistant.answer(
      '¿Cómo puedo priorizar una revisión ambiental?',
    );
    expect(openQuestion.topic, contains('ambiental'));
    expect(openQuestion.sources, contains('Dataset local GeoPredIA'));
  });

  testWidgets('Joule responde dentro de una pantalla móvil',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(MiningDatasetService.instance.init);

    final zone = MiningDatasetService.instance.allZones.first;
    await tester.pumpWidget(const MaterialApp(home: AssistantScreen()));
    expect(tester.takeException(), isNull);
    await tester.enterText(
        find.byType(TextField), 'Riesgo global de ${zone.code}');
    await tester.tap(find.byTooltip('Enviar pregunta'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.textContaining(zone.name), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Panorama adapta KPI y carga zonas conforme se desplaza',
      (WidgetTester tester) async {
    await tester.runAsync(MiningDatasetService.instance.init);
    final zones = MiningDatasetService.instance.allZones;
    expect(zones, isNotEmpty);

    for (final width in [360.0, 320.0]) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MultiProvider(
          providers: Injector.buildProviders(),
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final zonesHeading = find.text('Zonas bajo evaluación');
      await tester.scrollUntilVisible(
        zonesHeading,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(zonesHeading, findsOneWidget);
      expect(tester.widgetList<ZoneListCard>(find.byType(ZoneListCard)).length,
          lessThan(zones.length));
      expect(tester.takeException(), isNull);
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('KPI muestra título, valor y pie centrados',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              child: KpiCard(
                title: 'Zonas de exploración',
                value: '140',
                footer: Text('Actualizadas hoy'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text('Zonas de exploración')).textAlign,
      TextAlign.center,
    );
    expect(
      find.descendant(
        of: find.byType(KpiCard),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding ==
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      findsOneWidget,
    );
    final valueRichText = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == '140',
    );
    expect(tester.widget<RichText>(valueRichText).textAlign, TextAlign.center);
  });

  testWidgets('Panorama muestra el nombre completo de Evaluaciones completas',
      (WidgetTester tester) async {
    await tester.runAsync(MiningDatasetService.instance.init);
    await tester.pumpWidget(
      MultiProvider(
        providers: Injector.buildProviders(),
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Evaluaciones completas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el acceso de Panorama abre el perfil completo del operador',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(MiningDatasetService.instance.init);
    await tester.pumpWidget(
      MultiProvider(
        providers: Injector.buildProviders(),
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Operador del Sistema'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil del Operador'), findsOneWidget);
    expect(find.text('Ing. Alejandro Samir'), findsOneWidget);
    expect(find.text('PRIVILEGIOS HITL ACTIVOS'), findsOneWidget);

    await tester.tap(find.text('Editar perfil'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('profile-name-field')),
      'Ing. Alejandra Samir',
    );
    await tester.enterText(
      find.byKey(const ValueKey('profile-email-field')),
      'alejandra@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('profile-phone-field')),
      '+51 999 555 111',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Ing. Alejandra Samir'), findsOneWidget);
    expect(find.text('alejandra@example.com'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(
        preferences.getString('operator_profile_name'), 'Ing. Alejandra Samir');

    final passwordAction = find.text('Cambiar contraseña');
    await tester.scrollUntilVisible(
      passwordAction,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(passwordAction);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('todavía no está conectada a un proveedor'),
      findsOneWidget,
    );
  });

  testWidgets('IoT envía la zona completa a HITL sin desbordar en móvil',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(MiningDatasetService.instance.init);
    final zones = MiningDatasetService.instance.allZones;
    expect(zones, isNotEmpty);
    final zone = zones.first;

    await tester.pumpWidget(
      const MaterialApp(home: IotSentinelScreen()),
    );
    expect(find.textContaining('${zone.code} · ${zone.name}'), findsWidgets);

    final sendButton = find.text('Enviar telemetría a Revisión Humana HITL');
    await tester.scrollUntilVisible(
      sendButton,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(sendButton);
    await tester.pump();
    expect(tester.takeException(), isNull);

    final task = ReviewManagerService.instance.tasks.firstWhere(
      (item) => item.origin == 'Monitoreo IoT' && item.zoneCode == zone.code,
    );
    expect(task.zoneName, '${zone.code} · ${zone.name}');
    expect(find.text('Ver bandeja'), findsOneWidget);
    ReviewManagerService.instance.deleteTask(task.id);
  });

  testWidgets('la navegación inferior muestra los nombres completos en móvil',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: Injector.buildProviders(),
        child: const MaterialApp(home: MainBottomNav()),
      ),
    );

    expect(find.text('Panorama'), findsOneWidget);
    expect(find.text('Multiagentes'), findsOneWidget);
    expect(find.text('Monitoreo\nIoT'), findsOneWidget);
    expect(find.text('Revisión\nHumana'), findsOneWidget);
    expect(find.text('Asistente\nJoule'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('una tarea enviada se puede dictaminar desde Revisión',
      (WidgetTester tester) async {
    final service = ReviewManagerService.instance;
    final task = ReviewTaskItem(
      id: 'REV-UI-TEST-${DateTime.now().microsecondsSinceEpoch}',
      zoneCode: 'Z-TEST',
      zoneName: 'Zona de prueba completa',
      origin: 'Multiagentes',
      globalScore: 61,
      geoScore: 52,
      envScore: 67,
      socialScore: 64,
      date: 'Hoy',
      summary: 'Resumen completo enviado desde el análisis multiagente.',
    );
    service.addTask(task);

    await tester.pumpWidget(const MaterialApp(home: ReviewInboxScreen()));
    expect(find.text('Rechazada'), findsOneWidget);
    await tester.tap(find.text('Rechazada'));
    await tester.pumpAndSettle();
    expect(find.text('No hay tareas con estado "Rechazada"'), findsOneWidget);
    await tester.tap(find.text('Todas'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Z-TEST · Zona de prueba completa'),
        findsOneWidget);
    await tester.tap(find.textContaining('Z-TEST · Zona de prueba completa'));
    await tester.pumpAndSettle();
    expect(find.text(task.summary), findsOneWidget);
    expect(find.text('Aprobar'), findsOneWidget);

    await tester.tap(find.text('Aprobar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Revisado en prueba');
    await tester.tap(find.text('Confirmar dictamen'));
    await tester.pumpAndSettle();

    expect(task.status, 'Aprobada');
    expect(task.comment, 'Revisado en prueba');
    service.deleteTask(task.id);
  });

  testWidgets('el splash espera tres segundos y carga antes de entrar',
      (WidgetTester tester) async {
    await tester.runAsync(MiningDatasetService.instance.init);
    await tester.pumpWidget(
      MultiProvider(
        providers: Injector.buildProviders(),
        child: const GeoPredIAApp(),
      ),
    );
    expect(find.text('Iniciando GeoPredIA...'), findsOneWidget);
    final initialProgress = tester
        .widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        )
        .value!;
    await tester.pump(const Duration(seconds: 2));
    final advancedProgress = tester
        .widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        )
        .value!;
    expect(advancedProgress, greaterThan(initialProgress));
    expect(advancedProgress, lessThanOrEqualTo(0.9));
    expect(find.byType(MainBottomNav), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(MainBottomNav), findsOneWidget);
  });
}
