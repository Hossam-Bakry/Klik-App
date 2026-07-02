import 'package:get_it/get_it.dart';

import '../../../core/favorites/presentation/favorites_cubit.dart';
import '../../../core/network/api_interface.dart';
import '../data/datasources/wishlist_remote_data_source.dart';
import '../data/repositories/wishlist_repository_impl.dart';
import '../domain/repositories/wishlist_repository.dart';
import '../presentation/bloc/wishlist_bloc.dart';

/// Registers the wishlist module's dependencies. Relies on core deps
/// (ApiInterface, FavoritesCubit) already being registered on [sl].
void registerWishlistModule(GetIt sl) {
  sl
    ..registerLazySingleton<WishlistRemoteDataSource>(
      () => WishlistRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<WishlistRepository>(
      () => WishlistRepositoryImpl(sl<WishlistRemoteDataSource>()),
    )
    // Page-scoped: a fresh WishlistBloc per navigation (factory). The route's
    // BlocProvider owns its lifecycle and closes it when the page is popped.
    ..registerFactory(
      () => WishlistBloc(sl<WishlistRepository>(), sl<FavoritesCubit>()),
    );
}
