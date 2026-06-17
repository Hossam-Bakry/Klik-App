/// Type-safe keys for the localization JSON files (assets/lang/*.json).
///
/// Use these instead of raw strings so a typo is a compile error and every key
/// is declared exactly once. Each constant must match a key present in every
/// language file.
abstract class LocaleKeys {
  static const appName = 'app_name';

  static const onboardingWelcomeTitle = 'onboarding_welcome_title';
  static const onboardingWelcomeSubtitle = 'onboarding_welcome_subtitle';
  static const onboardingDeliveryTitle = 'onboarding_delivery_title';
  static const onboardingDeliverySubtitle = 'onboarding_delivery_subtitle';

  static const skip = 'skip';
  static const next = 'next';
  static const getStarted = 'get_started';
  static const retry = 'retry';

  static const storeTitle = 'store_title';
  static const signOut = 'sign_out';
  static const somethingWentWrong = 'something_went_wrong';
  static const comingSoon = 'coming_soon';

  // Home
  static const homeGreeting = 'home_greeting';
  static const homeWelcome = 'home_welcome';
  static const searchHint = 'search_hint';
  static const promoTitle = 'promo_title';
  static const promoSubtitle = 'promo_subtitle';
  static const categories = 'categories';
  static const popularProducts = 'popular_products';
  static const seeAll = 'see_all';

  // Login
  static const welcomeBack = 'welcome_back';
  static const loginSubtitle = 'login_subtitle';
  static const phoneNumber = 'phone_number';
  static const password = 'password';
  static const fullName = 'full_name';
  static const emailAddress = 'email_address';
  static const forgetPasswordQ = 'forget_password_q';
  static const logIn = 'log_in';
  static const noAccount = 'no_account';
  static const signUp = 'sign_up';
  static const or = 'or';

  // Register
  static const createAccount = 'create_account';
  static const registerSubtitle = 'register_subtitle';
  static const agreePrefix = 'agree_prefix';
  static const termsPrivacy = 'terms_privacy';
  static const haveAccount = 'have_account';

  // Forgot password
  static const forgetPasswordTitle = 'forget_password_title';
  static const forgetPasswordSubtitle = 'forget_password_subtitle';
  static const sendOtp = 'send_otp';

  // OTP
  static const enterOtp = 'enter_otp';
  static const otpSentTo = 'otp_sent_to';
  static const resendOtpIn = 'resend_otp_in';
  static const verifyOtp = 'verify_otp';

  // Change password
  static const changePasswordTitle = 'change_password_title';
  static const changePasswordSubtitle = 'change_password_subtitle';
  static const newPassword = 'new_password';
  static const confirmPassword = 'confirm_password';
  static const changePassword = 'change_password';
  static const passwordChanged = 'password_changed';

  // Validation
  static const fieldRequired = 'field_required';
  static const invalidPhone = 'invalid_phone';
  static const invalidEmail = 'invalid_email';
  static const passwordMin = 'password_min';
  static const passwordsDoNotMatch = 'passwords_do_not_match';
  static const mustAgreeTerms = 'must_agree_terms';
}
