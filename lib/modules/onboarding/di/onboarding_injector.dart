import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/onboarding_local_data_source.dart';
import '../presentation/cubit/onboarding_cubit.dart';

/// Registers the onboarding module's dependencies. A thin feature — no domain
/// layer. Relies on [SharedPreferences] already being registered on [sl].
void registerOnboardingModule(GetIt sl) {
  sl
    ..registerLazySingleton<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSourceImpl(sl<SharedPreferences>()),
    )
    // App-scoped like AuthBloc — the router guard reads its state.
    ..registerLazySingleton(
      () => OnboardingCubit(sl<OnboardingLocalDataSource>()),
    );
}
