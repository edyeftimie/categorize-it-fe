import '../../../domain/models/category.dart';
import '../../../domain/repositories/i_category_repository.dart';
import 'mock_data.dart';

class MockCategoryRepository implements ICategoryRepository {
  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.categories;
  }
}