import '../../domain/models/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._api);

  final AuthApiService _api;

  @override
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) {
    return _api.signUp(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) {
    return _api.signIn(email: email, password: password);
  }

  @override
  Future<AuthUser> verifyAccount({
    required String email,
    required String code,
  }) {
    return _api.verifyAccount(email: email, code: code);
  }
}
