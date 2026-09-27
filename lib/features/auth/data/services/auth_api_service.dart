import 'package:dio/dio.dart';

import '../../domain/models/auth_user.dart';

class AuthApiService {
  AuthApiService({Dio? client, String? baseUrl})
      : _client = client ?? Dio(),
        _baseUrl = baseUrl ??
            const String.fromEnvironment(
              'ejemploaquiratuapi',
              defaultValue: 'http://localhost:3000/api',
            );

  final Dio _client;
  final String _baseUrl;

  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    return _sendUser('/auth/signup', {
      'nombre_completo': fullName,
      'correo_electronico': email,
      'password': password,
      'rol_especialista': role,
    });
  }

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    return _sendUser('/auth/signin', {
      'correo_electronico': email,
      'password': password,
    });
  }

  Future<AuthUser> verifyAccount({
    required String email,
    required String code,
  }) async {
    return _sendUser('/auth/verify', {
      'correo_electronico': email,
      'codigo': code,
    });
  }

  Future<AuthUser> _sendUser(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client.post('$_baseUrl$path', data: body);
      final data = Map<String, dynamic>.from(response.data as Map);
      return AuthUser.fromJson(
        (data['user'] as Map?)?.cast<String, dynamic>() ?? data,
      );
    } on DioException catch (error) {
      final message = error.response?.data is Map
          ? error.response?.data['message']?.toString()
          : null;
      throw AuthApiException(
          message ?? 'No se pudo completar la operación de autenticación.');
    }
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
