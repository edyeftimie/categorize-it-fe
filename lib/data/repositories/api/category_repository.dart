import 'package:categoriseit_fe/core/network/api_exception.dart';
import 'package:categoriseit_fe/domain/models/category.dart';
import 'package:categoriseit_fe/domain/repositories/i_category_repository.dart';
import 'package:dio/dio.dart';

class CategoryRepository implements ICategoryRepository {
  final Dio _dio;

  CategoryRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get<List<dynamic>>('/api/categories');
      return (response.data ?? [])
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}