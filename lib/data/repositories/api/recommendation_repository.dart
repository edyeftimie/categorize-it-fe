import 'package:dio/dio.dart';
import '../../../core/network/api_exception.dart';
import '../../../domain/models/recommendation.dart';
import '../../../domain/repositories/i_recommendation_repository.dart';

class RecommendationRepository implements IRecommendationRepository {
  final Dio _dio;
  RecommendationRepository(this._dio);

  @override
  Future<List<Recommendation>> getRecommendations() async {
    try {
      final r = await _dio.get<List<dynamic>>(
        '/api/recommendations',
        queryParameters: {'includeRead': true, 'includeDismissed': false},
      );
      return (r.data ?? [])
          .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _dio.patch<void>('/api/recommendations/$id/read');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> dismiss(String id) async {
    try {
      await _dio.patch<void>('/api/recommendations/$id/dismiss');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> generate() async {
    try {
      await _dio.post<void>('/api/recommendations/generate');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('/api/recommendations/unread-count');
      return r.data!['count'] as int;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}