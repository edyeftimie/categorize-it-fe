import '../models/user.dart';

class AuthResult {
  final String token;
  final User user;

  const AuthResult({required this.token, required this.user});

  factory AuthResult.fromJson(Map<String, dynamic> j) => AuthResult(
    token: j['token'] as String,
    user: User.fromJson(j['user'] as Map<String, dynamic>),
  );
}

abstract interface class IAuthRepository {
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> register({required String email, required String password, required String username});
  Future<AuthResult> googleLogin({required String idToken});
  Future<void> logout();
  Future<User?> getCurrentUser();
}