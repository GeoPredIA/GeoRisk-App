// =============================================================
// core/constants/sap_endpoints.dart
// -------------------------------------------------------------
// URLs base de cada servicio SAP que consume la app.
// Centralizarlas aquí permite cambiar fácilmente entre el
// ambiente Trial del hackathon y un ambiente productivo,
// sin buscar y reemplazar URLs por todo el proyecto.
//
// IMPORTANTE: estos son valores de EJEMPLO. Reemplázalos por
// las URLs reales que te entregue NTT DATA / SAP BTP Trial.
// Nunca subas claves/API keys reales a un repositorio público:
// usa variables de entorno (--dart-define) en su lugar.
// =============================================================

class SapEndpoints {
  SapEndpoints._();

  // --- SAP HANA Cloud (dataset de zonas, vía OData) ---
  /// API desplegada en SAP BTP. Se puede sustituir por ambiente con
  /// `--dart-define=GEOPREDIA_API_URL=https://...` sin recompilar código.
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
