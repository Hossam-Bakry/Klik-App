import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user has completed onboarding. A plain key/value flag
/// in [SharedPreferences] is the right tool here — it's non-sensitive and only
/// gates first-launch UI. (Tokens still live in secure storage.)
abstract class OnboardingLocalDataSource {
  Future<bool> hasCompletedOnboarding();
  Future<void> markCompleted();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  OnboardingLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'onboarding_completed';

  @override
  Future<bool> hasCompletedOnboarding() async =>
      _prefs.getBool(_key) ?? false;

  @override
  Future<void> markCompleted() async => _prefs.setBool(_key, true);
}
