import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/address/di/address_injector.dart';
import '../../modules/auth/di/auth_injector.dart';
import '../../modules/catalog/di/catalog_injector.dart';
import '../../modules/categories/di/categories_injector.dart';
import '../../modules/home/di/home_injector.dart';
import '../../modules/negotiations/di/negotiations_injector.dart';
import '../../modules/onboarding/di/onboarding_injector.dart';
import '../../modules/orders/di/orders_injector.dart';
import '../../modules/product/di/product_injector.dart';
import '../../modules/products/di/products_injector.dart';
import '../../modules/profile/di/profile_injector.dart';
import '../../modules/security/di/security_injector.dart';
import '../../modules/shops/di/shops_injector.dart';
import '../../modules/support/di/support_injector.dart';
import '../../modules/update_password/di/update_password_injector.dart';
import '../../modules/wishlist/di/wishlist_injector.dart';
import '../../modules/auth/presentation/bloc/auth_bloc.dart';
import '../cart/data/cart_remote_data_source.dart';
import '../cart/data/cart_repository_impl.dart';
import '../cart/data/local_cart_store.dart';
import '../cart/domain/cart_repository.dart';
import '../cart/presentation/cart_cubit.dart';
import '../favorites/data/favorites_remote_data_source.dart';
import '../favorites/data/favorites_repository_impl.dart';
import '../favorites/domain/favorites_repository.dart';
import '../favorites/presentation/favorites_cubit.dart';
import '../localization/locale_cubit.dart';
import '../network/api_interface.dart';
import '../network/connectivity_cubit.dart';
import '../network/dio_api_client.dart';
import '../network/dio_client.dart';
import '../network/token_provider.dart';
import '../services/location_service.dart';
import '../services/otp_cooldown_store.dart';

/// Global service locator. Kept manual (no injectable/codegen) so the project
/// builds without `build_runner`.
///
/// Composition root: this file registers shared core dependencies, then hands
/// [sl] to each module's own injector. Every module owns its registrations in
/// `modules/<name>/di/<name>_injector.dart` — add a new module by writing its
/// injector and calling it here.
final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  await _registerCore();

  // Per-module registrations. Core must be registered first since modules
  // depend on it (Dio, secure storage, prefs).
  registerAuthModule(sl);
  registerOnboardingModule(sl);
  registerCatalogModule(sl);
  registerCategoriesModule(sl);
  registerHomeModule(sl);
  registerAddressModule(sl);
  registerNegotiationsModule(sl);
  registerOrdersModule(sl);
  registerProductModule(sl);
  registerProductsModule(sl);
  registerProfileModule(sl);
  registerSecurityModule(sl);
  registerShopsModule(sl);
  registerSupportModule(sl);
  registerUpdatePasswordModule(sl);
  registerWishlistModule(sl);
}

/// Shared, cross-module dependencies.
Future<void> _registerCore() async {
  sl
    // DioClient reads the token via TokenProvider (auth module) and the active
    // language via LocaleCubit. Resolution is lazy, so registration order is
    // fine — both are available by the time the first request fires.
    ..registerLazySingleton<DioClient>(
      () => DioClient(
        sl<TokenProvider>(),
        languageProvider: () => sl<LocaleCubit>().state.languageCode,
      ),
    )
    // Data sources depend on ApiInterface, not Dio directly.
    ..registerLazySingleton<ApiInterface>(
      () => DioApiClient(sl<DioClient>().dio),
    )
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    // Current-location + reverse-geocoding, shared by the address module.
    ..registerLazySingleton<LocationService>(() => const LocationService())
    // App-wide connectivity: a singleton stream of online/offline status,
    // surfaced as a global overlay in MaterialApp's builder.
    ..registerLazySingleton<Connectivity>(() => Connectivity())
    ..registerLazySingleton<ConnectivityCubit>(
      () => ConnectivityCubit(sl<Connectivity>()),
    )
    // App-wide favorites: a single shared set of favorited product ids so
    // every product card (home, categories, product details) stays in sync.
    ..registerLazySingleton<FavoritesRemoteDataSource>(
      () => FavoritesRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(sl<FavoritesRemoteDataSource>()),
    )
    ..registerLazySingleton<FavoritesCubit>(
      () => FavoritesCubit(sl<FavoritesRepository>()),
    );

  // SharedPreferences must be awaited once, then registered as a ready instance.
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerLazySingleton<SharedPreferences>(() => prefs)
    // App-level locale (persisted). Drives MaterialApp + accept-language.
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<SharedPreferences>()))
    // Persistent per-phone OTP resend cooldown (survives navigation/restart).
    ..registerLazySingleton<OtpCooldownStore>(
      () => OtpCooldownStore(sl<SharedPreferences>()),
    )
    // Cart: a guest's cart is held entirely on the device (no cart API calls
    // at all), a signed-in user's is the server's. The repository routes each
    // call by session; CartCubit merges the guest lines in once on sign-in.
    ..registerLazySingleton<LocalCartStore>(
      () => LocalCartStore(sl<SharedPreferences>()),
    )
    ..registerLazySingleton<CartRemoteDataSource>(
      () => CartRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(
        sl<CartRemoteDataSource>(),
        sl<LocalCartStore>(),
        () => sl<AuthBloc>().state.isAuthenticated,
      ),
    )
    ..registerLazySingleton<CartCubit>(() => CartCubit(sl<CartRepository>()));
}
