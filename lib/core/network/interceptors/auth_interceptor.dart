// =============================================================
// Interceptor de Dio que agrega automáticamente el token OAuth2
// =============================================================

import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  String? _cachedToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    
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
