# Integraciones SAP de GeoRisk App

Esta aplicación móvil/web consume la misma API GeoPredIA desplegada en SAP BTP
que la consola original. Ambas aplicaciones permanecen operativas en paralelo.

## Flujo activo

- **Datos y scoring:** `GET /api/zones` carga las zonas y los últimos resultados
  publicados por el backend. Si la red falla, Flutter usa el dataset incluido en
  `assets/data` para que la demostración no se interrumpa.
- **Asistente / Joule:** `POST /api/assistant/query` usa el contrato preparado
  para la acción de Joule Studio. Mientras el agente nativo no esté publicado,
  la respuesta proviene de reglas auditables del backend y luego usa reglas
  locales como último respaldo.
- **IoT:** el contrato compartido está en `POST /api/telemetry` y el simulador
  demostrativo en `POST /api/telemetry/simulate`.
- **Revisión:** `POST /api/reviews` registra decisiones locales y
  `POST /api/integrations/bpa/start` inicia SAP Build Process Automation cuando
  el tenant tiene sus credenciales configuradas.
- **SAP Analytics Cloud:** la Story oficial se conserva en
  `SapEndpoints.sacStoryUrl`.
- **SAP Build Work Zone:** la URL del sitio se conserva en
  `SapEndpoints.workZoneBaseUrl` para su registro en el catálogo.

## Compilación y despliegue independiente

```sh
flutter pub get
flutter build web --release \
  --dart-define=GEOPREDIA_API_URL=https://geopredia-ac374882u14.cfapps.us10-001.hana.ondemand.com
cf push -f manifest.yml
```

El nombre y la ruta Cloud Foundry de esta app son diferentes de los de la
consola original, por lo que desplegarla no reemplaza ni detiene GeoPredIA.

