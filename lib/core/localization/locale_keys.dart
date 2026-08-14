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

  // Guest / auth gating
  static const signInRequiredTitle = 'sign_in_required_title';
  static const signInRequiredMessage = 'sign_in_required_message';
  static const somethingWentWrong = 'something_went_wrong';
  static const comingSoon = 'coming_soon';
  static const couldNotOpenLink = 'could_not_open_link';
  static const noInternetConnection = 'no_internet_connection';
  static const checkConnectionRetry = 'check_connection_retry';

  // Profile
  static const orders = 'orders';
  static const myNegotiation = 'my_negotiation';
  static const wishlist = 'wishlist';
  static const notification = 'notification';
  static const noNotificationsYet = 'no_notifications_yet';
  static const manageAddress = 'manage_address';
  static const language = 'language';
  static const country = 'country';
  static const security = 'security';
  static const termsServices = 'terms_services';
  static const privacyPolicy = 'privacy_policy';
  static const logout = 'logout';
  static const logoutConfirm = 'logout_confirm';
  static const sellWithUs = 'sell_with_us';
  static const shareAppMessage = 'share_app_message';
  static const appVersion = 'app_version';
  static const allRightsReserved = 'all_rights_reserved';

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

  // Product details
  static const color = 'color';
  static const size = 'size';
  static const aboutProduct = 'about_product';
  static const reviews = 'reviews';
  static const noReviewsYet = 'no_reviews_yet';
  static const similarProducts = 'similar_products';
  static const addToCart = 'add_to_cart';

  // Cart
  static const cart = 'cart';
  static const cartEmpty = 'cart_empty';
  static const total = 'total';
  static const checkOut = 'check_out';
  static const addedToCart = 'added_to_cart';
  static const buyNow = 'buy_now';
  static const outOfStock = 'out_of_stock';

  // Negotiation (bidable products)
  static const negotiateOffer = 'negotiate_offer';
  static const offersLeft = 'offers_left';
  static const onlyYouSeeOffers = 'only_you_see_offers';
  static const bidExpiresAt = 'bid_expires_at';

  // Price-negotiate sheet
  static const priceNegotiate = 'price_negotiate';
  static const dailyBidLimit = 'daily_bid_limit';
  static const expireIn = 'expire_in';
  static const realPrice = 'real_price';
  static const noAttemptsToday = 'no_attempts_today';
  static const bidPending = 'bid_pending';
  static const bidDeclined = 'bid_declined';
  static const bidCountered = 'bid_countered';
  static const bidApproved = 'bid_approved';
  static const bidExpired = 'bid_expired';
  static const yourOffer = 'your_offer';
  static const yourLastOffer = 'your_last_offer';
  static const lastAcceptedOffer = 'last_accepted_offer';
  static const sellerOffer = 'seller_offer';
  static const counteredPrice = 'countered_price';
  static const clickToFill = 'click_to_fill';
  static const suggestedOffer = 'suggested_offer';
  static const suggestedOfferForYou = 'suggested_offer_for_you';
  static const listedPrice = 'listed_price';
  static const priceAvailableUntil = 'price_available_until';
  static const percentOff = 'percent_off';
  static const yourNegotiatedPrice = 'your_negotiated_price';
  static const offerAmountHint = 'offer_amount_hint';
  static const proceedToCheckout = 'proceed_to_checkout';
  static const bidMinimumOffer = 'bid_minimum_offer';
  static const bidOfferTooSmall = 'bid_offer_too_small';
  static const bidInvalidAmount = 'bid_invalid_amount';
  static const bidSubmitted = 'bid_submitted';

  // My Negotiations
  static const myNegotiations = 'my_negotiations';
  static const all = 'all';
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const expired = 'expired';
  static const noNegotiationsYet = 'no_negotiations_yet';

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
  static const termsConditions = 'terms_conditions';
  static const andConjunction = 'and_conjunction';
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

  // Phone verification (post-registration)
  static const verifyPhoneTitle = 'verify_phone_title';
  static const phoneOtpSentTo = 'phone_otp_sent_to';

  // Change password
  static const changePasswordTitle = 'change_password_title';
  static const changePasswordSubtitle = 'change_password_subtitle';
  static const currentPassword = 'current_password';
  static const newPassword = 'new_password';
  static const confirmPassword = 'confirm_password';
  static const confirmNewPassword = 'confirm_new_password';
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
  static const addressTitle = 'address_title';
  static const add = 'add';
  static const noAddressesAdded = 'no_addresses_added';
  static const deleteAddressConfirm = 'delete_address_confirm';
  static const yes = 'yes';
  static const no = 'no';
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
  static const locationRequired = 'location_required';
  static const typeHome = 'type_home';
  static const typeWork = 'type_work';
  static const typeOther = 'type_other';

  // Location
  static const locating = 'locating';
  static const locationServiceDisabled = 'location_service_disabled';
  static const locationPermissionDenied = 'location_permission_denied';
  static const locationPermissionDeniedForever = 'location_permission_denied_forever';

  // Products list / filters
  static const products = 'products';
  static const searchProductsPrompt = 'search_products_prompt';
  static const filter = 'filter';
  static const filters = 'filters';
  static const reset = 'reset';
  static const selectedFilters = 'selected_filters';
  static const brand = 'brand';
  static const sortedBy = 'sorted_by';
  static const defaultSorting = 'default_sorting';
  static const sortNewProducts = 'sort_new_products';
  static const sortHighToLow = 'sort_high_to_low';
  static const sortLowToHigh = 'sort_low_to_high';
  static const sortBestSelling = 'sort_best_selling';
  static const sortMostPopular = 'sort_most_popular';
  static const sortJustForYou = 'sort_just_for_you';
  static const priceRange = 'price_range';
  static const minPrice = 'min_price';
  static const maxPrice = 'max_price';
  static const rating = 'rating';
  static const ratingAndUp = 'rating_and_up';
  static const negotiableOnly = 'negotiable_only';
  static const applyFilters = 'apply_filters';
  static const clearAll = 'clear_all';
  static const couldNotLoadMore = 'could_not_load_more';

  // Toast messages
  static const loggedOutSuccessfully = 'logged_out_successfully';
  static const changesSavedSuccessfully = 'changes_saved_successfully';
  static const itemAddedToWishlist = 'item_added_to_wishlist';
  static const itemRemovedFromWishlist = 'item_removed_from_wishlist';

  // Support
  static const support = 'support';
  static const supportHeading = 'support_heading';
  static const supportSubtitle = 'support_subtitle';
  static const supportMessageHint = 'support_message_hint';
  static const sendMessage = 'send_message';
  static const supportRequestSent = 'support_request_sent';

  // Security / delete account
  static const deleteAccount = 'delete_account';
  static const deleteAccountTitle = 'delete_account_title';
  static const deleteAccountSubtitle = 'delete_account_subtitle';
  static const pleaseNote = 'please_note';
  static const deleteAccountNoteData = 'delete_account_note_data';
  static const deleteAccountNoteAccess = 'delete_account_note_access';
  static const deleteAccountConfirm = 'delete_account_confirm';
  static const accountDeletedSuccessfully = 'account_deleted_successfully';

  // Edit profile
  static const editProfile = 'edit_profile';
  static const changePhoto = 'change_photo';
  static const profileUpdatedSuccessfully = 'profile_updated_successfully';
  static const takePhoto = 'take_photo';
  static const chooseFromGallery = 'choose_from_gallery';

  // Orders
  static const orderDetails = 'order_details';
  static const findItems = 'find_items';
  static const ordersEmpty = 'orders_empty';
  static const noOrdersMatch = 'no_orders_match';
  static const viewAllDetails = 'view_all_details';
  static const item = 'item';
  static const items = 'items';
  static const rate = 'rate';
  static const deliveryAddress = 'delivery_address';
  static const noAddressOnOrder = 'no_address_on_order';
  static const orderSummary = 'order_summary';
  static const status = 'status';
  static const subtotal = 'subtotal';
  static const shipping = 'shipping';
  static const tax = 'tax';
  static const discount = 'discount';
  static const getHelp = 'get_help';
  static const review = 'review';
  static const cancelOrder = 'cancel_order';
  static const cancelOrderConfirm = 'cancel_order_confirm';
  static const orderCancelledMessage = 'order_cancelled_message';
  static const expected = 'expected';
  static const complete = 'complete';
  static const inProgress = 'in_progress';

  // Order statuses
  static const orderPending = 'order_pending';
  static const orderConfirmed = 'order_confirmed';
  static const orderProcessing = 'order_processing';
  static const orderPickup = 'order_pickup';
  static const orderOnDelivery = 'order_on_delivery';
  static const orderDelivered = 'order_delivered';
  static const orderCancelled = 'order_cancelled';

  // Order date windows
  static const today = 'today';
  static const lastWeek = 'last_week';
  static const last3Weeks = 'last_3_weeks';
  static const lastMonth = 'last_month';
  static const allTime = 'all_time';

  // Order review
  static const writeAReview = 'write_a_review';
  static const writeAReviewHint = 'write_a_review_hint';
  static const yourReview = 'your_review';
  static const addPhotos = 'add_photos';
  static const optional = 'optional';
  static const pickARating = 'pick_a_rating';
  static const reviewRequired = 'review_required';
  static const submitReview = 'submit_review';
  static const reviewSubmitted = 'review_submitted';
  static const whichProductToReview = 'which_product_to_review';

  // Checkout
  static const stepAddress = 'step_address';
  static const stepPayment = 'step_payment';
  static const stepReview = 'step_review';
  // static const change = 'change';
  static const paymentMethod = 'payment_method';
  static const debitCreditCard = 'debit_credit_card';
  static const applePay = 'apple_pay';
  static const googlePay = 'google_pay';
  static const knet = 'knet';
  static const tabby = 'tabby';
  static const tabbyInstallments = 'tabby_installments';
  static const cashOnDelivery = 'cash_on_delivery';
  static const paymentComingSoon = 'payment_coming_soon';
  static const haveACouponCode = 'have_a_coupon_code';
  static const enterCouponCode = 'enter_coupon_code';
  static const apply = 'apply';
  static const couponApplied = 'coupon_applied';
  static const payNow = 'pay_now';
  static const placeOrder = 'place_order';
  static const payWithCashNote = 'pay_with_cash_note';
  static const paymentPendingNote = 'payment_pending_note';
  static const paymentDetails = 'payment_details';
  static const cardNumber = 'card_number';
  static const expireDate = 'expire_date';
  static const cvv = 'cvv';
  static const invalidCardNumber = 'invalid_card_number';
  static const invalidExpiry = 'invalid_expiry';
  static const invalidCvv = 'invalid_cvv';

  // Order placed
  static const orderPlacedSuccessfully = 'order_placed_successfully';
  static const orderConfirmationEmail = 'order_confirmation_email';
  static const orderNumber = 'order_number';
  static const dateAndTime = 'date_and_time';
  static const totalPaid = 'total_paid';
  static const continueShopping = 'continue_shopping';

  // Returns / help
  static const returnPolicy = 'return_policy';
  static const whichItemsCanBeReturned = 'which_items_can_be_returned';
  static const returnRuleUnopened = 'return_rule_unopened';
  static const returnRuleDamaged = 'return_rule_damaged';
  static const returnRuleWithin14Days = 'return_rule_within_14_days';
  static const returnRuleUsed = 'return_rule_used';
  static const returnRuleDigital = 'return_rule_digital';
  static const learnMoreReturnPolicy = 'learn_more_return_policy';
}
