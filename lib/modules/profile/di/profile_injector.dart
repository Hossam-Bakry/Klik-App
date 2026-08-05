import 'package:get_it/get_it.dart';

import '../../../core/network/api_interface.dart';
import '../data/datasources/profile_remote_data_source.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import '../presentation/cubit/current_user_cubit.dart';
import '../presentation/cubit/edit_profile_cubit.dart';

/// Registers the profile module's dependencies. Relies on core deps
/// (ApiInterface) already being registered on [sl].
void registerProfileModule(GetIt sl) {
  sl
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
    )
    // App-wide: the signed-in user's profile, provided at the root and driven
    // by AuthStatus (loaded on sign-in, cleared on sign-out).
    ..registerLazySingleton<CurrentUserCubit>(
      () => CurrentUserCubit(sl<ProfileRepository>()),
    )
    // Page-scoped: a fresh EditProfileCubit per navigation (factory). The
    // route's BlocProvider owns its lifecycle and closes it when popped.
    ..registerFactory(() => EditProfileCubit(sl<ProfileRepository>()));
}
