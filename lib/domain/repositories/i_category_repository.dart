import '../models/category.dart';

abstract interface class ICategoryRepository {
  Future<List<Category>> getCategories();
}