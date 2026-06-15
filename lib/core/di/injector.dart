import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/auth/di/auth_injector.dart';
import '../../modules/catalog/di/catalog_injector.dart';
import '../../modules/onboarding/di/onboarding_injector.dart';
import '../localization/locale_cubit.dart';
import '../network/api_interface.dart';
import '../network/dio_api_client.dart';
import '../network/dio_client.dart';
import '../network/token_provider.dart';

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
    );

  // SharedPreferences must be awaited once, then registered as a ready instance.
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerLazySingleton<SharedPreferences>(() => prefs)
    // App-level locale (persisted). Drives MaterialApp + accept-language.
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<SharedPreferences>()));
}
