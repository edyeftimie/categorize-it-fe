import '../../../domain/models/user.dart';
import '../../../domain/repositories/i_auth_repository.dart';

class MockAuthRepository implements IAuthRepository {
  static const _mockUser = User(id: 'u1', email: 'eftimie.eduard28@gmail.com', username: 'Eduard');

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AuthResult(token: 'mock_jwt_token', user: _mockUser);
  }

  @override
  Future<AuthResult> register({required String email, required String password, required String username}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AuthResult(token: 'mock_jwt_token', user: User(id: 'u1', email: email, username: username));
  }

  @override
  Future<AuthResult> googleLogin({required String idToken}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AuthResult(token: 'mock_jwt_token', user: _mockUser);
  }

  @override
  Future<void> logout() => Future.delayed(const Duration(milliseconds: 100));

  @override
  Future<User?> getCurrentUser() async => _mockUser;
}