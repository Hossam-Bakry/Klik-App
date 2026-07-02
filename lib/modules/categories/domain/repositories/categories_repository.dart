import '../../../../core/network/api_result.dart';
import '../entities/category.dart';
import '../entities/sub_category.dart';

abstract class CategoriesRepository {
  Future<ApiResult<List<Category>>> fetchCategories();

  Future<ApiResult<List<SubCategory>>> fetchSubCategories(int categoryId);
}
