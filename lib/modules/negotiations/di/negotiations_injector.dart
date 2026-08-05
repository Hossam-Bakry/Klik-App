import 'package:get_it/get_it.dart';

import '../../../core/network/api_interface.dart';
import '../data/datasources/negotiations_remote_data_source.dart';
import '../data/repositories/negotiations_repository_impl.dart';
import '../domain/repositories/negotiations_repository.dart';
import '../presentation/bloc/negotiations_bloc.dart';

/// Registers the negotiations module's dependencies. Relies on core deps
/// (ApiInterface) already being registered on [sl].
void registerNegotiationsModule(GetIt sl) {
  sl
    ..registerLazySingleton<NegotiationsRemoteDataSource>(
      () => NegotiationsRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<NegotiationsRepository>(
      () => NegotiationsRepositoryImpl(sl<NegotiationsRemoteDataSource>()),
    )
    // Page-scoped: a fresh bloc per navigation. The route's BlocProvider owns
    // its lifecycle and closes it when the page is popped.
    ..registerFactory(() => NegotiationsBloc(sl<NegotiationsRepository>()));
}
