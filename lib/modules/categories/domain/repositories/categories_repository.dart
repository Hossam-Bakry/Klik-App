import '../../../../core/network/api_result.dart';
import '../../../home/domain/entities/home_product.dart';
import '../entities/category.dart';
import '../entities/sub_category.dart';

abstract class CategoriesRepository {
  Future<ApiResult<List<Category>>> fetchCategories();

  Future<ApiResult<List<SubCategory>>> fetchSubCategories(int categoryId);

  /// Products for a leaf category (one with no subcategories).
  Future<ApiResult<List<HomeProduct>>> fetchCategoryProducts(int categoryId);
}
