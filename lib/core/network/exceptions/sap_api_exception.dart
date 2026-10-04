// =============================================================
// core/network/exceptions/sap_api_exception.dart
// -------------------------------------------------------------
// Excepción propia para errores al comunicarse con cualquier
// servicio SAP. Tenerla tipada (en vez de usar Exception genérica)
// permite que la UI muestre mensajes específicos según el caso
// (timeout, no autorizado, servidor caído, etc.).
// =============================================================

class SapApiException implements Exception {
final String message;
final int? statusCode;

const SapApiException(this.message, {this.statusCode});

  /// Fábrica de conveniencia para errores de conexión (sin internet,
  /// timeout, DNS, etc.) — no hay statusCode porque nunca llegó respuesta.
factory SapApiException.connection() =>
const SapApiException('No se pudo conectar con los servicios SAP. Verifica tu conexión.');

  /// Fábrica de conveniencia para cuando el token expiró o es inválido.
factory SapApiException.unauthorized() =>
    const SapApiException('Sesión expirada. Vuelve a iniciar sesión.', statusCode: 401);

@override
String toString() => 'SapApiException($statusCode): $message';
}
