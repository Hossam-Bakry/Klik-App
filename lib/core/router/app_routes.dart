/// Named route paths. Reference these constants instead of raw strings so a
/// rename is a single edit and typos are caught at compile time.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String changePassword = '/change-password';
  static const String catalog = '/catalog';

  /// Routes reachable while unauthenticated (the full auth flow). The guard
  /// allows free navigation among these and blocks everything else.
  static const Set<String> authFlow = {
    login,
    register,
    forgotPassword,
    otp,
    changePassword,
  };
}
