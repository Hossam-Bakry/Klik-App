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
  static const String verifyPhone = '/verify-phone';
  static const String changePassword = '/change-password';
  static const String home = '/home';
  static const String productDetails = '/product';
  static const String products = '/products';
  static const String shops = '/shops';
  static const String wishlist = '/wishlist';
  static const String support = '/support';
  static const String security = '/security';
  static const String updatePassword = '/update-password';
  static const String editProfile = '/edit-profile';
  static const String addressList = '/address';
  static const String addressAdd = '/address/add';
  static const String addressEdit = '/address/edit';

  /// The auth flow screens. Authenticated users are bounced out of these into
  /// the app; guests may visit them freely to sign in.
  static const Set<String> authFlow = {
    login,
    register,
    forgotPassword,
    otp,
    verifyPhone,
    changePassword,
  };

  /// Routes that require a real session. A guest who navigates here is
  /// redirected to [login]. Browse routes (home, catalog) are intentionally
  /// absent so anonymous users can explore the app.
  static const Set<String> authRequired = {
    addressList,
    addressAdd,
    addressEdit,
    wishlist,
    security,
    updatePassword,
    editProfile,
  };
}
