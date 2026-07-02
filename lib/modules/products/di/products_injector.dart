import 'package:get_it/get_it.dart';

import '../../../core/favorites/presentation/favorites_cubit.dart';
import '../../../core/network/api_interface.dart';
import '../../categories/domain/repositories/categories_repository.dart';
import '../data/datasources/products_remote_data_source.dart';
import '../data/repositories/products_repository_impl.dart';
import '../domain/repositories/products_repository.dart';
import '../presentation/bloc/products_bloc.dart';

/// Registers the products module's dependencies. Relies on core deps
/// (ApiInterface, FavoritesCubit) and the categories module
/// (CategoriesRepository, for the filter sheet's category options) already
/// being registered on [sl].
void registerProductsModule(GetIt sl) {
  sl
    ..registerLazySingleton<ProductsRemoteDataSource>(
      () => ProductsRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<ProductsRepository>(
      () => ProductsRepositoryImpl(sl<ProductsRemoteDataSource>()),
    )
    // Page-scoped: a fresh ProductsBloc per navigation (factory). The route's
    // BlocProvider owns its lifecycle and closes it when the page is popped.
    ..registerFactory(
      () => ProductsBloc(
        sl<ProductsRepository>(),
        sl<CategoriesRepository>(),
        sl<FavoritesCubit>(),
      ),
    );
}
