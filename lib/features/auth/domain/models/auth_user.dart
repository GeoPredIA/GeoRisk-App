class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isVerified,
  });

  final String id;
  final String fullName;
  final String email;
  final String role;
  final bool isVerified;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id_usuario']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['nombre_completo']?.toString() ?? '',
      email: json['correo_electronico']?.toString() ?? '',
      role: json['rol_especialista']?.toString() ?? '',
      isVerified: json['estado_verificacion'] == true,
    );
  }
}
