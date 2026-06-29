import 'package:get_it/get_it.dart';

import '../../../core/network/api_interface.dart';
import '../data/datasources/home_remote_data_source.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../presentation/bloc/home_bloc.dart';

/// Registers the home module's dependencies. Relies on core deps (ApiInterface)
/// already being registered on [sl].
void registerHomeModule(GetIt sl) {
  sl
    ..registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(sl<HomeRemoteDataSource>()),
    )
    // Page-scoped: a fresh HomeBloc per navigation (factory). The host layout's
    // BlocProvider owns its lifecycle.
    ..registerFactory(() => HomeBloc(sl<HomeRepository>()));
}
