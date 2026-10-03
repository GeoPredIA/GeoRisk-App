// =============================================================
// Cliente HTTP único, compartido por TODOS los datasources de
// TODOS los features. Internamente usa Dio (paquete de terceros)
// y le agrega el AuthInterceptor para que cada petición lleve
// el token de SAP automáticamente.

// =============================================================

import 'package:dio/dio.dart';

import 'interceptors/auth_interceptor.dart';
import 'exceptions/sap_api_exception.dart';

class SapApiClient {
  late final Dio _dio;

  SapApiClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(AuthInterceptor());
  }

  /// GET genérico. Los datasources llaman esto pasando la URL completa
  /// (endpoint base de core/constants/sap_endpoints.dart + path).
  Future<Map<String, dynamic>> get(String url, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParams);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// POST genérico, usado por ejemplo para enviar una decisión de
  /// revisión a SAP Build Process Automation.
  Future<Map<String, dynamic>> post(String url, {required Map<String, dynamic> body}) async {
    try {
      final response = await _dio.post(url, data: body);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Traduce errores de Dio a nuestra excepción tipada SapApiException,
  /// para que el resto de la app no dependa de la librería Dio directamente.
  SapApiException _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return SapApiException.connection();
    }
    if (e.response?.statusCode == 401) {
      return SapApiException.unauthorized();
    }
    return SapApiException(
      e.response?.data?['message']?.toString() ?? 'Error al comunicarse con SAP.',
      statusCode: e.response?.statusCode,
    );
  }
}
