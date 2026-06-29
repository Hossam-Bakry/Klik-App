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
  static const profileTitle = 'profile_title';
  static const somethingWentWrong = 'something_went_wrong';
  static const comingSoon = 'coming_soon';

  // Home
  static const deliverTo = 'deliver_to';
  static const homeGreeting = 'home_greeting';
  static const homeWelcome = 'home_welcome';
  static const searchHint = 'search_hint';
  static const promoTitle = 'promo_title';
  static const promoSubtitle = 'promo_subtitle';
  static const categories = 'categories';
  static const popularProducts = 'popular_products';
  static const seeAll = 'see_all';
  static const bestDealsForYou = 'best_deals_for_you';
  static const shops = 'shops';
  static const openToOffers = 'open_to_offers';
  static const sold = 'sold';
  static const negotiate = 'negotiate';
  static const sellerAcceptsOffers = 'seller_accepts_offers';
  static const currencyKwd = 'currency_kwd';
  static const noItemsYet = 'no_items_yet';

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
  static const phoneNoLeadingZero = 'phone_no_leading_zero';
  static const invalidEmail = 'invalid_email';
  static const nameMin = 'name_min';
  static const nameMax = 'name_max';
  static const nameInvalid = 'name_invalid';
  static const passwordMin = 'password_min';
  static const passwordStrong = 'password_strong';
  static const passwordMax = 'password_max';
  static const passwordsDoNotMatch = 'passwords_do_not_match';
  static const mustAgreeTerms = 'must_agree_terms';

  // Addresses
  static const addNewAddress = 'add_new_address';
  static const editAddress = 'edit_address';
  static const chooseAddressLocation = 'choose_address_location';
  static const savedAddresses = 'saved_addresses';
  static const searchAnAddress = 'search_an_address';
  static const noAddressesFound = 'no_addresses_found';
  static const selectAddress = 'select_address';
  static const city = 'city';
  static const area = 'area';
  static const flatNumber = 'flat_number';
  static const postCode = 'post_code';
  static const addressLine1 = 'address_line_1';
  static const addressLine2 = 'address_line_2';
  static const setAsDefaultAddress = 'set_as_default_address';
  static const saveAddress = 'save_address';
  static const saveChanges = 'save_changes';
  static const useCurrentLocation = 'use_current_location';
  static const change = 'change';
  static const selectLocation = 'select_location';
  static const confirmLocation = 'confirm_location';
  static const moveMapToSelect = 'move_map_to_select';
  static const typeHome = 'type_home';
  static const typeWork = 'type_work';
  static const typeOther = 'type_other';

  // Location
  static const locating = 'locating';
  static const locationServiceDisabled = 'location_service_disabled';
  static const locationPermissionDenied = 'location_permission_denied';
  static const locationPermissionDeniedForever = 'location_permission_denied_forever';
}
