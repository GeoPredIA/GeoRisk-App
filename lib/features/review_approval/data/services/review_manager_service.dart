// =============================================================
// features/review_approval/data/services/review_manager_service.dart
// -------------------------------------------------------------
// Servicio reactivo que conecta Multiagentes, IoT Sentinel y la
// bandeja de Revisión Humana HITL (Human-in-the-Loop).
// Permite agregar dictámenes, aprobar, observar y eliminar tareas.
// =============================================================

import 'package:flutter/foundation.dart';

class ReviewTaskItem {
  final String id;
  final String zoneCode;
  final String zoneName;
  final String origin; // 'Multiagentes' | 'Monitoreo IoT' | 'Campo'
  String status; // 'Pendiente' | 'Aprobada' | 'Observada' | 'Rechazada'
  final int globalScore;
  final int geoScore;
  final int envScore;
  final int socialScore;
  final String date;
  final String summary;
  String reviewer;
  String decision;
  String comment;

  ReviewTaskItem({
    required this.id,
    required this.zoneCode,
    required this.zoneName,
    required this.origin,
    this.status = 'Pendiente',
    required this.globalScore,
    required this.geoScore,
    required this.envScore,
    required this.socialScore,
    required this.date,
    required this.summary,
    this.reviewer = 'Ing. Alejandro Samir',
    this.decision = 'Pendiente de dictamen',
    this.comment = '',
  });
}

class ReviewManagerService extends ChangeNotifier {
  ReviewManagerService._() {
    _initDefaultTasks();
  }

  static final ReviewManagerService instance = ReviewManagerService._();

  final List<ReviewTaskItem> _tasks = [];
  List<ReviewTaskItem> get tasks => List.unmodifiable(_tasks);

  void _initDefaultTasks() {
    _tasks.addAll([
      ReviewTaskItem(
        id: 'REV-001',
        zoneCode: 'QN-402',
        zoneName: 'Quellaveco Norte',
        origin: 'Multiagentes',
        status: 'Pendiente',
        globalScore: 74,
        geoScore: 72,
        envScore: 68,
        socialScore: 78,
        date: 'Hoy, 04:30 p.m.',
        summary: 'Alerta por sismicidad inducida cercana a falla y requerimiento de plan de aguas ácidas.',
        reviewer: 'Ing. Alejandro Samir',
      ),
      ReviewTaskItem(
        id: 'REV-002',
        zoneCode: 'TT-892',
        zoneName: 'Tintaya Sur / Coroccohuayco',
        origin: 'Multiagentes',
        status: 'Observada',
        globalScore: 76,
        geoScore: 58,
        envScore: 81,
        socialScore: 84,
        date: 'Ayer, 11:20 a.m.',
        summary: 'Elevado estrés hídrico y quejas registradas en cuenca del río Salado.',
        reviewer: 'Ing. Alejandro Samir',
        decision: 'Continuar con condiciones',
        comment: 'Actualizar línea base hídrica trimestral antes de excavaciones.',
      ),
      ReviewTaskItem(
        id: 'REV-003',
        zoneCode: 'Z0001',
        zoneName: 'Zona Yanacocha Baja II',
        origin: 'Monitoreo IoT',
        status: 'Pendiente',
        globalScore: 65,
        geoScore: 62,
        envScore: 71,
        socialScore: 60,
        date: '26-set., 03:10 p.m.',
        summary: 'Pico de humedad relativa del suelo (25.9%) y temperatura de agua (18.6°C) en sensor DS18B20.',
        reviewer: 'Ing. Alejandro Samir',
      ),
    ]);
  }

  /// Agrega una nueva tarea de revisión desde Multiagentes o IoT Sentinel
  void addTask(ReviewTaskItem task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  /// Elimina una tarea de revisión ("el usuario va poder enviar y tambien eliminar")
  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Dictamen de Aprobación
  void approveTask(String id, {String? comment}) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].status = 'Aprobada';
      _tasks[index].decision = 'Continuar exploración minera';
      if (comment != null && comment.isNotEmpty) {
        _tasks[index].comment = comment;
      }
      notifyListeners();
    }
  }

  /// Dictamen de Observación
  void observeTask(String id, {String? comment}) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].status = 'Observada';
      _tasks[index].decision = 'Continuar con condiciones de mitigación';
      if (comment != null && comment.isNotEmpty) {
        _tasks[index].comment = comment;
      }
      notifyListeners();
    }
  }

  /// Dictamen de Rechazo o Suspensión
  void rejectTask(String id, {String? comment}) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].status = 'Rechazada';
      _tasks[index].decision = 'Suspender actividades de exploración';
      if (comment != null && comment.isNotEmpty) {
        _tasks[index].comment = comment;
      }
      notifyListeners();
    }
  }
}