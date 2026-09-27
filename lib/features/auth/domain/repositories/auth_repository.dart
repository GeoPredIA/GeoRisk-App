import '../models/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String password,
    required String role,
  });

  Future<AuthUser> signIn({
    required String email,
    required String password,
  });

  Future<AuthUser> verifyAccount({
    required String email,
    required String code,
  });
}
