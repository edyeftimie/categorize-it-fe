import 'package:categoriseit_fe/core/config/app_config.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../services/token_storage.dart';
import 'api_exception.dart';

class DioClient {
  final Dio dio;

  DioClient(TokenStorage tokenStorage)
      : dio = Dio(
          BaseOptions(
            baseUrl: appBaseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.addAll([
      _AuthInterceptor(tokenStorage),
      _ErrorInterceptor(tokenStorage),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  _AuthInterceptor(this._tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  _ErrorInterceptor(this._tokenStorage);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    if (statusCode == 401) {
      await _tokenStorage.deleteToken();
      return handler.reject(_wrap(
        err,
        ApiException(
          statusCode: 401,
          message: 'Session expired. Please log in again.',
          isUnauthorized: true,
        ),
      ));
    }

    // Prefer the server's own message when available.
    final serverMessage = _extractMessage(err.response?.data);
    handler.reject(_wrap(
      err,
      ApiException(
        statusCode: statusCode,
        message: serverMessage ?? _defaultMessage(statusCode),
      ),
    ));
  }

  String? _extractMessage(dynamic body) {
    if (body is Map) {
      final v = body['message'] ?? body['title'];
      return v is String && v.isNotEmpty ? v : null;
    }
    if (body is String && body.isNotEmpty) return body;
    return null;
  }

  String _defaultMessage(int? code) => switch (code) {
    400 => 'Invalid request.',
    403 => 'You don\'t have permission to do that.',
    404 => 'Resource not found.',
    409 => 'Conflict with existing data.',
    500 => 'Server error. Please try again later.',
    _   => 'Something went wrong.',
  };

  DioException _wrap(DioException original, ApiException apiEx) => DioException(
    requestOptions: original.requestOptions,
    response: original.response,
    type: original.type,
    error: apiEx,
  );
}