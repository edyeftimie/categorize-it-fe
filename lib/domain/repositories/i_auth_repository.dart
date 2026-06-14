import '../models/user.dart';

class AuthResult {
  final String token;
  final User user;
  final DateTime expiration;
  const AuthResult({required this.token, required this.user, required this.expiration});
}

abstract interface class IAuthRepository {
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> register({required String email, required String password, required String username});
  Future<AuthResult> googleLogin({required String idToken});
  Future<void> logout();
  Future<User?> getCurrentUser();
}