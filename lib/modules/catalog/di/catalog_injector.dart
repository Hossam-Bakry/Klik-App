import 'package:get_it/get_it.dart';

import '../../../core/network/api_interface.dart';
import '../data/datasources/catalog_remote_data_source.dart';
import '../data/repositories/catalog_repository_impl.dart';
import '../domain/repositories/catalog_repository.dart';
import '../presentation/bloc/catalog_bloc.dart';

/// Registers the catalog module's dependencies. Relies on core deps (DioClient)
/// already being registered on [sl].
void registerCatalogModule(GetIt sl) {
  sl
    ..registerLazySingleton<CatalogRemoteDataSource>(
      () => CatalogRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(sl<CatalogRemoteDataSource>()),
    )
    // Page-scoped: a fresh CatalogBloc per navigation (factory). The route's
    // BlocProvider owns its lifecycle and closes it when the route is popped.
    ..registerFactory(() => CatalogBloc(sl<CatalogRepository>()));
}
