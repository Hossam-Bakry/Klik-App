import 'package:get_it/get_it.dart';

import '../../../core/network/api_interface.dart';
import '../data/datasources/categories_remote_data_source.dart';
import '../data/repositories/categories_repository_impl.dart';
import '../domain/repositories/categories_repository.dart';
import '../presentation/bloc/categories_bloc.dart';
import '../presentation/bloc/category_products_bloc.dart';

/// Registers the categories module's dependencies. Relies on core deps
/// (ApiInterface) already being registered on [sl].
void registerCategoriesModule(GetIt sl) {
  sl
    ..registerLazySingleton<CategoriesRemoteDataSource>(
      () => CategoriesRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<CategoriesRepository>(
      () => CategoriesRepositoryImpl(sl<CategoriesRemoteDataSource>()),
    )
    // Page-scoped: a fresh bloc per navigation (factory). The route's/push's
    // BlocProvider owns its lifecycle and closes it when the page is popped.
    ..registerFactory(() => CategoriesBloc(sl<CategoriesRepository>()))
    ..registerFactory(() => CategoryProductsBloc(sl<CategoriesRepository>()));
}
