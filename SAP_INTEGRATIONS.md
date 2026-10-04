# Integraciones SAP de GeoRisk App

La app Flutter consume la API GeoPredIA desplegada en SAP BTP. La app no se
conecta directamente a SAP HANA Cloud: solicita datos al backend, que es quien
expone las rutas de integración.

## Conexiones activas desde Flutter

- **URL base:** `SapEndpoints.backendBaseUrl` apunta por defecto a
  `https://geopredia-ac374882u14.cfapps.us10-001.hana.ondemand.com`. Se puede
  cambiar para otro ambiente con `--dart-define=GEOPREDIA_API_URL=https://...`.
- **Zonas:** el dashboard hace `GET /api/zones` y transforma la respuesta en
  sus modelos. Si la petición falla o no devuelve zonas utilizables, la app usa
  el dataset local de `assets/data`; por eso ver datos en pantalla, por sí solo,
  no demuestra que esa sesión haya recibido datos remotos.
- **Asistente:** envía `POST /api/assistant/query`. Si el endpoint falla o no
  devuelve una respuesta utilizable, el asistente responde con reglas locales.
  La respuesta diferencia el caso en que el backend indica
  `joule_deployed: true`; la ruta preparada no demuestra por sí misma que el
  agente nativo de Joule esté desplegado.

## Servicios configurados o documentados, no llamados directamente por Flutter

- **SAP Analytics Cloud:** `SapEndpoints.sacStoryUrl` guarda una URL de Story,
  pero la app no contiene actualmente navegación que la abra.
- **SAP Build Work Zone:** `SapEndpoints.workZoneBaseUrl` guarda la URL del
  sitio; no está conectada actualmente a una acción de navegación en Flutter.
- **Revisión / BPA e IoT:** las rutas (`/api/reviews`,
  `/api/integrations/bpa/start`, `/api/telemetry`) forman parte del contrato
  documentado, pero no se encontraron llamadas a ellas desde los servicios
  Flutter actuales.

## Autenticación y comprobación

El interceptor de Flutter todavía no implementa OAuth real: `_fetchToken()`
devuelve `MOCK_TOKEN` y el header `Authorization` se establece con un valor
provisional. La API de zonas puede responder sin ese flujo; si un endpoint
requiere autenticación, esta implementación no proporciona credenciales válidas.

Para comprobar desde Windows que el backend configurado responde:

```powershell
curl.exe -i "https://geopredia-ac374882u14.cfapps.us10-001.hana.ondemand.com/api/zones"
```

Una respuesta `HTTP 200` con `application/json` confirma que el endpoint es
alcanzable y devuelve datos. Para comprobar que una sesión de la app utilizó
el backend y no el respaldo local, inspecciona en las herramientas de red del
entorno de ejecución la petición `GET /api/zones` y su respuesta `200`.

## Compilación y despliegue independiente

```powershell
flutter pub get
flutter build web --release --dart-define=GEOPREDIA_API_URL=https://geopredia-ac374882u14.cfapps.us10-001.hana.ondemand.com
cf push -f manifest.yml
```

El nombre y la ruta Cloud Foundry de esta app son diferentes de los de la
consola original, por lo que desplegarla no reemplaza ni detiene GeoPredIA.
