import '../../../domain/models/recommendation.dart';
import '../../../domain/repositories/i_recommendation_repository.dart';
import 'mock_data.dart';

class MockRecommendationRepository implements IRecommendationRepository {
  final _recs = List<Recommendation>.from(MockData.recommendations);

  @override
  Future<List<Recommendation>> getRecommendations() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _recs.where((r) => !r.isDismissed).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    final idx = _recs.indexWhere((r) => r.id == id);
    if (idx != -1) _recs[idx] = _recs[idx].copyWith(isRead: true);
  }

  @override
  Future<void> dismiss(String id) async {
    final idx = _recs.indexWhere((r) => r.id == id);
    if (idx != -1) _recs[idx] = _recs[idx].copyWith(isDismissed: true);
  }

  @override
  Future<void> generate() => Future.delayed(const Duration(seconds: 1));
}