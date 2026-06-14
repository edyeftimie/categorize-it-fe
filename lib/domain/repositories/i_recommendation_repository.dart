import '../models/recommendation.dart';

abstract interface class IRecommendationRepository {
  Future<List<Recommendation>> getRecommendations();
  Future<void> markAsRead(String id);
  Future<void> dismiss(String id);
  Future<void> generate();
}