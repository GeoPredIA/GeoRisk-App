import 'package:dio/dio.dart';

import '../templates/verification_email_template.dart';

class BrevoEmailService {
  BrevoEmailService({Dio? client, String? backendUrl})
      : _client = client ?? Dio(),
        _backendUrl = backendUrl ??
            const String.fromEnvironment(
              'GEORISK_API_BASE_URL',
              defaultValue: 'http://localhost:3000/api',
            );

  final Dio _client;
  final String _backendUrl;

  // TODO: [BREVO_API_KEY] Inserta aquí tu clave de API de Brevo (ej: xkeysib-...) y configura el endpoint https://api.brevo.com/v3/smtp/email
  // La clave debe vivir únicamente en el backend, nunca en la aplicación móvil.
  Future<void> sendVerificationCode({
    required String recipientName,
    required String email,
    required String code,
  }) async {
    try {
      await _client.post(
        '$_backendUrl/auth/send-verification-email',
        data: {
          'nombre_completo': recipientName,
          'correo_electronico': email,
          'codigo': code,
          'html_content': VerificationEmailTemplate.html(
            recipientName: recipientName,
            code: code,
          ),
        },
      );
    } on DioException catch (error) {
      final message = error.response?.data is Map
          ? error.response?.data['message']?.toString()
          : null;
      throw BrevoException(
        message ?? 'No se pudo enviar el correo de verificación.',
      );
    }
  }
}

class BrevoException implements Exception {
  const BrevoException(this.message);
  final String message;

  @override
  String toString() => message;
}
