// =============================================================
// core/constants/sap_endpoints.dart
// -------------------------------------------------------------
// URLs de la API GeoPredIA desplegada en SAP BTP y de los servicios SAP
// enlazados o configurados por la app.
// Centralizarlas aquí permite cambiar el backend por ambiente sin
// buscar y reemplazar URLs por todo el proyecto.
//
// La URL por defecto apunta al backend desplegado. Para usar otro ambiente,
// configura `--dart-define=GEOPREDIA_API_URL=https://...`.
// Nunca incluyas claves/API keys reales en el repositorio.
// =============================================================

class SapEndpoints {
  SapEndpoints._();

  // --- API GeoPredIA en SAP BTP (datos y asistente) ---
  /// El cliente Flutter consume esta API; no se conecta directamente a HANA.
  static const String backendBaseUrl = String.fromEnvironment(
    'GEOPREDIA_API_URL',
    defaultValue:
        'https://geopredia-ac374882u14.cfapps.us10-001.hana.ondemand.com',
  );

  static const String hanaCloudBaseUrl = backendBaseUrl;

  // --- SAP Analytics Cloud (scoring, KPIs, dashboards) ---
  static const String sacBaseUrl =
      'https://sactrial-sacus10-wvs89sqlbd0v2ahch0f3bwyt.us10.hcs.cloud.sap';

  static const String sacStoryUrl =
      '$sacBaseUrl/sap/fpa/ui/app.html#;mode=present%3Bpreview%3Dtrue;view_id=story2;resource_id=AECC69FE103144DBA7279F47CF2E9EEC;url_api=true';

  // --- SAP Build Process Automation (flujo de revisión humana) ---
  static const String bpaBaseUrl = '$backendBaseUrl/api/integrations/bpa';

  // --- SAP Build Work Zone (portal / SSO) ---
  static const String workZoneBaseUrl =
      'https://sap-build-us10-trial-5-sd5tu6nm.workzone.cfapps.us10.hana.ondemand.com/site#workzone-home';

  // --- SAP Joule / Joule Studio (sugerencias en lenguaje natural) ---
  static const String jouleBaseUrl = '$backendBaseUrl/api/assistant/query';

  // --- Rutas específicas reutilizadas por los datasources ---
  static const String zonesPath = '/api/zones';
  static const String zoneDetailPath = '/api/evaluations';
  static const String agentsFindingsPath = '/api/agent-runs';
  static const String reviewTasksPath = '/api/reviews';
  static const String telemetryPath = '/api/telemetry';
  static const String systemsStatusPath = '/api/status';
}
