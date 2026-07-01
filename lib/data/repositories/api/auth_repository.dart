import 'package:categoriseit_fe/core/services/google_sign_in_service.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/token_storage.dart';
import '../../../domain/models/user.dart';
import '../../../domain/repositories/i_auth_repository.dart';

class ApiAuthRepository implements IAuthRepository {
  static const _loginPath       = '/api/authentication/login';
  static const _registerPath    = '/api/authentication/register';
  static const _googleLoginPath = '/api/authentication/google-login';

  final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiAuthRepository({required Dio dio, required TokenStorage tokenStorage})
      : _dio = dio,
        _tokenStorage = tokenStorage;

  @override
  Future<AuthResult> login({required String email, required String password}) =>
      _post(_loginPath, {'email': email, 'password': password});

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
  }) =>
      _post(_registerPath, {'email': email, 'password': password, 'name': username});

  @override
  Future<AuthResult> googleLogin({required String idToken}) =>
      _post(_googleLoginPath, {'idToken': idToken});

  @override
  Future<void> logout() async{
    await _tokenStorage.clearAll();
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await _tokenStorage.readToken();
    if (token == null) return null;
    final data = await _tokenStorage.readUserData();
    if (data == null) return null;
    return User(
      id:       data['id']       as String,
      email:    data['email']    as String,
      username: data['username'] as String?,
    );
  }

  Future<AuthResult> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final result = AuthResult.fromJson(response.data!);
      await Future.wait([
        _tokenStorage.saveToken(result.token),
        _tokenStorage.saveUserData({
          'id':       result.user.id,
          'email':    result.user.email,
          'username': result.user.username,
        }),
      ]);
      return result;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}