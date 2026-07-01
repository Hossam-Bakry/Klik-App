import '../../../../core/network/api_result.dart';
import '../../../home/domain/entities/home_product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/sub_category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_remote_data_source.dart';

/// Entities are already mapped by [CategoryDto] et al., so this is a thin
/// pass-through — kept as a seam for caching later.
class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl(this._remote);

  final CategoriesRemoteDataSource _remote;

  @override
  Future<ApiResult<List<Category>>> fetchCategories() =>
      _remote.fetchCategories();

  @override
  Future<ApiResult<List<SubCategory>>> fetchSubCategories(int categoryId) =>
      _remote.fetchSubCategories(categoryId);

  @override
  Future<ApiResult<List<HomeProduct>>> fetchCategoryProducts(
    int categoryId,
  ) =>
      _remote.fetchCategoryProducts(categoryId);
}
