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
  static const String hanaCloudBaseUrl =
      'https://TU-INSTANCIA.hanacloud.ondemand.com/odata/v4/georisk';

  // --- SAP Analytics Cloud (scoring, KPIs, dashboards) ---
  static const String sacBaseUrl =
      'https://TU-TENANT.sapanalytics.cloud/api/v1';

  // --- SAP Build Process Automation (flujo de revisión humana) ---
  static const String bpaBaseUrl =
      'https://TU-TENANT.build.cloud.sap/process-automation/api/v1';

  // --- SAP Build Work Zone (portal / SSO) ---
  static const String workZoneBaseUrl =
      'https://TU-TENANT.workzone.cloud.sap/api/v1';

  // --- SAP Joule / Joule Studio (sugerencias en lenguaje natural) ---
  static const String jouleBaseUrl =
      'https://TU-TENANT.joule.cloud.sap/skills/v1';

  // --- Rutas específicas reutilizadas por los datasources ---
  static const String zonesPath = '/Zones';
  static const String zoneDetailPath = '/Zones'; // + '/{id}'
  static const String agentsFindingsPath = '/AgentFindings';
  static const String reviewTasksPath = '/ReviewTasks';
  static const String systemsStatusPath = '/SystemsStatus';
}
