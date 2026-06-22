import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final bool isUnauthorized;

  const ApiException({
    this.statusCode,
    required this.message,
    this.isUnauthorized = false,
  });

  /// Convenience: extract from a DioException after the error interceptor has run.
  static ApiException fromDioException(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException(message: 'Request timed out.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ApiException(message: 'Could not reach the server. Check your connection.');
    }
    return ApiException(
      statusCode: e.response?.statusCode,
      message: e.message ?? 'An unexpected error occurred.',
    );
  }

  @override
  String toString() => statusCode != null
      ? 'ApiException($statusCode): $message'
      : 'ApiException: $message';
}