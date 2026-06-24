import 'package:categoriseit_fe/core/config/app_config.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../services/token_storage.dart';
import 'api_exception.dart';

class DioClient {
  late final Dio dio;

  DioClient(TokenStorage tokenStorage, {void Function()? onUnauthorized}) {
    dio = Dio(
      BaseOptions(
        baseUrl: appBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.addAll([
      _AuthInterceptor(tokenStorage),
      _ErrorInterceptor(tokenStorage, onUnauthorized: onUnauthorized),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  final TokenStorage _storage;
  _AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  final TokenStorage _storage;
  final void Function()? onUnauthorized;

  _ErrorInterceptor(this._storage, {this.onUnauthorized});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _storage.deleteToken();

      final isAuthEndpoint = err.requestOptions.path.contains('/authentication/');
      if (!isAuthEndpoint) {
        onUnauthorized?.call();
      }

      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: const ApiException(
            statusCode: 401,
            message: 'Session expired. Please log in again.',
            isUnauthorized: true,
          ),
        ),
      );
      return;
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: ApiException.fromDioException(err),
      ),
    );
  }
}