import 'package:get_it/get_it.dart';

import '../../../core/network/api_interface.dart';
import '../data/datasources/product_remote_data_source.dart';
import '../data/repositories/product_repository_impl.dart';
import '../domain/repositories/product_repository.dart';
import '../presentation/bloc/product_bloc.dart';

/// Registers the product module's dependencies. Relies on core deps
/// (ApiInterface) already being registered on [sl].
void registerProductModule(GetIt sl) {
  sl
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl<ProductRemoteDataSource>()),
    )
    // Page-scoped: a fresh ProductBloc per navigation (factory). The route's
    // BlocProvider owns its lifecycle and closes it when the route is popped.
    ..registerFactory(() => ProductBloc(sl<ProductRepository>()));
}
