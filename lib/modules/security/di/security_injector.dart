import 'package:get_it/get_it.dart';

import '../../../core/network/api_interface.dart';
import '../data/datasources/security_remote_data_source.dart';
import '../data/repositories/security_repository_impl.dart';
import '../domain/repositories/security_repository.dart';
import '../presentation/cubit/security_cubit.dart';

/// Registers the security module's dependencies. Relies on core deps
/// (ApiInterface) already being registered on [sl].
void registerSecurityModule(GetIt sl) {
  sl
    ..registerLazySingleton<SecurityRemoteDataSource>(
      () => SecurityRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<SecurityRepository>(
      () => SecurityRepositoryImpl(sl<SecurityRemoteDataSource>()),
    )
    // Page-scoped: a fresh SecurityCubit per navigation (factory). The route's
    // BlocProvider owns its lifecycle and closes it when the page is popped.
    ..registerFactory(() => SecurityCubit(sl<SecurityRepository>()));
}
