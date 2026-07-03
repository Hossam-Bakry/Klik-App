import 'package:get_it/get_it.dart';

import '../../../core/network/api_interface.dart';
import '../data/datasources/support_remote_data_source.dart';
import '../data/repositories/support_repository_impl.dart';
import '../domain/repositories/support_repository.dart';
import '../presentation/cubit/support_cubit.dart';

/// Registers the support module's dependencies. Relies on core deps
/// (ApiInterface) already being registered on [sl].
void registerSupportModule(GetIt sl) {
  sl
    ..registerLazySingleton<SupportRemoteDataSource>(
      () => SupportRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<SupportRepository>(
      () => SupportRepositoryImpl(sl<SupportRemoteDataSource>()),
    )
    // Page-scoped: a fresh SupportCubit per navigation (factory). The route's
    // BlocProvider owns its lifecycle and closes it when the page is popped.
    ..registerFactory(() => SupportCubit(sl<SupportRepository>()));
}
