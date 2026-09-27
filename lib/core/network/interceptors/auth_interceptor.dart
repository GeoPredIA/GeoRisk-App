// =============================================================
// core/network/interceptors/auth_interceptor.dart
// -------------------------------------------------------------
// Interceptor de Dio que agrega automáticamente el token OAuth2
// (requerido por SAP BTP) a cada petición, sin que cada
// datasource tenga que escribirlo manualmente.
//
// NOTA: la lógica real de obtención/renovación del token
// (contra SAP Identity Authentication / XSUAA) se completa
// cuando tengas las credenciales del ambiente Trial. Por ahora
// queda el esqueleto documentado.
// =============================================================

import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  // TODO: reemplazar por un TokenStorage real (ej. flutter_secure_storage)
  // una vez que tengas el flujo de login contra SAP configurado.
  String? _cachedToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Si aún no hay token en caché, se solicita uno nuevo.
    _cachedToken ??= await _fetchToken();

    options.headers['Authorization'] = 'Bearer $_cachedToken';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si el token expiró (401), se intenta renovar UNA vez y se
    // reintenta la petición original.
    if (err.response?.statusCode == 401) {
      _cachedToken = null;
      _cachedToken = await _fetchToken();
      // Aquí se podría reintentar la petición original con el nuevo token.
    }
    handler.next(err);
  }

  /// Placeholder: aquí va la llamada real al endpoint de token de
  /// SAP Identity Authentication (flujo OAuth2 client_credentials
  /// o authorization_code, según cómo lo configure NTT DATA).
  Future<String> _fetchToken() async {
    // return await _authApi.requestAccessToken(...);
    return 'MOCK_TOKEN'; // valor temporal mientras se integra SAP real
  }
}
